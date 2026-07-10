"""Single-command demo seeder: config + realistic phone-format footfall.

Seeds the same config as seed_config (mall, floors, stores, beacons, campaigns,
users, cache) and then generates realistic LocationPing + CampaignImpression
rows using direct ORM inserts — no running server required.

Pings mimic exactly what a phone POSTs to /api/v1/location/batch:
  - 64-char SHA-256 device hashes
  - 12-char zero-padded hex beacon adv_ids
  - ISO 8601 timestamps with microsecond precision, Z suffix
  - Realistic RSSI profiles: approach ramp → dwell oscillation → leave ramp
  - 3-10 second scan intervals, cross-hearing nearby beacons
  - Walking paths: gate entry → stores → gate exit
  - Campaign impressions on campaign-targeted store visits

Usage:
    uv run python manage.py seed_demo                    # full reset + 30 devices
    uv run python manage.py seed_demo --devices 100      # 100 devices
    uv run python manage.py seed_demo --hours 48         # spread across 48h
    uv run python manage.py seed_demo --footfall-only    # add footfall to existing config
"""
import hashlib
import math
import random
from datetime import timedelta

from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand
from django.utils import timezone

from core.models import (
    Beacon, Campaign, CampaignImpression, CacheVersion, Floor, LocationPing,
    Mall, Store,
)

# ▸▸▸ Config constants — identical to seed_config.py ▸▸▸▸▸▸▸▸▸▸▸▸▸▸▸▸▸▸▸▸▸▸

W, H = 1000, 720

STORES = [
    ('Nike', 'nike', 'Sportswear', 0, 300, 180, 'Just do it — new drops in', 'OFFER'),
    ('Starbucks', 'starbucks', 'Cafe', 0, 520, 120, 'Handcrafted coffee & bites', 'FREE'),
    ('Zara', 'zara', 'Fashion', 0, 720, 200, 'New season arrivals', 'NEW'),
    ('Apple', 'apple', 'Electronics', 0, 800, 460, 'Latest iPhone, Mac & more', ''),
    ('Sephora', 'sephora', 'Beauty', 0, 480, 520, 'Beauty, skincare & fragrance', ''),
    ('H&M', 'hm', 'Fashion', 1, 260, 200, 'Fashion for the whole family', 'SALE'),
    ("Levi's", 'levis', 'Fashion', 1, 500, 160, 'Original jeans since 1873', ''),
    ('Croma', 'croma', 'Electronics', 1, 760, 240, 'Electronics megastore', ''),
    ('KFC', 'kfc', 'Food', 1, 700, 520, "Finger lickin' good", ''),
    ('Lifestyle', 'lifestyle', 'Department', 1, 320, 500, 'Everything under one roof', ''),
]

SHAPES = {
    'Nike':      [[236, 134], [364, 134], [364, 180], [300, 180], [300, 226], [236, 226]],
    'Starbucks': [[520, 74], [566, 108], [548, 162], [492, 162], [474, 108]],
    'Apple':     [[740, 460], [770, 408], [830, 408], [860, 460], [830, 512], [770, 512]],
}

# Footfall constants

PATHS = [
    ['Sephora', 'Nike'],
    ['Nike', 'Starbucks'],
    ['Zara', 'Apple'],
    ['Starbucks', 'Zara', 'Apple'],
    ['Sephora', 'Zara'],
    ['Nike', 'Sephora'],
    ['Starbucks'],
    ['Zara'],
    ['Apple'],
    ['Nike', 'Starbucks', 'Zara'],
    [],
    [],
    [],
]

HOURLY_WEIGHTS = {
    0: 0.015, 1: 0.015, 2: 0.01, 3: 0.01, 4: 0.01, 5: 0.015, 6: 0.02,
    7: 0.03, 8: 0.04, 9: 0.06, 10: 0.07,
    11: 0.10, 12: 0.10, 13: 0.10,
    14: 0.06, 15: 0.06, 16: 0.06,
    17: 0.10, 18: 0.10, 19: 0.10,
    20: 0.05, 21: 0.04, 22: 0.03, 23: 0.02,
}

TX_POWER = -59
CROSS_HEAR_CHANCE = 0.30
IMPRESSION_OPEN_RATE = 0.30


def _device_hash(index):
    return hashlib.sha256(f'demo-{index:04d}'.encode()).hexdigest()


def _rssi_clamp(v):
    return max(-90, min(-40, round(v)))


def _est_distance(rssi):
    return 10 ** ((TX_POWER - rssi) / 20.0)


def _rssi_ramp(start_db, end_db, n):
    if n <= 1:
        return [_rssi_clamp((start_db + end_db) / 2 + random.gauss(0, 2))]
    vals = []
    for i in range(n):
        base = start_db + (end_db - start_db) * i / (n - 1)
        vals.append(_rssi_clamp(base + random.gauss(0, 2)))
    return vals


