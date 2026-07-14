from datetime import datetime, time, timedelta
from functools import wraps

from django.contrib.auth import get_user_model
from django.contrib.auth.decorators import login_required, user_passes_test
from django.core.exceptions import PermissionDenied
from django.db.models import Count
from django.shortcuts import get_object_or_404, redirect, render
from django.utils import timezone
from django.utils.html import format_html

from .dwell import (BUCKET_NAMES, DOMINANT_COLOR, dwell_buckets_per_store,
                    dwell_stats)
from .forms import (AdminSignupForm, BeaconForm, CampaignForm, FloorForm,
                    MallForm, SignupForm, StoreForm)
from .heatmap import (BAND_COLOR, beacon_counts, hourly_footfall,
                      store_band_visitors, store_dwell_by_band, store_engagement)
from .models import (Beacon, CacheVersion, Campaign, Floor, LocationPing, Mall,
                     Store)

admin_only = user_passes_test(lambda u: u.is_superuser)


def keeper_only(view):
    """Campaigns belong to storekeepers, not admins - 403 superusers out."""
    @wraps(view)
    def wrapped(request, *args, **kwargs):
        if request.user.is_superuser:
            raise PermissionDenied
        return view(request, *args, **kwargs)
    return wrapped

BARW = 116  # store metric-bar width (px), narrower than the 124px store box


def _fmt_dur(sec):
    """Seconds → compact human label, e.g. 40s, 2m, 2m 40s."""
    if sec < 60:
        return f'{sec}s'
    m, s = divmod(sec, 60)
    return f'{m}m {s}s' if s else f'{m}m'


def _stack_segments(pairs, barw=BARW):
    """Turn [(name, count, color), ...] into positioned stacked-bar segments
    [{'name','count','color','x','w'}] proportional to the total. Shared by the
    footfall (distance bands) and dwell (session buckets) store bars."""
    total = sum(c for _, c, _ in pairs)
    segs, x = [], 0.0
    if total:
        for name, count, color in pairs:
            if count:
                w = barw * count / total
                segs.append({'name': name, 'count': count, 'color': color,
                             'x': round(x, 2), 'w': round(w, 2)})
                x += w
    return segs, total


def visible_stores(user):
    qs = Store.objects.select_related('floor', 'mall')
    return qs if user.is_superuser else qs.filter(keeper=user)


def _place_ctx(mall, form, kind, inst):
    """Shared context for the graph-paper place editor. Ships every floor's
    coordinate space (+ its boundary outline) so the canvas resizes/regrids/redraws
    on the floor <select>, plus the other shops and beacons drawn as faint context.
    The shop/beacon being edited is excluded - its own layer draws it live."""
    floors = list(Floor.objects.filter(mall=mall))
    spaces = {}
    for f in floors:
        sp = f.space
        if f.outline:
            sp['outline'] = ' '.join(f'{p[0]},{p[1]}' for p in f.outline)
        spaces[str(f.id)] = sp
    cur_store = inst.id if (kind == 'store' and inst) else None
    cur_beacon = inst.id if (kind == 'beacon' and inst) else None
    ref_stores = [
        {'floor': s.floor_id, 'name': s.name, 'x': s.pos_x, 'y': s.pos_y,
         'points': ' '.join(f'{p[0]},{p[1]}' for p in s.shape) if s.shape else ''}
        for s in Store.objects.filter(mall=mall).exclude(pk=cur_store)]
    ref_beacons = [
        {'id': b.id, 'floor': b.floor_id, 'x': b.pos_x, 'y': b.pos_y,
         'mine': cur_store is not None and b.store_id == cur_store}
        for b in Beacon.objects.filter(mall=mall).exclude(pk=cur_beacon)]
    return {'form': form, 'kind': kind, 'obj': inst, 'floors': floors,
            'floor_spaces': spaces, 'ref_stores': ref_stores, 'ref_beacons': ref_beacons,
            'is_new': inst is None,
            'init_floor_id': inst.floor_id if inst else (floors[0].id if floors else 0)}


