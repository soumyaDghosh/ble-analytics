import 'dart:async';
import 'dart:developer';
import 'dart:math' show min;

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'api.dart';
import 'config.dart';
import 'db.dart';
import 'notify.dart';

// Pull the 6-byte instance (= beacon adv_id) out of an Eddystone-UID frame,
// but only for our namespace. Returns null for anything else.
String? parseEddystone(Map<Guid, List<int>> serviceData) {
  for (final e in serviceData.entries) {
    if (!e.key.str.toLowerCase().contains('feaa')) continue;
    final b = e.value;
    if (b.length < 18 || b[0] != 0x00) continue; // 0x00 = UID frame
    if (_hex(b.sublist(2, 12)) != eddystoneNamespace) continue;
    return _hex(b.sublist(12, 18));
  }
  return null;
}

String _hex(List<int> b) => b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

class Scanner extends ChangeNotifier {
  Scanner(this.db, this.api, this.deviceHash);

  final AppDb db;
  final Api api;
  final String deviceHash;

  bool scanning = false;
  String status = 'Idle';
  int? currentFloorId; // floor of the most recent known beacon (drives store auto-filter)
  int? syncedVersion;
  Map<String, dynamic>? lastSent; // last body POSTed to /batch (payload viewer)
  DateTime? lastSentAt;

  final _lastSeen = <String, DateTime>{}; // 5s per-beacon dedup
  DateTime _lastKnown = DateTime.now();
  bool _syncedThisSession = false;
  StreamSubscription<List<ScanResult>>? _sub;
  Timer? _idle;

  Future<bool> _grantPerms() async {
    final res = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse, // Samsung returns no scan results without it
      Permission.notification,
    ].request();
    return (res[Permission.bluetoothScan]?.isGranted ?? false) &&
        (res[Permission.bluetoothConnect]?.isGranted ?? false);
  }

  Future<void> start() async {
    if (scanning) return;
    if (!await _grantPerms()) {
      status = 'Bluetooth permission needed';
      log('scan blocked: bluetooth permission denied', name: 'ble');
      notifyListeners();
      return;
    }
    _syncedThisSession = false;
    _lastKnown = DateTime.now();
    _sub = FlutterBluePlus.onScanResults.listen(_onResults);
    // Scan everything, filter in Dart — the Android 16-bit UUID scan filter is unreliable.
    try {
      await FlutterBluePlus.startScan(continuousUpdates: true, androidScanMode: AndroidScanMode.lowLatency);
    } catch (e) {
      await _sub?.cancel();
      _sub = null;
      status = 'Could not start scan';
      log('startScan failed', name: 'ble', error: e);
      notifyListeners();
      return;
    }
    scanning = true;
    status = 'Scanning…';
    log('scan started', name: 'ble');
    notifyListeners();
    _idle = Timer.periodic(const Duration(minutes: 1), (_) {
      if (DateTime.now().difference(_lastKnown).inMinutes >= 10) {
        stop(reason: 'Auto-stopped after 10 idle minutes');
      }
    });
  }

  Future<void> stop({String reason = 'Stopped'}) async {
    _idle?.cancel();
    await _sub?.cancel();
    await FlutterBluePlus.stopScan();
    scanning = false;
    status = reason;
    log('scan stopped: $reason', name: 'ble');
    notifyListeners();
    await flush();
  }

  Future<void> _onResults(List<ScanResult> results) async {
    for (final r in results) {
      final adv = parseEddystone(r.advertisementData.serviceData);
      if (adv != null) await _handle(adv, r.rssi);
    }
  }

  Future<void> _handle(String adv, int rssi) async {
    final now = DateTime.now();
    _lastKnown = now;

    final last = _lastSeen[adv];
    if (last != null && now.difference(last).inSeconds < 5) return;
    _lastSeen[adv] = now;

    if (!_syncedThisSession) {
      _syncedThisSession = true;
      await _freshness();
    }

    await db.queuePing(now.toUtc().toIso8601String(), adv, rssi);

    final b = await db.beacon(adv);
    if (b == null) return;
    if (currentFloorId != b.floorId) {
      currentFloorId = b.floorId; // store page follows the floor you're on
      notifyListeners();
    }

    final storeId = b.storeId;
    if (storeId == null) return;
    for (final c in await db.matchCampaigns(adv, storeId, now.toUtc())) {
      if (!await db.dedupOk(c.id, Duration(minutes: cooldownMinutes))) continue;
      await db.markFired(c.id);
      await db.markVisited(storeId); // reactive: the store gets a ✓ in the list
      await showOffer(c.id, c.title, _withCoupon(c.body, c.coupon), payload: '$storeId');
      await db.queueImpression(c.id, now.toUtc().toIso8601String());
    }
  }

  Future<void> _freshness() async {
    status = 'Checking for updates…';
    notifyListeners();
    final local = await db.version();
    final remote = await api.version(mallId);
    if (remote != null && (local == null || remote > local)) {
      final data = await api.sync(mallId);
      if (data != null) await db.replaceCache(data);
    }
    syncedVersion = await db.version();
    status = scanning ? 'Scanning…' : status;
    notifyListeners();
  }

  // Manual "sync now".
  Future<bool> refresh() async {
    final data = await api.sync(mallId);
    if (data == null) return false;
    await db.replaceCache(data);
    syncedVersion = await db.version();
    notifyListeners();
    return true;
  }

  Future<void> flush() => uploadWithProgress((_, _) {});

  // Chunked upload so the UI can show real progress.
  Future<void> uploadWithProgress(void Function(int done, int total) onProgress) async {
    final pingRows = await db.takePings();
    final imps = await db.takeImpressions();
    final total = pingRows.length;
    onProgress(0, total);
    if (total == 0) {
      if (imps.isNotEmpty) {
        final impsJson = _impJson(imps);
        if (await api.batch(deviceHash, const [], impsJson)) {
          _recordSent(const [], impsJson);
          await db.deleteImpressions(imps);
        }
      }
      return;
    }
    const chunk = 250;
    var done = 0;
    for (var i = 0; i < pingRows.length; i += chunk) {
      final slice = pingRows.sublist(i, min(i + chunk, pingRows.length));
      final pings = [for (final p in slice) {'t': p.t, 'b': p.advId, 'rssi': p.rssi}];
      final impsJson = i == 0 ? _impJson(imps) : const [];
      if (!await api.batch(deviceHash, pings, impsJson)) break;
      _recordSent(pings, impsJson);
      await db.deletePings(slice);
      if (i == 0) await db.deleteImpressions(imps);
      done += slice.length;
      onProgress(done, total);
    }
  }

  void _recordSent(List pings, List impressions) {
    lastSent = {'device_hash': deviceHash, 'pings': pings, 'impressions': impressions};
    lastSentAt = DateTime.now();
    notifyListeners();
  }

  // The exact body the phone would POST right now — for the in-app payload viewer.
  Future<Map<String, dynamic>> pendingPayload() async {
    final pings = await db.takePings();
    final imps = await db.takeImpressions();
    return {
      'device_hash': deviceHash,
      'pings': [for (final p in pings) {'t': p.t, 'b': p.advId, 'rssi': p.rssi}],
      'impressions': _impJson(imps),
    };
  }

  List _impJson(List<Impression> imps) =>
      [for (final im in imps) {'c': im.campaignId, 't': im.t, 'opened': im.opened}];

  @override
  void dispose() {
    _idle?.cancel();
    _sub?.cancel();
    super.dispose();
  }
}

String _withCoupon(String body, String coupon) => coupon.isNotEmpty ? '$body\nCode: $coupon' : body;
