from django.conf import settings
from django.db import models

# Coordinates are pixel positions on Floor.plan_image (PRD §3.3). No GPS.
# FileField (not ImageField) keeps us off the Pillow dependency - the browser
# renders the plan and overlays the heatmap; no server-side image work needed.


class Mall(models.Model):
    name = models.CharField(max_length=120)
    address = models.CharField(max_length=255, blank=True)

    def __str__(self):
        return self.name


class Floor(models.Model):
    mall = models.ForeignKey(Mall, on_delete=models.CASCADE, related_name='floors')
    number = models.IntegerField()
    name = models.CharField(max_length=80)
    plan_image = models.FileField(upload_to='floors/', blank=True)
    # Real-world floor size in metres (admin-set on the graph-paper editor). Null →
    # legacy floor: the old fixed 1000x720 board space. When set, the board space is
    # normalised so the longer side = 1000 units and one grid square = one metre.
    width_m = models.FloatField(null=True, blank=True)
    height_m = models.FloatField(null=True, blank=True)
    # Mall/floor boundary polygon in board px space (same as Store.shape). Null →
    # the board draws the default rectangular frame.
    outline = models.JSONField(null=True, blank=True)

    class Meta:
        ordering = ['number']

    def __str__(self):
        return f'{self.mall.name} · {self.name}'

    # Fixed px-per-metre. Whole so every 0.25 m lands on an integer pixel - grid
    # metrics stay clean (no 1.99 m). Seed floors were 50 m wide → this keeps their
    # old 1000-px width byte-identical. vb* = viewBox with a metre of breathing room
    # so a boundary curved past the nominal rectangle isn't clipped.
    PPM = 20

    @property
    def space(self):
        """Board coordinate space: {w, h, ppm, grid, metered, pad, vbx/vby/vw/vh}.
        All store/beacon/outline coords live in this px space (1 grid square = 1 m).
        Legacy floors (no width/height) keep the old 1000x720 px space."""
        if self.width_m and self.height_m:
            w, h = round(self.width_m * self.PPM), round(self.height_m * self.PPM)
            pad = max(2, round(0.1 * max(self.width_m, self.height_m))) * self.PPM
            return {'w': w, 'h': h, 'ppm': self.PPM, 'grid': self.PPM, 'metered': True,
                    'pad': pad, 'vbx': -pad, 'vby': -pad, 'vw': w + 2 * pad, 'vh': h + 2 * pad}
        return {'w': 1000, 'h': 720, 'ppm': self.PPM, 'grid': 40,
                'metered': False, 'pad': 0, 'vbx': 0, 'vby': 0, 'vw': 1000, 'vh': 720}


class Store(models.Model):
    mall = models.ForeignKey(Mall, on_delete=models.CASCADE, related_name='stores')
    floor = models.ForeignKey(Floor, on_delete=models.CASCADE, related_name='stores')
    name = models.CharField(max_length=120)
    category = models.CharField(max_length=60)
    image = models.FileField(upload_to='stores/', blank=True)   # storefront photo for the app card
    tagline = models.CharField(max_length=80, blank=True)        # one-line hook under the name
    badge = models.CharField(max_length=16, blank=True)          # short chip, e.g. OFFER / NEW
    pos_x = models.IntegerField(default=0)  # label anchor - auto-set to shape centroid
    pos_y = models.IntegerField(default=0)
    # Footprint polygon on the 1000x720 board: [[x, y], ...]. Null → the old
    # fixed 128x92 box at pos_x/pos_y (back-compat). A store is an area, not a point.
    shape = models.JSONField(null=True, blank=True)
    keeper = models.ForeignKey(settings.AUTH_USER_MODEL, null=True, blank=True,
                               on_delete=models.SET_NULL, related_name='stores')

    def __str__(self):
        return self.name


class Beacon(models.Model):
    GATE, STORE, COMMON = 'gate', 'store', 'common'
    TYPES = [(GATE, 'Gate'), (STORE, 'Store'), (COMMON, 'Common')]

    mall = models.ForeignKey(Mall, on_delete=models.CASCADE, related_name='beacons')
    floor = models.ForeignKey(Floor, on_delete=models.CASCADE, related_name='beacons')
    store = models.ForeignKey(Store, null=True, blank=True, on_delete=models.SET_NULL,
                              related_name='beacons')
    adv_id = models.CharField(max_length=12, unique=True)  # 6 bytes as hex; advertised + matched
    beacon_type = models.CharField(max_length=8, choices=TYPES, default=COMMON)  # admin-only, not synced
    pos_x = models.IntegerField(default=0)
    pos_y = models.IntegerField(default=0)
    tx_power = models.IntegerField(default=-59)  # calibrated RSSI @ 1m

    def __str__(self):
        return self.adv_id


class Campaign(models.Model):
    DRAFT, ACTIVE, PAUSED, COMPLETED = 'draft', 'active', 'paused', 'completed'
    STATUSES = [(DRAFT, 'Draft'), (ACTIVE, 'Active'), (PAUSED, 'Paused'), (COMPLETED, 'Completed')]

    store = models.ForeignKey(Store, on_delete=models.CASCADE, related_name='campaigns')
    title = models.CharField(max_length=120)
    body = models.CharField(max_length=255)
    image = models.FileField(upload_to='campaigns/', blank=True)
    coupon = models.CharField(max_length=40, blank=True)
    discount = models.CharField(max_length=40, blank=True)
    starts_at = models.DateTimeField()
    ends_at = models.DateTimeField()
    status = models.CharField(max_length=10, choices=STATUSES, default=DRAFT)
    target_beacons = models.ManyToManyField(Beacon, related_name='campaigns', blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.title


class LocationPing(models.Model):
    time = models.DateTimeField()
    device_hash = models.CharField(max_length=64)
    beacon = models.ForeignKey(Beacon, on_delete=models.CASCADE, related_name='pings')
    store_id = models.IntegerField(null=True)  # denormalized: per-store footfall without a join
    mall_id = models.IntegerField()
    rssi = models.IntegerField()
    est_distance = models.FloatField()

    class Meta:
        indexes = [models.Index(fields=['mall_id', 'time'])]
        # dedup + idempotent re-seeding: same device at same beacon at same instant = one row
        constraints = [
            models.UniqueConstraint(fields=['device_hash', 'beacon', 'time'], name='uniq_ping'),
        ]


class CampaignImpression(models.Model):
    campaign = models.ForeignKey(Campaign, on_delete=models.CASCADE, related_name='impressions')
    device_hash = models.CharField(max_length=64)
    triggered_at = models.DateTimeField()
    delivered = models.BooleanField(default=True)
    opened = models.BooleanField(default=False)


class CacheVersion(models.Model):
    mall = models.OneToOneField(Mall, on_delete=models.CASCADE, related_name='cache_version')
    version = models.PositiveIntegerField(default=1)
    updated_at = models.DateTimeField(auto_now=True)