def _range(key):
    now = timezone.now()
    spans = {'7d': timedelta(days=7), '30d': timedelta(days=30), 'all': timedelta(days=3650)}
    if key in spans:
        return now - spans[key], now
    start = timezone.make_aware(datetime.combine(timezone.localdate(), time.min))
    return start, now  # today


@login_required
def mall_settings(request):
    """Fresh-setup create + later edit for the single mall. Storekeepers never
    set up a mall - they only reach here via the gate before one exists, and see
    a wait screen."""
    mall = Mall.objects.first()
    if not request.user.is_superuser:
        return redirect('dashboard') if mall else render(request, 'mall_setup_wait.html')
    if request.method == 'POST':
        form = MallForm(request.POST, instance=mall)
        if form.is_valid():
            m = form.save(commit=False)
            if not mall:
                m.id = 1  # pin id=1 so the app's hardcoded mall_id resolves (single-mall MVP)
            m.save()
            # The app polls /api/v1/cache/version and 404s without this row - seed
            # makes it too. Every mall needs its cache pointer from birth.
            CacheVersion.objects.get_or_create(mall=m)
            return redirect('dashboard')
    else:
        form = MallForm(instance=mall)
    return render(request, 'mall_form.html', {'form': form, 'obj': mall})


@login_required
def overview(request):
    stores = visible_stores(request.user)
    start, now = _range('today')
    mall = Mall.objects.first()

    pings = LocationPing.objects.filter(time__gte=start)
    store_ids = None
    if not request.user.is_superuser:
        store_ids = list(stores.values_list('id', flat=True))
        pings = pings.filter(store_id__in=store_ids)

    active = Campaign.objects.filter(store__in=stores, status=Campaign.ACTIVE,
                                     ends_at__gte=now).count()
    stats = {'rows': [
        ('Footfall', pings.values('device_hash').distinct().count(), 'unique visitors'),
        ('Detections', pings.count(), 'beacon pings'),
        ('Stores', stores.count(), 'in scope'),
        ('Campaigns', active, 'active now'),
    ]}
    busiest = (pings.values('store_id')
               .annotate(w=Count('device_hash', distinct=True)).order_by('-w')[:5])
    names = dict(Store.objects.filter(mall=mall).values_list('id', 'name')) if mall else {}
    busiest = [{'name': names.get(r['store_id'], 'Common area'), 'w': r['w']} for r in busiest]

    # Dwell today - headline "how long they stayed": avg stay + distribution.
    ds = (dwell_stats(mall.id, start, now, store_ids=store_ids) if mall else
          {'totals': {n: 0 for n in BUCKET_NAMES}, 'total_sessions': 0, 'avg_s': 0})
    totals = ds['totals']
    # Plain-English ranges shown next to each bucket label.
    ranges_txt = {'glance': '<15s', 'look': '15–60s', 'browse': '1–5 min', 'linger': '>5 min'}
    dwell_today = {
        'totals': totals,
        'max': max(totals.values(), default=1) or 1,
        'total_sessions': ds['total_sessions'],
        'avg_label': _fmt_dur(ds['avg_s']),
        'buckets': [(name, ranges_txt[name], totals.get(name, 0)) for name in BUCKET_NAMES],
    }

    # Engagement - share of a store's detections within ~3m (near band).
    engagement = store_engagement(mall.id, start, now, store_ids=store_ids) if mall else []
    for r in engagement:
        r['name'] = names.get(r['store_id'], 'Common area')
    # Hover alert: enough traffic, but most detection-time was NOT close (<34%
    # near) - people linger at the store's edge without coming in to the counter.
    HOVER_MAX_NEAR = 34  # ponytail: fixed threshold; tune if it fires too often
    hover_stores = [r['name'] for r in engagement if r['share'] < HOVER_MAX_NEAR]
    engagement = engagement[:6]

    # Hourly footfall - distinct visitors by wall-clock hour today. Highlight every
    # bar tied at the peak (not just the first), so plateaus read honestly.
    hours = hourly_footfall(mall.id, start, now, store_ids=store_ids) if mall else [0] * 24
    hmax = max(hours) or 1
    peak_hours = [h for h, n in enumerate(hours) if n == hmax] if any(hours) else []
    hourly = {'bars': list(enumerate(hours)), 'max': hmax, 'total': sum(hours),
              'peak_label': ', '.join(f'{h}:00' for h in peak_hours[:3])}

    return render(request, 'overview.html',
                  {'stats': stats, 'busiest': busiest, 'dwell_today': dwell_today,
                   'engagement': engagement, 'hourly': hourly,
                   'hover_stores': hover_stores})


