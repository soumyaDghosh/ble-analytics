import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ble.dart';
import 'theme.dart';

// Shows the exact JSON the phone POSTs to /api/v1/location/batch: what's queued
// right now, and the last body actually sent. For the "here's what we upload" demo.
class PayloadPage extends StatelessWidget {
  const PayloadPage({super.key, required this.scanner});

  final Scanner scanner;

  static const _enc = JsonEncoder.withIndent('  ');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paper,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: ink,
        title: const Text('Upload payload', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: scanner.pendingPayload(),
        builder: (context, snap) {
          final pending = snap.data;
          final sent = scanner.lastSent;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('POST /api/v1/location/batch',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: muted)),
              const SizedBox(height: 14),
              _block(
                context,
                label: 'PENDING',
                subtitle: pending == null
                    ? 'Loading…'
                    : '${_len(pending, 'pings')} pings · ${_len(pending, 'impressions')} impressions queued',
                json: pending == null ? null : _enc.convert(pending),
              ),
              const SizedBox(height: 16),
              _block(
                context,
                label: 'LAST SENT',
                subtitle: sent == null
                    ? 'Nothing sent yet this session.'
                    : 'Sent ${_ago(scanner.lastSentAt)} · ${_len(sent, 'pings')} pings',
                json: sent == null ? null : _enc.convert(sent),
              ),
            ],
          );
        },
      ),
    );
  }

  int _len(Map<String, dynamic> m, String k) => (m[k] as List?)?.length ?? 0;

  String _ago(DateTime? t) {
    if (t == null) return 'just now';
    final s = DateTime.now().difference(t).inSeconds;
    if (s < 60) return '${s}s ago';
    final m = s ~/ 60;
    return m < 60 ? '${m}m ago' : '${m ~/ 60}h ago';
  }

  Widget _block(BuildContext context,
      {required String label, required String subtitle, required String? json}) {
    return Container(
      decoration: cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.w700, color: muted)),
            const Spacer(),
            if (json != null)
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: json));
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Payload copied')));
                },
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.copy_rounded, size: 15, color: ink),
                    SizedBox(width: 4),
                    Text('Copy', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ink)),
                  ]),
                ),
              ),
          ]),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: muted, fontSize: 13)),
          if (json != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: ink, borderRadius: BorderRadius.circular(8)),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText(
                  json,
                  style: const TextStyle(
                      fontFamily: 'monospace', fontSize: 12, height: 1.45, color: Color(0xFFE8EAED)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
