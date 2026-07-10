import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import 'config.dart';

// Thin client. Every call fails soft (returns null/false) so the app keeps
// working offline from cache.
class Api {
  Future<int?> version(int mall) async {
    try {
      final r = await http
          .head(Uri.parse('$baseUrl/api/v1/cache/version?mall_id=$mall'))
          .timeout(const Duration(seconds: 6));
      return int.tryParse(r.headers['cache-version'] ?? '');
    } catch (e) {
      log('version check failed', name: 'api', error: e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> sync(int mall) async {
    try {
      final r = await http
          .get(Uri.parse('$baseUrl/api/v1/data/sync?mall_id=$mall'))
          .timeout(const Duration(seconds: 10));
      if (r.statusCode != 200) return null;
      return jsonDecode(r.body) as Map<String, dynamic>;
    } catch (e) {
      log('sync failed', name: 'api', error: e);
      return null;
    }
  }

  Future<bool> batch(String deviceHash, List pings, List impressions) async {
    try {
      final r = await http
          .post(Uri.parse('$baseUrl/api/v1/location/batch'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'device_hash': deviceHash, 'pings': pings, 'impressions': impressions}))
          .timeout(const Duration(seconds: 15));
      return r.statusCode == 200;
    } catch (e) {
      log('batch upload failed', name: 'api', error: e);
      return false;
    }
  }
}