@login_required
def heatmap(request):
    mall = Mall.objects.first()
    floors = list(Floor.objects.filter(mall=mall))
    floor_id = int(request.GET.get('floor') or (floors[0].id if floors else 0))
    span = request.GET.get('range', 'today')
    view = request.GET.get('view', 'footfall')
    if view not in ('footfall', 'dwell', 'focus'):
        view = 'footfall'
    start, end = _range(span)

    stores = visible_stores(request.user).filter(mall=mall, floor_id=floor_id).order_by('category', 'name')
    # Restrict beacons to those of the visible stores; gate beacons (store=None)
    # are public - every visitor passes through them - keep them for everyone.
    if request.user.is_superuser:
        beacons = list(Beacon.objects.filter(mall=mall, floor_id=floor_id))
        store_ids_on_floor = [s.id for s in stores]
    else:
        store_ids_on_floor = list(stores.values_list('id', flat=True))
        beacons = list(Beacon.objects.filter(
            mall=mall, floor_id=floor_id,
            store_id__in=store_ids_on_floor + [None]))
    counts = beacon_counts(mall.id, floor_id, start, end,
                          beacon_ids=[b.id for b in beacons])

    store_name_map = dict(Store.objects.filter(mall=mall).values_list('id', 'name'))
    for b in beacons:
        b.count = counts.get(b.id, 0)
        b.store_name = store_name_map.get(b.store_id, 'Gate') if b.store_id else 'Gate'
        if not b.store_id:  # gate hover tooltip
            b.tip = format_html('<b>Gate</b> · {} visitors<br>entrance beacon', b.count)

    # Each store carries a stacked bar mirroring the other view's grammar:
    # footfall = distance bands (near/mid/far), dwell = session buckets.
    stores = list(stores)
    for s in stores:  # footprint polygon points, "" → template draws the rect fallback
        s.points_str = ' '.join(f'{p[0]},{p[1]}' for p in s.shape) if s.shape else ''
    if view == 'footfall':
        # Each visitor counted once (by closest approach), so near+mid+far = unique.
        bandv = store_band_visitors(mall.id, start, end, store_ids=store_ids_on_floor)
        share = {r['store_id']: r['share'] for r in
                 store_engagement(mall.id, start, end, store_ids=store_ids_on_floor)}
        for s in stores:
            d = bandv.get(s.id) or {'near': 0, 'mid': 0, 'far': 0}
            s.bar_segments, s.bar_total = _stack_segments(
                [('near', d['near'], BAND_COLOR['near']),
                 ('mid', d['mid'], BAND_COLOR['mid']),
                 ('far', d['far'], BAND_COLOR['far'])])
            s.near_share = share.get(s.id)
            share_txt = format_html('<br>{}% of detections within 3m', s.near_share) if s.near_share is not None else ''
            s.tip = format_html('<b>{}</b> · {} visitor{}<br>near {} · mid {} · far {} (by closest approach){}',
                                s.name, s.bar_total, '' if s.bar_total == 1 else 's',
                                d['near'], d['mid'], d['far'], share_txt)
    elif view == 'focus':
        # Dwell time split by distance - where visitors spent time (close vs edge).
        bandt = store_dwell_by_band(mall.id, start, end, store_ids=store_ids_on_floor)
        for s in stores:
            d = bandt.get(s.id) or {'near': 0, 'mid': 0, 'far': 0}
            s.bar_segments, s.bar_total = _stack_segments(
                [('near', d['near'], BAND_COLOR['near']),
                 ('mid', d['mid'], BAND_COLOR['mid']),
                 ('far', d['far'], BAND_COLOR['far'])])
            tot = d['near'] + d['mid'] + d['far']
            s.focus_pct = round(100 * d['near'] / tot) if tot else 0
            if tot:
                mp, fp = round(100 * d['mid'] / tot), round(100 * d['far'] / tot)
                s.tip = format_html('<b>{}</b> · dwell time by distance<br>near {}% · mid {}% · far {}%<br>{}',
                                    s.name, s.focus_pct, mp, fp,
                                    'mostly at the counter' if s.focus_pct >= 50 else 'hovering at the edge')
            else:
                s.tip = format_html('<b>{}</b> · no dwell yet', s.name)
    else:  # dwell
        per_store = dwell_buckets_per_store(mall.id, start, end,
                                            store_ids=store_ids_on_floor)
        for s in stores:
            d = per_store.get(s.id) or {}
            s.bar_segments, s.bar_total = _stack_segments(
                [(n, d.get(n, 0), DOMINANT_COLOR[n]) for n in BUCKET_NAMES])
            s.tip = format_html('<b>{}</b> · {} sessions<br>glance {} · look {} · browse {} · linger {}',
                                s.name, s.bar_total, d.get('glance', 0), d.get('look', 0),
                                d.get('browse', 0), d.get('linger', 0))

    ranges = [('today', 'Today'), ('7d', '7 days'), ('30d', '30 days'), ('all', 'All')]
    current = next((f for f in floors if f.id == floor_id), None)
    board = current.space if current else {'w': 1000, 'h': 720, 'grid': 40, 'metered': False,
                                           'pad': 0, 'vbx': 0, 'vby': 0, 'vw': 1000, 'vh': 720}
    if current and current.outline:
        board['outline'] = ' '.join(f'{p[0]},{p[1]}' for p in current.outline)
    ctx = {'floors': floors, 'floor_id': floor_id, 'span': span, 'ranges': ranges,
           'view': view, 'stores': stores, 'beacons': beacons, 'board': board,
           'view_choices': [('footfall', 'Footfall'), ('dwell', 'Dwell'), ('focus', 'Focus')]}
    if request.headers.get('HX-Request'):
        return render(request, '_plan.html', ctx)
    return render(request, 'heatmap.html', ctx)


