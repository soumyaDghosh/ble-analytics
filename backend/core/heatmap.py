from django.db.models import Count, Min, Q
from django.db.models.functions import ExtractHour
from django.utils import timezone

from .models import LocationPing

# RSSI honestly encodes distance, never bearing — a ping only says how far a
# device was from the beacon, not which way. So everything here is a distance
# band (near/mid/far), never a position. Footfall bands a visitor by their
# *closest* approach; Focus bands a store's dwell *time* by distance.

# Bands in meters (locked with user 2026-07-11):
NEAR_M, MID_M = 3.0, 9.0


def _store_pings(mall_id, start, end, store_ids=None):
    """Base queryset of store-beacon pings in the window (gate pings excluded).
    store_ids=None → every store; a list → restrict (empty list → no rows, and
    Django short-circuits `__in=[]` without hitting the DB)."""
    qs = LocationPing.objects.filter(mall_id=mall_id, store_id__isnull=False,
                                     time__gte=start, time__lt=end)
    return qs.filter(store_id__in=store_ids) if store_ids is not None else qs


def beacon_counts(mall_id, floor_id, start, end, beacon_ids=None):
    # Footfall = distinct devices (people), NOT raw pings — one lingering phone
    # emits many pings but is one visitor.
    qs = (LocationPing.objects
          .filter(mall_id=mall_id, beacon__floor_id=floor_id,
                  time__gte=start, time__lt=end))
    if beacon_ids is not None:
        qs = qs.filter(beacon_id__in=beacon_ids)
    qs = (qs.values('beacon_id').annotate(w=Count('device_hash', distinct=True)))
    return {r['beacon_id']: r['w'] for r in qs}


def store_band_visitors(mall_id, start, end, store_ids=None):
    """Per-store visitor distance distribution — each distinct device counted
    ONCE, in the band of its *closest* approach (min distance) over the window.
    So near+mid+far == the true unique-visitor count.

    Closest approach, not average: if a phone ever got within 3m it *entered*
    (near) — they're not Schrödinger's cat, averaging in their far pings would
    wrongly demote a real visit. A device lands in `far` only if it never came
    within MID_M — a true passer-by.

    Returns {store_id: {'near': int, 'mid': int, 'far': int, 'total': int}}.
    """
    # One row per (store, device) with that device's closest distance to the store.
    qs = (_store_pings(mall_id, start, end, store_ids)
          .values('store_id', 'device_hash').annotate(mind=Min('est_distance')))
    out = {}
    for r in qs:
        d = out.setdefault(r['store_id'], {'near': 0, 'mid': 0, 'far': 0, 'total': 0})
        band = 'near' if r['mind'] < NEAR_M else 'mid' if r['mind'] < MID_M else 'far'
        d[band] += 1
        d['total'] += 1
    return out


# -- insights ---------------------------------------------------------------

def store_engagement(mall_id, start, end, store_ids=None):
    """Per-store near-share: what fraction of a store's detections landed within
    NEAR_M (~3m) of the beacon. Reads as "did they get close, or just pass by".
    Ping-based (not distinct devices) so it spreads — counting distinct visitors
    saturates near 100%, since a lingering phone almost always logs one near ping.
    Returns [{'store_id','near','total','share'}] sorted by share desc, only
    stores with total >= MIN_SAMPLE detections (small-N would be noise)."""
    MIN_SAMPLE = 10
    qs = (_store_pings(mall_id, start, end, store_ids)
          .values('store_id')
          .annotate(near=Count('id', filter=Q(est_distance__lt=NEAR_M)),
                    total=Count('id')))
    rows = []
    for r in qs:
        if r['total'] < MIN_SAMPLE:
            continue
        rows.append({'store_id': r['store_id'], 'near': r['near'],
                     'total': r['total'],
                     'share': round(100 * r['near'] / r['total'])})
    rows.sort(key=lambda r: r['share'], reverse=True)
    return rows


def store_dwell_by_band(mall_id, start, end, store_ids=None):
    """Per-store dwell *time* split across distance bands — how much of a store's
    detection-time was spent close (near, at the counter) vs at the edge (mid/far).
    Ping-count is the time proxy: pings are ~periodic, so more pings in a band ≈
    more time there. (ponytail: count proxy; sum consecutive-ping deltas if the
    view ever needs true minutes.)

    RSSI has no bearing, so this is 'close vs far from the beacon', never
    'inside vs in front of'. Returns {store_id: {'near','mid','far'}}.
    """
    qs = (_store_pings(mall_id, start, end, store_ids)
          .values('store_id')
          .annotate(near=Count('id', filter=Q(est_distance__lt=NEAR_M)),
                    mid=Count('id', filter=Q(est_distance__gte=NEAR_M,
                                             est_distance__lt=MID_M)),
                    far=Count('id', filter=Q(est_distance__gte=MID_M))))
    return {r['store_id']: {'near': r['near'], 'mid': r['mid'], 'far': r['far']}
            for r in qs}


def hourly_footfall(mall_id, start, end, store_ids=None):
    """Distinct visitors per hour-of-day over the window. Returns a 24-slot list
    of ints (index = local hour). Extract in the active tz so buckets line up
    with wall-clock hours, not UTC."""
    qs = (LocationPing.objects
          .filter(mall_id=mall_id, time__gte=start, time__lt=end))
    if store_ids is not None:
        qs = qs.filter(store_id__in=store_ids)
    tz = timezone.get_current_timezone()
    qs = (qs.annotate(h=ExtractHour('time', tzinfo=tz))
            .values('h')
            .annotate(w=Count('device_hash', distinct=True)))
    hours = [0] * 24
    for r in qs:
        hours[r['h']] = r['w']
    return hours


# -- colors -----------------------------------------------------------------

# Footfall distance-band bar: sequential amber ramp, near (closest, strongest
# signal) = darkest → far = lightest. Validated lightness-monotonic (dataviz).
BAND_COLOR = {'near': '#7A4A02', 'mid': '#D68A0C', 'far': '#F2C879'}