import json
import logging
from datetime import timedelta

from django.http import HttpResponse, HttpResponseBadRequest, JsonResponse
from django.utils import timezone
from django.utils.dateparse import parse_datetime
from django.views.decorators.csrf import csrf_exempt

from .models import Beacon, CacheVersion, Campaign, CampaignImpression, Floor, LocationPing

logger = logging.getLogger(__name__)


def _mall_id(request):
    try:
        return int(request.GET['mall_id'])
    except (KeyError, ValueError):
        return None


def cache_version(request):
    """HEAD /api/v1/cache/version?mall_id=N -> Cache-Version header."""
    mall_id = _mall_id(request)
    if mall_id is None:
        return HttpResponseBadRequest('mall_id required')
    cv = CacheVersion.objects.filter(mall_id=mall_id).first()
    if cv is None:
        return HttpResponse(status=404)
    resp = HttpResponse(status=200)
    resp['Cache-Version'] = str(cv.version)
    return resp


def data_sync(request):
    """GET /api/v1/data/sync?mall_id=N -> ultra-light per-mall JSON (<10KB)."""
    mall_id = _mall_id(request)
    if mall_id is None:
        return HttpResponseBadRequest('mall_id required')
    cv = CacheVersion.objects.select_related('mall').filter(mall_id=mall_id).first()
    if cv is None:
        return HttpResponse(status=404)
    mall = cv.mall
    now = timezone.now()

    floors = list(Floor.objects.filter(mall_id=mall_id).values('id', 'number', 'name'))
    stores = [{'id': s.id, 'name': s.name, 'category': s.category,
               'floor_id': s.floor_id, 'x': s.pos_x, 'y': s.pos_y,
               'image': request.build_absolute_uri(s.image.url) if s.image else None,
               'tagline': s.tagline, 'badge': s.badge}
              for s in mall.stores.all()]
    beacons = [{'id': b.adv_id, 'store_id': b.store_id, 'x': b.pos_x, 'y': b.pos_y,
                'floor_id': b.floor_id, 'tx': b.tx_power}
               for b in mall.beacons.all()]

    # Active + soon-to-start (24h) so the app has it cached before the time boundary.
    # App filters starts<=now<=ends locally — fixes "activates on time, version never bumps".
    camps = (Campaign.objects
             .filter(store__mall_id=mall_id, status=Campaign.ACTIVE,
                     ends_at__gte=now, starts_at__lte=now + timedelta(days=1))
             .prefetch_related('target_beacons'))
    campaigns = []
    for c in camps:
        item = {'id': c.id, 'store_id': c.store_id, 'title': c.title, 'body': c.body,
                'coupon': c.coupon, 'beacons': [b.adv_id for b in c.target_beacons.all()],
                'starts': c.starts_at.isoformat(), 'ends': c.ends_at.isoformat()}
        if c.discount:
            item['discount'] = c.discount
        campaigns.append(item)

    return JsonResponse({'version': cv.version, 'mall': {'id': mall.id, 'name': mall.name},
                         'floors': floors, 'stores': stores, 'beacons': beacons,
                         'campaigns': campaigns})


@csrf_exempt
def location_batch(request):
    """POST /api/v1/location/batch -> ingest pings + impressions. Phone AND seeder use this."""
    if request.method != 'POST':
        return HttpResponseBadRequest('POST only')
    try:
        data = json.loads(request.body)
    except (ValueError, TypeError):
        logger.warning('location_batch: invalid json (%d bytes)', len(request.body))
        return HttpResponseBadRequest('invalid json')

    device_hash = data.get('device_hash')
    pings = data.get('pings', [])
    impressions = data.get('impressions', [])
    if not isinstance(device_hash, str) or not device_hash:
        return HttpResponseBadRequest('device_hash required')
    if not isinstance(pings, list) or len(pings) > 5000:
        return HttpResponseBadRequest('pings must be a list of <= 5000')

    beacons = {b.adv_id: b for b in Beacon.objects.filter(adv_id__in={p.get('b') for p in pings})}
    rows, skipped = [], 0
    for p in pings:
        b = beacons.get(p.get('b'))
        t = parse_datetime(p.get('t') or '')
        rssi = p.get('rssi')
        if b is None or t is None or not isinstance(rssi, (int, float)) or isinstance(rssi, bool):
            skipped += 1
            continue
        est = 10 ** ((b.tx_power - rssi) / 20.0)  # log-distance, n=2
        rows.append(LocationPing(time=t, device_hash=device_hash, beacon=b,
                                 store_id=b.store_id, mall_id=b.mall_id,
                                 rssi=int(rssi), est_distance=est))
    LocationPing.objects.bulk_create(rows, ignore_conflicts=True)

    imp_rows = []
    for im in impressions if isinstance(impressions, list) else []:
        t = parse_datetime(im.get('t') or '')
        cid = im.get('c')
        if t is not None and isinstance(cid, int):
            imp_rows.append(CampaignImpression(campaign_id=cid, device_hash=device_hash,
                                               triggered_at=t, opened=bool(im.get('opened'))))
    CampaignImpression.objects.bulk_create(imp_rows)

    logger.info('location_batch device=%s pings=%d skipped=%d impressions=%d',
                device_hash[:8], len(rows), skipped, len(imp_rows))
    return JsonResponse({'pings': len(rows), 'skipped': skipped, 'impressions': len(imp_rows)})