# ---- Campaigns (storekeeper own / admin all) ---------------------------------

@login_required
@keeper_only
def campaigns(request):
    stores = visible_stores(request.user)
    rows = (Campaign.objects.filter(store__in=stores)
            .select_related('store').order_by('-updated_at'))
    return render(request, 'campaigns.html', {'campaigns': rows, 'stores': stores})


@login_required
@keeper_only
def campaign_edit(request, store_id, pk=None):
    store = get_object_or_404(visible_stores(request.user), pk=store_id)
    inst = get_object_or_404(Campaign, pk=pk, store=store) if pk else None
    if request.method == 'POST':
        form = CampaignForm(request.POST, request.FILES, instance=inst, store=store)
        if form.is_valid():
            c = form.save(commit=False)
            c.store = store
            c.save()
            form.save_m2m()
            return redirect('campaigns')
    else:
        form = CampaignForm(instance=inst, store=store)
    return render(request, 'campaign_form.html', {'form': form, 'store': store, 'campaign': inst})


@login_required
@keeper_only
def campaign_delete(request, store_id, pk):
    store = get_object_or_404(visible_stores(request.user), pk=store_id)
    get_object_or_404(Campaign, pk=pk, store=store).delete()
    return redirect('campaigns')


# ---- Stores + Beacons (admin, click-to-place) --------------------------------

@login_required
@admin_only
def stores(request):
    mall = Mall.objects.first()
    return render(request, 'stores.html', {
        'stores': (Store.objects.filter(mall=mall).select_related('floor', 'keeper')
                   .annotate(beacon_n=Count('beacons'))),
        'floors': Floor.objects.filter(mall=mall)})


