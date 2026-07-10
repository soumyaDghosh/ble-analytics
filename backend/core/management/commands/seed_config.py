from datetime import timedelta

from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand
from django.utils import timezone

from core.models import Beacon, Campaign, CacheVersion, Floor, Mall, Store

# Floor-plan coordinate space. Day-3 floor-plan images use this same viewBox.
W, H = 1000, 720

# (name, slug, category, floor_number, x, y, tagline, badge)
# slug -> media/stores/<slug>.jpg storefront photo; tagline+badge = Swiggy/Zomato-style hook shown on the card.
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

# A few real (non-rectangular) footprints so the demo shows arbitrary shapes;
# every other store falls back to the default box. Absolute board coordinates.
SHAPES = {
    'Nike':      [[236, 134], [364, 134], [364, 180], [300, 180], [300, 226], [236, 226]],  # L-shaped unit
    'Starbucks': [[520, 74], [566, 108], [548, 162], [492, 162], [474, 108]],               # pentagon kiosk
    'Apple':     [[740, 460], [770, 408], [830, 408], [860, 460], [830, 512], [770, 512]],   # hexagon flagship
}


class Command(BaseCommand):
    help = 'Reset demo config: one mall, floors, stores, beacons, campaigns, users.'

    def handle(self, *args, **opts):
        User = get_user_model()
        Mall.objects.all().delete()            # cascade wipes everything below it
        User.objects.filter(username__in=['admin', 'nike']).delete()

        # Pin id=1 so the app's hardcoded mall_id (single-mall MVP) always resolves.
        mall = Mall.objects.create(id=1, name='City Center Mall', address='MG Road')
        # 50x36 m keeps the historic 1000x720 board space (ppm=20 → 1 m = 20 px grid).
        ground = Floor.objects.create(mall=mall, number=0, name='Ground Floor', width_m=50, height_m=36)
        first = Floor.objects.create(mall=mall, number=1, name='First Floor', width_m=50, height_m=36)
        floors = {0: ground, 1: first}

        admin = User.objects.create_superuser('admin', password='admin12345')
        keeper = User.objects.create_user('nike', password='keeper12345')

        n = 1  # beacon adv_id counter (6 bytes -> 12 hex chars)

        def adv():
            nonlocal n
            v = f'{n:012X}'
            n += 1
            return v

        # Gate beacon (store=None) near the ground-floor entrance.
        Beacon.objects.create(mall=mall, floor=ground, adv_id=adv(),
                              beacon_type=Beacon.GATE, pos_x=120, pos_y=650, tx_power=-59)

        stores = {}
        for name, slug, cat, fno, x, y, tagline, badge in STORES:
            floor = floors[fno]
            store = Store.objects.create(mall=mall, floor=floor, name=name, category=cat,
                                         image=f'stores/{slug}.jpg', tagline=tagline, badge=badge,
                                         pos_x=x, pos_y=y, shape=SHAPES.get(name),
                                         keeper=keeper if name == 'Nike' else None)
            Beacon.objects.create(mall=mall, floor=floor, store=store, adv_id=adv(),
                                  beacon_type=Beacon.STORE, pos_x=x - 5, pos_y=y - 5, tx_power=-59)
            stores[name] = store

        # Nike gets a second beacon — shows multi-beacon-per-store on the dashboard.
        Beacon.objects.create(mall=mall, floor=ground, store=stores['Nike'], adv_id=adv(),
                              beacon_type=Beacon.STORE, pos_x=280, pos_y=210, tx_power=-59)

        now = timezone.now()
        for store_name, title, body, coupon in [
            ('Nike', '10% Off Sneakers', 'Show this at the counter for 10% off any pair.', 'NIKE10'),
            ('Starbucks', 'Free Cookie', 'Buy any grande, get a cookie free today.', 'BREWFREE'),
        ]:
            store = stores[store_name]
            c = Campaign.objects.create(
                store=store, title=title, body=body, coupon=coupon,
                starts_at=now - timedelta(days=1), ends_at=now + timedelta(days=14),
                status=Campaign.ACTIVE)
            c.target_beacons.set(store.beacons.all())  # defaults to store's own beacons

        CacheVersion.objects.create(mall=mall, version=1)

        self.stdout.write(self.style.SUCCESS(
            f'Seeded "{mall.name}": {Store.objects.count()} stores, '
            f'{Beacon.objects.count()} beacons, {Campaign.objects.count()} campaigns.'))
        self.stdout.write('  admin / admin12345  (superuser)')
        self.stdout.write('  nike  / keeper12345  (storekeeper → Nike)')
