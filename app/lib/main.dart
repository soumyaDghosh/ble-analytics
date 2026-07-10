import 'package:flutter/material.dart';

import 'api.dart';
import 'ble.dart';
import 'config.dart';
import 'db.dart';
import 'device.dart';
import 'notify.dart';
import 'onboarding_page.dart';
import 'settings_page.dart';
import 'store_detail.dart';
import 'stores_page.dart';
import 'theme.dart';

final _navKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDb();
  // Dev overrides from the Advanced panel, persisted in Meta.
  mallId = int.tryParse(await db.getMeta('mall_id') ?? '') ?? mallId;
  baseUrl = await db.getMeta('base_url') ?? baseUrl;
  cooldownMinutes = int.tryParse(await db.getMeta('cooldown_min') ?? '') ?? cooldownMinutes;
  final onboarded = await db.getMeta('onboarded') == '1';
  await initNotify(onSelectStore: (storeId) async {
    final store = await db.storeById(storeId);
    if (store != null) {
      _navKey.currentState?.push(MaterialPageRoute(builder: (_) => StoreDetail(store: store, db: db)));
    }
  });
  final scanner = Scanner(db, Api(), await deviceHash(db));
  runApp(App(scanner: scanner, onboarded: onboarded));
}

class App extends StatelessWidget {
  const App({super.key, required this.scanner, required this.onboarded});
  final Scanner scanner;
  final bool onboarded;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navKey,
      title: 'City Center',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: paper,
        colorScheme: ColorScheme.fromSeed(seedColor: signal, primary: ink, surface: Colors.white),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: ink, centerTitle: false),
      ),
      home: onboarded
          ? Home(scanner: scanner)
          : OnboardingPage(
              scanner: scanner,
              onDone: () => _navKey.currentState!.pushReplacement(
                  MaterialPageRoute(builder: (_) => Home(scanner: scanner))),
            ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key, required this.scanner});
  final Scanner scanner;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _filter = StoreFilter();

  @override
  void initState() {
    super.initState();
    // On open: ship anything left over, pull the latest stores/photos, then scan.
    Future(() async {
      await widget.scanner.flush();
      await widget.scanner.refresh();
      await widget.scanner.start();
    });
  }

  @override
  void dispose() {
    _filter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scanner;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const Text('City Center', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3)),
        actions: [
          AnimatedBuilder(
            animation: s,
            builder: (_, _) => ScanButton(on: s.scanning, onTap: () => s.scanning ? s.stop() : s.start()),
          ),
          AnimatedBuilder(
            animation: _filter,
            builder: (_, _) => _iconWithDot(
              icon: Icons.filter_list_rounded,
              tooltip: 'Filter',
              dot: _filter.active,
              onPressed: () => showStoreFilterSheet(context, s.db, _filter),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => SettingsPage(scanner: s))),
          ),
          const SizedBox(width: 6),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: line),
        ),
      ),
      body: StoresPage(scanner: s, filter: _filter),
    );
  }

  Widget _iconWithDot({
    required IconData icon,
    required String tooltip,
    required bool dot,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Stack(clipBehavior: Clip.none, children: [
        Icon(icon),
        if (dot)
          Positioned(
            right: -1,
            top: -1,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: signal,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ]),
    );
  }
}

// Icon-only bluetooth scan toggle. Idle = bluetooth; scanning = bluetooth_searching
// on an amber disc that pulses.
class ScanButton extends StatefulWidget {
  const ScanButton({super.key, required this.on, required this.onTap});
  final bool on;
  final VoidCallback onTap;

  @override
  State<ScanButton> createState() => _ScanButtonState();
}

class _ScanButtonState extends State<ScanButton> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 950))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final on = widget.on;
    final icon = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Icon(
        on ? Icons.bluetooth_searching_rounded : Icons.bluetooth_rounded,
        key: ValueKey(on),
        size: 20,
        color: on ? Colors.white : ink,
      ),
    );
    return Tooltip(
      message: on ? 'Stop scanning' : 'Scan for beacons',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: on ? signal : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: on ? signal : line),
            ),
            alignment: Alignment.center,
            child: on
                ? FadeTransition(opacity: _c.drive(Tween(begin: 0.45, end: 1)), child: icon)
                : icon,
          ),
        ),
      ),
    );
  }
}