@login_required
@admin_only
def store_edit(request, pk=None):
    mall = Mall.objects.first()
    inst = get_object_or_404(Store, pk=pk) if pk else None
    if request.method == 'POST':
        form = StoreForm(request.POST, request.FILES, instance=inst)
        if form.is_valid():
            s = form.save(commit=False)
            s.mall = mall
            shape = form.cleaned_data['shape_json']
            if shape:  # footprint drawn → store it + anchor the label at its centroid
                s.shape = shape
                s.pos_x = round(sum(x for x, _ in shape) / len(shape))
                s.pos_y = round(sum(y for _, y in shape) / len(shape))
            s.save()
            # Store owns beacon assignment: claim checked, release the rest of ours.
            sel_ids = list(form.cleaned_data['beacons'].values_list('pk', flat=True))
            Beacon.objects.filter(store=s).exclude(pk__in=sel_ids).update(store=None)
            if sel_ids:
                Beacon.objects.filter(pk__in=sel_ids).update(store=s)
            return redirect('stores')
    else:
        form = StoreForm(instance=inst)
    return render(request, 'place_form.html', _place_ctx(mall, form, 'store', inst))


@login_required
@admin_only
def floors(request):
    mall = Mall.objects.first()
    return render(request, 'floors.html', {
        'floors': (Floor.objects.filter(mall=mall)
                   .annotate(store_n=Count('stores', distinct=True),
                             beacon_n=Count('beacons', distinct=True)))})


@login_required
@admin_only
def floor_edit(request, pk=None):
    mall = Mall.objects.first()
    inst = get_object_or_404(Floor, pk=pk, mall=mall) if pk else None
    if request.method == 'POST':
        form = FloorForm(request.POST, instance=inst)
        if form.is_valid():
            f = form.save(commit=False)
            f.mall = mall
            f.outline = form.cleaned_data['outline_json']
            f.save()
            return redirect('floors')
    else:
        form = FloorForm(instance=inst)
    return render(request, 'floor_form.html', {
        'form': form, 'obj': inst,
        'stores': Store.objects.filter(mall=mall, floor=inst) if inst else Store.objects.none()})


@login_required
@admin_only
def beacons(request):
    mall = Mall.objects.first()
    return render(request, 'beacons.html', {
        'beacons': Beacon.objects.filter(mall=mall).select_related('floor', 'store'),
        'floors': Floor.objects.filter(mall=mall)})


@login_required
@admin_only
def beacon_edit(request, pk=None):
    mall = Mall.objects.first()
    inst = get_object_or_404(Beacon, pk=pk) if pk else None
    if request.method == 'POST':
        form = BeaconForm(request.POST, instance=inst)
        if form.is_valid():
            b = form.save(commit=False)
            b.mall = mall
            b.save()
            return redirect('beacons')
    else:
        form = BeaconForm(instance=inst)
    return render(request, 'place_form.html', _place_ctx(mall, form, 'beacon', inst))


# ---- Admin first-run setup --------------------------------------------------

def setup(request):
    """One‑time admin account creation. Only works when no superuser exists yet."""
    if get_user_model().objects.filter(is_superuser=True).exists():
        return redirect('login')
    if request.method == 'POST':
        form = AdminSignupForm(request.POST)
        if form.is_valid():
            form.save()
            return redirect('login')
    else:
        form = AdminSignupForm()
    return render(request, 'setup.html', {'form': form})


# ---- Storekeeper signup + admin approval -------------------------------------

def signup(request):
    """Public storekeeper self-registration. Anonymous-only; lands inactive until
    an admin approves on the Keepers page."""
    if request.user.is_authenticated:
        return redirect('dashboard')
    if request.method == 'POST':
        form = SignupForm(request.POST)
        if form.is_valid():
            form.save()
            return render(request, 'signup.html', {'submitted': True})
    else:
        form = SignupForm()
    return render(request, 'signup.html', {'form': form})


@login_required
@admin_only
def keepers(request):
    qs = (get_user_model().objects.filter(is_superuser=False)
          .prefetch_related('stores').order_by('username'))
    return render(request, 'keepers.html', {
        'pending': [u for u in qs if not u.is_active],
        'active': [u for u in qs if u.is_active]})


@login_required
@admin_only
def keeper_action(request, pk, action):
    if request.method != 'POST':
        raise PermissionDenied
    user = get_object_or_404(get_user_model(), pk=pk, is_superuser=False)
    if action == 'approve':
        user.is_active = True
        user.save(update_fields=['is_active'])
    elif action == 'revoke':
        user.is_active = False
        user.save(update_fields=['is_active'])
    elif action == 'delete':
        user.delete()
    return redirect('keepers')