def _rssi_oscillate(start_db, n):
    vals = []
    cur = start_db
    for _ in range(n):
        cur = _rssi_clamp(cur + random.gauss(0, 2))
        vals.append(cur)
    return vals


def _scan_times(start_dt, duration_sec, count):
    if count <= 1:
        return [start_dt + timedelta(seconds=duration_sec / 2)]
    times = []
    for i in range(count):
        ideal = start_dt + timedelta(seconds=duration_sec * i / (count - 1))
        jitter = duration_sec / count * random.uniform(-0.3, 0.3)
        t = ideal + timedelta(seconds=jitter)
        if times and t <= times[-1]:
            t = times[-1] + timedelta(milliseconds=random.randint(500, 1500))
        times.append(t)
    return times


def seed_config():
    """Phase 1: seed mall, floors, stores, beacons, campaigns, users, cache."""
    User = get_user_model()
    Mall.objects.all().delete()
    User.objects.filter(username__in=['admin', 'nike']).delete()

    mall = Mall.objects.create(id=1, name='City Center Mall', address='MG Road')
    ground = Floor.objects.create(mall=mall, number=0, name='Ground Floor',
                                  width_m=50, height_m=36)
    first = Floor.objects.create(mall=mall, number=1, name='First Floor',
                                 width_m=50, height_m=36)
    floors = {0: ground, 1: first}

    User.objects.create_superuser('admin', password='admin12345')
    keeper = User.objects.create_user('nike', password='keeper12345')

    n = 1

    def adv():
        nonlocal n
        v = f'{n:012X}'
        n += 1
        return v

    gate = Beacon.objects.create(mall=mall, floor=ground, adv_id=adv(),
                                 beacon_type=Beacon.GATE, pos_x=120, pos_y=650,
                                 tx_power=TX_POWER)

    stores_by_name = {}
    beacons_by_adv_id = {gate.adv_id: gate}

    for name, slug, cat, fno, x, y, tagline, badge in STORES:
        floor = floors[fno]
        store = Store.objects.create(
            mall=mall, floor=floor, name=name, category=cat,
            image=f'stores/{slug}.jpg', tagline=tagline, badge=badge,
            pos_x=x, pos_y=y, shape=SHAPES.get(name),
            keeper=keeper if name == 'Nike' else None)
        b = Beacon.objects.create(mall=mall, floor=floor, store=store, adv_id=adv(),
                                  beacon_type=Beacon.STORE, pos_x=x - 5, pos_y=y - 5,
                                  tx_power=TX_POWER)
        stores_by_name[name] = store
        beacons_by_adv_id[b.adv_id] = b

    b2 = Beacon.objects.create(mall=mall, floor=ground, store=stores_by_name['Nike'],
                               adv_id=adv(), beacon_type=Beacon.STORE,
                               pos_x=280, pos_y=210, tx_power=TX_POWER)
    beacons_by_adv_id[b2.adv_id] = b2

    now = timezone.now()
    campaigns = []
    for store_name, title, body, coupon in [
        ('Nike', '10% Off Sneakers', 'Show this at the counter for 10% off any pair.', 'NIKE10'),
        ('Starbucks', 'Free Cookie', 'Buy any grande, get a cookie free today.', 'BREWFREE'),
    ]:
        store = stores_by_name[store_name]
        c = Campaign.objects.create(
            store=store, title=title, body=body, coupon=coupon,
            starts_at=now - timedelta(days=1), ends_at=now + timedelta(days=14),
            status=Campaign.ACTIVE)
        c.target_beacons.set(store.beacons.all())
        campaigns.append(c)

    CacheVersion.objects.create(mall=mall, version=1)

    return {
        'mall': mall,
        'gate': gate,
        'stores_by_name': stores_by_name,
        'beacons_by_adv_id': beacons_by_adv_id,
        'campaigns': campaigns,
        'ground_beacons': list(Beacon.objects.filter(floor=ground)),
    }


def _pick_hour(now, hours_ago):
    hours = list(HOURLY_WEIGHTS.keys())
    weights = [HOURLY_WEIGHTS[h] for h in hours]
    chosen_hour = random.choices(hours, weights=weights, k=1)[0]
    hour_offset = hours_ago - 1 - (now.hour - chosen_hour) % hours_ago
    if hour_offset < 0:
        hour_offset += hours_ago
    start_hour = now - timedelta(hours=hour_offset,
                                 minutes=random.randint(0, 59),
                                 seconds=random.randint(0, 59))
    earliest = now - timedelta(hours=hours_ago)
    return max(start_hour, earliest)


