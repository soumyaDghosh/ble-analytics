"""Dwell analytics - gaps-and-islands over (device_hash, store_id, time).

A "visit session" is consecutive pings from one device at one store with no
gap larger than 5 minutes. Session length = last_ping - first_ping. Single-
ping sessions (no second ping within 5min) count as length 0s = "glance" =
"walked past". This is the honest answer to "were they in the store or just
passing by" - measured from real timestamp gaps, not RSSI.

Pure Django ORM - we fetch ordered pings via LocationPing.objects.values()
and detect sessions by walking the ordered list, splitting on gaps > GAP_S.
At demo scale (a few thousand pings per time window) this is fast and keeps
the code plainly readable.
"""
from itertools import groupby
from operator import itemgetter

from .models import LocationPing

# Gap threshold (seconds). Two pings from the same (device, store) further
# apart than this start a new session.
GAP_S = 300

# Bucket cutoffs (seconds).
BUCKETS = [
    ('glance',  0,   15),
    ('look',    15,  60),
    ('browse',  60,  300),
    ('linger',  300, None),
]
BUCKET_NAMES = [b[0] for b in BUCKETS]

# Bucket → color, consistent with the heatmap ring palette.
# 4 distinct colors (cool → warm = walked past → stayed long):
DOMINANT_COLOR = {
    'glance': '#6BA8C9',   # light blue - walked past
    'look':   '#0E7C66',   # active-green - short
    'browse': '#E8A317',   # signal-amber - engaged
    'linger': '#C43D2E',   # alert-red - stayed long
}


def _bucket(sec):
    for name, lo, hi in BUCKETS:
        if hi is None and sec >= lo:
            return name
        if hi is not None and lo <= sec < hi:
            return name
    return 'glance'


def _session_qs(mall_id, start, end, fields, store_ids=None):
    """Ordered queryset for session detection. Caller passes the exact fields
    it wants via `fields`. Returns a materialized list ready for Python-side
    gaps-and-islands iteration - no raw SQL, no window functions."""
    qs = (LocationPing.objects
          .filter(mall_id=mall_id, store_id__isnull=False,
                  time__gte=start, time__lt=end))
    if store_ids is not None:
        if not store_ids:
            return []
        qs = qs.filter(store_id__in=store_ids)
    rows = (qs.values(*fields)
              .order_by('device_hash', 'store_id', 'time'))
    return list(rows)


def _session_splits(group):
    """Yield (start_idx, end_idx_inclusive) pairs for sessions within an
    ordered (by time) group. Splits whenever two consecutive pings are
    more than GAP_S seconds apart."""
    sub_start = 0
    for i in range(1, len(group)):
        prev_t = group[i - 1]['time']
        t = group[i]['time']
        if (t - prev_t).total_seconds() > GAP_S:
            yield (sub_start, i - 1)
            sub_start = i
    yield (sub_start, len(group) - 1)


def dwell_sessions(mall_id, start, end, store_ids=None):
    """Yield sessions {'device','store_id','start','end','len_s','bucket','ping_count'}.
    Only store-beacon pings (gate pings, store_id=None, excluded) qualify.
    Optional store_ids=[..] restricts to a set of stores. A generator so callers
    stream sessions without materialising a second full list."""
    rows = _session_qs(mall_id, start, end,
                       ['device_hash', 'store_id', 'time'], store_ids=store_ids)
    for (dev, store), group_iter in groupby(rows, key=itemgetter('device_hash', 'store_id')):
        group = list(group_iter)
        for s_i, e_i in _session_splits(group):
            s_start, s_end = group[s_i]['time'], group[e_i]['time']
            sec = int((s_end - s_start).total_seconds())
            yield {'device': dev, 'store_id': store, 'start': s_start, 'end': s_end,
                   'ping_count': e_i - s_i + 1, 'len_s': sec, 'bucket': _bucket(sec)}


def dwell_stats(mall_id, start, end, store_ids=None):
    """Bucket counts + average session length, in one pass. Returns
    {'totals': {bucket: count}, 'total_sessions': int, 'avg_s': int}. Powers the
    overview 'Dwell today' card (headline avg stay + the distribution)."""
    totals = {name: 0 for name in BUCKET_NAMES}
    total_len = n = 0
    for s in dwell_sessions(mall_id, start, end, store_ids):
        totals[s['bucket']] += 1
        total_len += s['len_s']
        n += 1
    return {'totals': totals, 'total_sessions': n,
            'avg_s': int(total_len / n) if n else 0}


def dwell_buckets_per_store(mall_id, start, end, store_ids=None):
    """Per-store dwell mix. Returns {store_id: {glance,look,browse,linger,total}}
    - the real distribution of session lengths, so the map can show a stacked
    mix bar instead of a single collapsed 'dominant' colour."""
    out = {}
    for s in dwell_sessions(mall_id, start, end, store_ids):
        d = out.setdefault(s['store_id'],
                           {n: 0 for n in BUCKET_NAMES} | {'total': 0})
        d[s['bucket']] += 1
        d['total'] += 1
    return out