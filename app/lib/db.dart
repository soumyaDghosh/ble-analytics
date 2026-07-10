import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'config.dart';

part 'db.g.dart';

// ---- Tables (ids come from the server, so no autoIncrement on cached rows) ----

class Floors extends Table {
  IntColumn get id => integer()();
  IntColumn get number => integer()();
  TextColumn get name => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class Stores extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  IntColumn get floorId => integer()();
  IntColumn get x => integer()();
  IntColumn get y => integer()();
  TextColumn get image => text().nullable()();                    // absolute URL from /data/sync
  TextColumn get tagline => text().withDefault(const Constant(''))();
  TextColumn get badge => text().withDefault(const Constant(''))();
  @override
  Set<Column> get primaryKey => {id};
}

class Beacons extends Table {
  TextColumn get advId => text()();
  IntColumn get storeId => integer().nullable()();
  IntColumn get mallId => integer()();
  IntColumn get floorId => integer()();
  IntColumn get tx => integer()();
  IntColumn get x => integer()();
  IntColumn get y => integer()();
  @override
  Set<Column> get primaryKey => {advId};
}

class Campaigns extends Table {
  IntColumn get id => integer()();
  IntColumn get storeId => integer()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get coupon => text().withDefault(const Constant(''))();
  TextColumn get starts => text()();
  TextColumn get ends => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class CampaignBeacons extends Table {
  IntColumn get campaignId => integer()();
  TextColumn get advId => text()();
}

// ---- Outbox + local state ----

class Pings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get t => text()();
  TextColumn get advId => text()();
  IntColumn get rssi => integer()();
}

class Impressions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get campaignId => integer()();
  TextColumn get t => text()();
  BoolColumn get opened => boolean().withDefault(const Constant(false))();
}

class Dedup extends Table {
  IntColumn get campaignId => integer()();
  TextColumn get lastFired => text()();
  @override
  Set<Column> get primaryKey => {campaignId};
}

class Visited extends Table {
  IntColumn get storeId => integer()();
  TextColumn get at => text()();
  @override
  Set<Column> get primaryKey => {storeId};
}

class Meta extends Table {
  TextColumn get k => text()();
  TextColumn get v => text()();
  @override
  Set<Column> get primaryKey => {k};
}

