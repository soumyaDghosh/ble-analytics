"""Simulate footfall by POSTing to the REAL /location/batch endpoint — exactly
like the phone does. No direct DB inserts, so the heatmap data is provably the
same shape and code path as live device data.

Requires the dev server running:
    uv run python manage.py runserver 0.0.0.0:8000
    uv run python manage.py seed_pings --devices 50 --days 7
"""
import hashlib
import json
import random
import urllib.request
from datetime import timedelta

from django.core.management.base import BaseCommand
from django.utils import timezone

from core.models import Beacon


class Command(BaseCommand):
    help = 'Simulate footfall via the real batch endpoint (like the phone).'

    def add_arguments(self, p):
        p.add_argument('--url', default='http://127.0.0.1:8000')
        p.add_argument('--days', type=int, default=7)
        p.add_argument('--devices', type=int, default=50)

    def handle(self, *args, **o):
        beacons = list(Beacon.objects.all())
        if not beacons:
            self.stderr.write('No beacons — run seed_config first.')
            return

        # A stable-ish popularity per beacon: gates and a lucky few draw crowds.
        weight = {b.id: (3.0 if b.store_id is None else 1.0) * random.uniform(0.6, 2.4)
                  for b in beacons}
        by_floor = {}
        for b in beacons:
            by_floor.setdefault(b.floor_id, []).append(b)

        now = timezone.now()
        total = 0
        for d in range(o['devices']):
            device_hash = hashlib.sha256(f'sim-{d}'.encode()).hexdigest()
            pings = []
            for day in range(o['days']):
                if random.random() < 0.45:
                    continue  # not every device visits every day
                pool = by_floor[random.choice(list(by_floor))]
                start = now - timedelta(days=day, hours=random.uniform(0, 10),
                                        minutes=random.uniform(0, 59))
                path = random.choices(pool, weights=[weight[b.id] for b in pool],
                                      k=random.randint(3, 7))
                t = start
                for b in path:
                    for _ in range(random.randint(2, 6)):
                        t += timedelta(seconds=random.randint(5, 90))
                        pings.append({'t': t.isoformat(), 'b': b.adv_id,
                                      'rssi': random.randint(-88, -55)})
            if pings:
                total += self._post(o['url'], device_hash, pings)

        self.stdout.write(self.style.SUCCESS(
            f'Seeded ~{total} pings from {o["devices"]} simulated devices via {o["url"]}'))

    def _post(self, url, device_hash, pings):
        body = json.dumps({'device_hash': device_hash, 'pings': pings, 'impressions': []}).encode()
        req = urllib.request.Request(url.rstrip('/') + '/api/v1/location/batch', data=body,
                                     headers={'Content-Type': 'application/json'}, method='POST')
        try:
            with urllib.request.urlopen(req, timeout=20) as r:
                return json.loads(r.read()).get('pings', 0)
        except Exception as e:  # noqa: BLE001
            self.stderr.write(f'POST failed: {e}')
            return 0
