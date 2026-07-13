import 'package:flutter/material.dart';

import 'ble.dart';
import 'theme.dart';

// First-run screen: sets expectations (anonymous, why Bluetooth/location) before
// the OS permission prompt fires. "Get started" marks it done and enters the app.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key, required this.scanner, required this.onDone});

  final Scanner scanner;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: signal, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 24),
              const Text('City Center',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: ink)),
              const SizedBox(height: 8),
              const Text('Nearby store offers, as you walk the mall.',
                  style: TextStyle(fontSize: 16, color: muted, height: 1.35)),
              const SizedBox(height: 40),
              _point(Icons.bluetooth_rounded,
                  'We use Bluetooth to spot in-store beacons as you pass - no pairing, no connecting.'),
              _point(Icons.location_on_rounded,
                  'Android requires location access for Bluetooth scanning. We never read GPS or track where you are.'),
              _point(Icons.visibility_off_rounded,
                  "You're anonymous - a one-way hash, no account, no personal data. It can't be traced back to you."),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    await scanner.db.setMeta('onboarded', '1');
                    onDone();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: ink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Get started',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text('Bluetooth & location prompts appear next.',
                    style: TextStyle(color: muted, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _point(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: line)),
            child: Icon(icon, size: 20, color: ink),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(text, style: const TextStyle(fontSize: 14, height: 1.4, color: ink)),
            ),
          ),
        ]),
      );
}
