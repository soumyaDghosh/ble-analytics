import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import 'db.dart';

// Anonymous by default: a random per-install UUID, stored once, sent only as a
// one-way hash. No PII, no login.
Future<String> deviceHash(AppDb db) async {
  var raw = await db.getMeta('device_uuid');
  if (raw == null) {
    raw = const Uuid().v4();
    await db.setMeta('device_uuid', raw);
  }
  return sha256.convert(utf8.encode(raw)).toString();
}