def _nearby_stores(store_name, stores_by_name, ground_beacons):
    store = stores_by_name[store_name]
    nearby_adv_ids = []
    for b in ground_beacons:
        if b.store and b.store.name != store_name:
            dx = b.pos_x - store.pos_x
            dy = b.pos_y - store.pos_y
            if math.hypot(dx, dy) < 200:
                nearby_adv_ids.append(b.adv_id)
    return nearby_adv_ids


def generate_device_pings(device_hash, path, stores_by_name, beacons_by_adv_id,
                          gate, ground_beacons, now, hours_ago):
    start_dt = _pick_hour(now, hours_ago)
    pings = []
    t = start_dt
    visited_stores = set()

    # Gate entry
    entry_pings_n = random.randint(3, 5)
    entry_rssi = _rssi_ramp(-80, -58, entry_pings_n)
    entry_times = _scan_times(t, random.uniform(15, 45), entry_pings_n)
    for r, ts in zip(entry_rssi, entry_times):
        pings.append({'t': ts, 'b': gate.adv_id, 'rssi': r})
    t = entry_times[-1] + timedelta(seconds=random.uniform(5, 20))

    if not path:
        mid_n = random.randint(2, 4)
        mid_rssi = _rssi_oscillate(-60, mid_n)
        mid_times = _scan_times(t, random.uniform(10, 30), mid_n)
        for r, ts in zip(mid_rssi, mid_times):
            pings.append({'t': ts, 'b': gate.adv_id, 'rssi': r})
        t = mid_times[-1] + timedelta(seconds=random.uniform(5, 20))
        exit_n = random.randint(2, 4)
        exit_rssi = _rssi_ramp(-58, -82, exit_n)
        exit_times = _scan_times(t, random.uniform(10, 30), exit_n)
        for r, ts in zip(exit_rssi, exit_times):
            pings.append({'t': ts, 'b': gate.adv_id, 'rssi': r})
        return pings, visited_stores

    for idx, store_name in enumerate(path):
        store = stores_by_name[store_name]
        store_beacons = [b.adv_id for b in store.beacons.all()]
        main_beacon = store_beacons[0]
        visited_stores.add(store_name)
        nearby = _nearby_stores(store_name, stores_by_name, ground_beacons)

        # Approach
        approach_n = random.randint(4, 8)
        approach_rssi = _rssi_ramp(
            random.uniform(-85, -78),
            random.uniform(-60, -53),
            approach_n)
        approach_dur = random.uniform(30, 120)
        approach_times = _scan_times(t, approach_dur, approach_n)
        for r, ts in zip(approach_rssi, approach_times):
            pings.append({'t': ts, 'b': main_beacon, 'rssi': r})
        t = approach_times[-1] + timedelta(seconds=random.uniform(1, 3))

        # Dwell
        dwell_dur = random.uniform(30, 300)
        avg_interval = random.uniform(3, 10)
        dwell_n = max(1, int(dwell_dur / avg_interval))
        dwell_rssi = _rssi_oscillate(random.randint(-65, -55), dwell_n)
        dwell_times = _scan_times(t, dwell_dur, dwell_n)
        for r, ts in zip(dwell_rssi, dwell_times):
            pings.append({'t': ts, 'b': main_beacon, 'rssi': r})
            if nearby and random.random() < CROSS_HEAR_CHANCE:
                cross_b = random.choice(nearby)
                cross_rssi = _rssi_clamp(random.uniform(-88, -75))
                pings.append({'t': ts + timedelta(milliseconds=random.randint(100, 500)),
                              'b': cross_b, 'rssi': cross_rssi})
            alt_beacons = [b for b in store_beacons if b != main_beacon]
            if alt_beacons and random.random() < 0.40:
                alt_b = random.choice(alt_beacons)
                alt_rssi = _rssi_clamp(random.uniform(-70, -55))
                pings.append({'t': ts + timedelta(milliseconds=random.randint(100, 500)),
                              'b': alt_b, 'rssi': alt_rssi})
        t = dwell_times[-1] + timedelta(seconds=random.uniform(1, 3))

        # Leave
        leave_n = random.randint(3, 6)
        leave_rssi = _rssi_ramp(
            random.uniform(-60, -53),
            random.uniform(-85, -78),
            leave_n)
        leave_dur = random.uniform(20, 60)
        leave_times = _scan_times(t, leave_dur, leave_n)
        for r, ts in zip(leave_rssi, leave_times):
            pings.append({'t': ts, 'b': main_beacon, 'rssi': r})
        t = leave_times[-1]

        # Transition to next store
        if idx < len(path) - 1:
            trans_n = random.randint(1, 3)
            trans_rssi = [_rssi_clamp(random.uniform(-85, -70)) for _ in range(trans_n)]
            trans_dur = random.uniform(10, 60)
            trans_times = _scan_times(t, trans_dur, trans_n)
            for r, ts in zip(trans_rssi, trans_times):
                pings.append({'t': ts, 'b': gate.adv_id, 'rssi': r})
            t = trans_times[-1] + timedelta(seconds=random.uniform(5, 15))

    # Gate exit
    exit_n = random.randint(2, 4)
    exit_rssi = _rssi_ramp(-78, -85, exit_n)
    exit_times = _scan_times(t, random.uniform(10, 30), exit_n)
    for r, ts in zip(exit_rssi, exit_times):
        pings.append({'t': ts, 'b': gate.adv_id, 'rssi': r})

    return pings, visited_stores