@DriftDatabase(tables: [
  Floors, Stores, Beacons, Campaigns, CampaignBeacons,
  Pings, Impressions, Dedup, Visited, Meta,
])
class AppDb extends _$AppDb {
  AppDb([QueryExecutor? e]) : super(e ?? _open());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(stores, stores.image);
            await m.addColumn(stores, stores.tagline);
            await m.addColumn(stores, stores.badge);
          }
        },
      );

  static QueryExecutor _open() => driftDatabase(
        name: 'blemall',
        native: const DriftNativeOptions(databaseDirectory: getApplicationSupportDirectory),
      );

  // ---- reactive reads (UI just rebuilds on change) ----
  Stream<List<Floor>> watchFloors() =>
      (select(floors)..orderBy([(f) => OrderingTerm(expression: f.number)])).watch();

  Stream<List<Store>> watchStores({int? floorId, String? category}) {
    final q = select(stores)
      ..orderBy([(s) => OrderingTerm(expression: s.category), (s) => OrderingTerm(expression: s.name)]);
    if (floorId != null) q.where((s) => s.floorId.equals(floorId));
    if (category != null) q.where((s) => s.category.equals(category));
    return q.watch();
  }

  Stream<Set<int>> watchVisited() =>
      select(visited).watch().map((rows) => {for (final r in rows) r.storeId});

  Stream<int> watchPending() => customSelect('SELECT COUNT(*) AS c FROM pings', readsFrom: {pings})
      .map((r) => r.read<int>('c'))
      .watchSingle();

  Future<List<String>> categories() async {
    final q = selectOnly(stores, distinct: true)
      ..addColumns([stores.category])
      ..orderBy([OrderingTerm(expression: stores.category)]);
    return q.map((r) => r.read(stores.category)!).get();
  }

  Future<List<Campaign>> campaignsForStore(int storeId) =>
      (select(campaigns)..where((c) => c.storeId.equals(storeId))).get();

  Future<Store?> storeById(int id) =>
      (select(stores)..where((s) => s.id.equals(id))).getSingleOrNull();

  // ---- hot path (offline) ----
  Future<Beacon?> beacon(String advId) =>
      (select(beacons)..where((b) => b.advId.equals(advId))).getSingleOrNull();

  Future<List<Campaign>> matchCampaigns(String advId, int storeId, DateTime nowUtc) async {
    final rows = await (select(campaigns).join([
      innerJoin(campaignBeacons, campaignBeacons.campaignId.equalsExp(campaigns.id)),
    ])
          ..where(campaignBeacons.advId.equals(advId) & campaigns.storeId.equals(storeId)))
        .map((r) => r.readTable(campaigns))
        .get();
    return rows.where((c) {
      final s = DateTime.parse(c.starts), e = DateTime.parse(c.ends);
      return nowUtc.isAfter(s) && nowUtc.isBefore(e);
    }).toList();
  }

  // ---- meta / version ----
  Future<String?> getMeta(String k) async =>
      (await (select(meta)..where((m) => m.k.equals(k))).getSingleOrNull())?.v;

  Future<void> setMeta(String k, String v) =>
      into(meta).insertOnConflictUpdate(MetaCompanion.insert(k: k, v: v));

  Future<int?> version() async => int.tryParse(await getMeta('version') ?? '');

  // ---- cache replace (from /data/sync) ----
  Future<void> replaceCache(Map<String, dynamic> d) async {
    try {
      await transaction(() async {
      // single-int PK columns are Value-wrapped (rowid alias); nullable = Value too.
      await delete(campaignBeacons).go();
      await delete(campaigns).go();
      await delete(beacons).go();
      await delete(stores).go();
      await delete(floors).go();
      await batch((b) {
        b.insertAll(floors, [
          for (final f in d['floors'])
            FloorsCompanion.insert(id: Value(f['id']), number: f['number'], name: f['name'])
        ]);
        b.insertAll(stores, [
          for (final s in d['stores'])
            StoresCompanion.insert(
                id: Value(s['id']), name: s['name'], category: s['category'],
                floorId: s['floor_id'], x: s['x'], y: s['y'],
                image: Value(s['image']), tagline: Value(s['tagline'] ?? ''),
                badge: Value(s['badge'] ?? ''))
        ]);
        b.insertAll(beacons, [
          for (final x in d['beacons'])
            BeaconsCompanion.insert(
                advId: x['id'], mallId: mallId, floorId: x['floor_id'],
                tx: x['tx'], x: x['x'], y: x['y'], storeId: Value(x['store_id']))
        ]);
        for (final c in d['campaigns']) {
          b.insert(
              campaigns,
              CampaignsCompanion.insert(
                  id: Value(c['id']), storeId: c['store_id'], title: c['title'], body: c['body'],
                  starts: c['starts'], ends: c['ends'], coupon: Value(c['coupon'] ?? '')));
          b.insertAll(campaignBeacons, [
            for (final adv in c['beacons']) CampaignBeaconsCompanion.insert(campaignId: c['id'], advId: adv)
          ]);
        }
      });
      });
    } catch (e) {
      log('replaceCache failed', name: 'db', error: e);
      rethrow;
    }
    await setMeta('version', '${d['version']}');
  }

  // ---- notification dedup + visited ----
  Future<bool> dedupOk(int campaignId, Duration cooldown) async {
    final r = await (select(dedup)..where((d) => d.campaignId.equals(campaignId))).getSingleOrNull();
    if (r == null) return true;
    return DateTime.now().toUtc().difference(DateTime.parse(r.lastFired)) >= cooldown;
  }

  Future<void> clearDedup() => delete(dedup).go(); // dev: let offers re-fire immediately

  Future<void> markFired(int campaignId) => into(dedup).insertOnConflictUpdate(
      DedupCompanion.insert(campaignId: Value(campaignId), lastFired: DateTime.now().toUtc().toIso8601String()));

  Future<void> markVisited(int storeId) => into(visited).insertOnConflictUpdate(
      VisitedCompanion.insert(storeId: Value(storeId), at: DateTime.now().toIso8601String()));

  // ---- outbox ----
  Future<void> queuePing(String tIso, String advId, int rssi) =>
      into(pings).insert(PingsCompanion.insert(t: tIso, advId: advId, rssi: rssi));

  Future<void> queueImpression(int campaignId, String tIso) =>
      into(impressions).insert(ImpressionsCompanion.insert(campaignId: campaignId, t: tIso));

  Future<List<Ping>> takePings() =>
      (select(pings)..orderBy([(p) => OrderingTerm(expression: p.id)])..limit(5000)).get();

  Future<List<Impression>> takeImpressions() =>
      (select(impressions)..orderBy([(i) => OrderingTerm(expression: i.id)])..limit(5000)).get();

  Future<void> deletePings(List<Ping> rows) =>
      (delete(pings)..where((p) => p.id.isIn([for (final r in rows) r.id]))).go();

  Future<void> deleteImpressions(List<Impression> rows) =>
      (delete(impressions)..where((i) => i.id.isIn([for (final r in rows) r.id]))).go();
}