def seed_footfall(ctx, num_devices, hours_ago):
    now = timezone.now()
    beacons_by_adv_id = ctx['beacons_by_adv_id']
    stores_by_name = ctx['stores_by_name']
    gate = ctx['gate']
    ground_beacons = ctx['ground_beacons']
    campaigns = ctx['campaigns']

    camp_by_store = {c.store.name: c for c in campaigns}

    all_location_pings = []
    all_impressions = []

    for i in range(num_devices):
        device_hash = _device_hash(i)
        path = random.choice(PATHS)
        raw_pings, visited_stores = generate_device_pings(
            device_hash, path, stores_by_name, beacons_by_adv_id,
            gate, ground_beacons, now, hours_ago)

        for p in raw_pings:
            beacon = beacons_by_adv_id.get(p['b'])
            if beacon is None:
                continue
            all_location_pings.append(LocationPing(
                time=p['t'],
                device_hash=device_hash,
                beacon=beacon,
                store_id=beacon.store_id,
                mall_id=beacon.mall_id,
                rssi=p['rssi'],
                est_distance=_est_distance(p['rssi']),
            ))

        for store_name in visited_stores:
            if store_name in camp_by_store:
                store_adv_ids = {b.adv_id for b in stores_by_name[store_name].beacons.all()}
                store_pings = [rp for rp in raw_pings if rp['b'] in store_adv_ids]
                if store_pings:
                    mid = store_pings[len(store_pings) // 2]
                    all_impressions.append(CampaignImpression(
                        campaign=camp_by_store[store_name],
                        device_hash=device_hash,
                        triggered_at=mid['t'],
                        delivered=True,
                        opened=random.random() < IMPRESSION_OPEN_RATE,
                    ))

    LocationPing.objects.bulk_create(all_location_pings, ignore_conflicts=True, batch_size=2000)
    CampaignImpression.objects.bulk_create(all_impressions, batch_size=500)

    return len(all_location_pings), len(all_impressions)


class Command(BaseCommand):
    help = 'Seed demo config + realistic phone-format footfall in one command.'

    def add_arguments(self, parser):
        parser.add_argument('--devices', type=int, default=30,
                            help='Number of simulated devices (default 30)')
        parser.add_argument('--hours', type=int, default=24,
                            help='Spread visits across last N hours (default 24)')
        parser.add_argument('--footfall-only', action='store_true',
                            help='Skip config phase, only add footfall data')

    def handle(self, *args, **options):
        num_devices = options['devices']
        hours_ago = options['hours']
        footfall_only = options['footfall_only']

        if not footfall_only:
            self.stdout.write('Phase 1: Seeding config...')
            ctx = seed_config()
            self.stdout.write(self.style.SUCCESS(
                f'  {Store.objects.count()} stores, {Beacon.objects.count()} beacons, '
                f'{Campaign.objects.count()} campaigns.'))
        else:
            mall = Mall.objects.first()
            if not mall:
                self.stderr.write('No config found — run without --footfall-only first.')
                return
            gate = Beacon.objects.filter(store__isnull=True).first()
            stores_by_name = {s.name: s for s in Store.objects.all()}
            beacons_by_adv_id = {b.adv_id: b for b in Beacon.objects.all()}
            campaigns = list(Campaign.objects.filter(status=Campaign.ACTIVE))
            ground_beacons = list(Beacon.objects.filter(floor__number=0))
            ctx = {
                'mall': mall, 'gate': gate,
                'stores_by_name': stores_by_name,
                'beacons_by_adv_id': beacons_by_adv_id,
                'campaigns': campaigns,
                'ground_beacons': ground_beacons,
            }

        self.stdout.write(f'Phase 2: Generating footfall ({num_devices} devices, '
                          f'last {hours_ago}h)...')
        pings_n, impr_n = seed_footfall(ctx, num_devices, hours_ago)

        self.stdout.write(self.style.SUCCESS(
            f'Done! {pings_n} pings, {impr_n} campaign impressions.'))
        self.stdout.write('  admin / admin12345  (superuser)')
        self.stdout.write('  nike  / keeper12345  (storekeeper → Nike)')
