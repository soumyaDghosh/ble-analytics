import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'ble.dart';
import 'db.dart';
import 'store_detail.dart';
import 'theme.dart';

// Filter state shared between the app-bar filter button (shows the active dot,
// opens the sheet) and the store list. Lives in Home so both can reach it.
class StoreFilter extends ChangeNotifier {
  int? floor; // null = all floors
  String? category; // null = all categories
  bool userPicked = false; // user chose a floor -> stop auto-following the beacon

  // Any narrowing lights the filter dot - whether the beacon auto-followed a
  // floor or the user picked one/a category. "All" (null) clears it.
  bool get active => floor != null || category != null;

  void setFloor(int? f) {
    floor = f;
    userPicked = true;
    notifyListeners();
  }

  void setCategory(String? c) {
    category = c;
    notifyListeners();
  }

  void clear() {
    floor = null;
    category = null;
    userPicked = false;
    notifyListeners();
  }

  // Follow the floor you're physically on until the user overrides it.
  void autoFloor(int? f) {
    if (!userPicked && f != null && f != floor) {
      floor = f;
      notifyListeners();
    }
  }
}

class StoresPage extends StatefulWidget {
  const StoresPage({super.key, required this.scanner, required this.filter});
  final Scanner scanner;
  final StoreFilter filter;

  @override
  State<StoresPage> createState() => _StoresPageState();
}

class _StoresPageState extends State<StoresPage> {
  AppDb get db => widget.scanner.db;

  bool _showPill = false; // "you're on <floor>" pill auto-hides after 5s
  int? _pillFloor;
  Timer? _pillTimer;

  @override
  void initState() {
    super.initState();
    widget.scanner.addListener(_onScan);
    widget.filter.addListener(_onFilter);
  }

  @override
  void dispose() {
    _pillTimer?.cancel();
    widget.scanner.removeListener(_onScan);
    widget.filter.removeListener(_onFilter);
    super.dispose();
  }

  void _onScan() {
    widget.filter.autoFloor(widget.scanner.currentFloorId);
    // Flash the pill for 5s each time the auto-followed floor changes.
    final f = widget.scanner.currentFloorId;
    if (!widget.filter.userPicked && f != null && f != _pillFloor) {
      _pillFloor = f;
      _pillTimer?.cancel();
      setState(() => _showPill = true);
      _pillTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) setState(() => _showPill = false);
      });
    }
  }

  void _onFilter() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Floor>>(
      stream: db.watchFloors(),
      builder: (_, fs) {
        final floors = fs.data ?? const <Floor>[];
        return StreamBuilder<List<Store>>(
          stream: db.watchStores(),
          builder: (_, ss) {
            final all = ss.data ?? const <Store>[];
            return StreamBuilder<Set<int>>(
              stream: db.watchVisited(),
              builder: (_, vs) {
                final visited = vs.data ?? const <int>{};
                if (all.isEmpty) return _empty();
                final f = widget.filter;
                final shown = all
                    .where((s) => (f.floor == null || s.floorId == f.floor) &&
                        (f.category == null || s.category == f.category))
                    .toList();
                return RefreshIndicator(
                  color: signal,
                  onRefresh: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final ok = await widget.scanner.refresh();
                    if (!ok) {
                      messenger.showSnackBar(
                          const SnackBar(content: Text("Couldn't reach the server")));
                    }
                  },
                  child: _list(shown, floors, visited),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _list(List<Store> shown, List<Floor> floors, Set<int> visited) {
    final following =
        !widget.filter.userPicked && widget.scanner.currentFloorId != null;
    final ordered = [...floors]..sort((a, b) => a.number.compareTo(b.number));
    final children = <Widget>[];
    var anyStore = false;

    if (following && _showPill) children.add(_herePill(floors));

    for (final f in ordered) {
      final rows = shown.where((s) => s.floorId == f.id).toList();
      if (rows.isEmpty) continue;
      anyStore = true;
      final here = following && widget.scanner.currentFloorId == f.id;
      children.add(_sectionHeader(f.name, rows.length, here));
      for (final s in rows) {
        children.add(_StoreCard(
          store: s,
          visited: visited.contains(s.id),
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => StoreDetail(store: s, db: db))),
        ));
      }
    }

    if (!anyStore) {
      children.add(Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.filter_alt_off_outlined, size: 40, color: muted),
            const SizedBox(height: 10),
            const Text('No stores match your filter', style: TextStyle(color: muted, fontSize: 14)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: widget.filter.clear,
              style: TextButton.styleFrom(foregroundColor: ink),
              child: const Text('Clear filter'),
            ),
          ]),
        ),
      ));
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 6, bottom: 24),
      children: children,
    );
  }

  Widget _herePill(List<Floor> floors) {
    final name = floors
        .firstWhere((f) => f.id == widget.scanner.currentFloorId,
            orElse: () => floors.isEmpty ? Floor(id: 0, number: 0, name: '') : floors.first)
        .name;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: signal.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: signal.withValues(alpha: 0.35)),
        ),
        child: Row(children: [
          const Icon(Icons.my_location_rounded, size: 16, color: signal),
          const SizedBox(width: 8),
          Expanded(
            child: Text("You're on $name - showing this floor",
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: ink)),
          ),
          GestureDetector(
            onTap: () => widget.filter.setFloor(null),
            child: const Text('See all',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: ink)),
          ),
        ]),
      ),
    );
  }

  Widget _sectionHeader(String name, int count, bool here) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(children: [
          Text(name.toUpperCase(),
              style: const TextStyle(
                  fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w700, color: muted)),
          if (here) ...[
            const SizedBox(width: 6),
            const Text('· HERE',
                style: TextStyle(fontSize: 11, letterSpacing: 1.0, fontWeight: FontWeight.w700, color: signal)),
          ],
          const SizedBox(width: 8),
          Expanded(child: Container(height: 1, color: line)),
          const SizedBox(width: 8),
          Text('$count', style: const TextStyle(fontSize: 11, color: muted, fontFamily: 'monospace')),
        ]),
      );

  Widget _empty() => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 120),
            child: Column(children: [
              const Icon(Icons.storefront_outlined, size: 48, color: muted),
              const SizedBox(height: 12),
              const Text('No stores yet', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 4),
              Text('Pull down to sync, or start a scan near a beacon.',
                  textAlign: TextAlign.center, style: TextStyle(color: muted)),
            ]),
          ),
        ],
      );
}

// Swiggy/Zomato-style store card: photo thumbnail, name + badge, category, tagline hook.
class _StoreCard extends StatelessWidget {
  const _StoreCard({required this.store, required this.visited, required this.onTap});
  final Store store;
  final bool visited;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey(store.id), // preserve element so the tick can animate in
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: visited ? active.withValues(alpha: 0.5) : line),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              _thumb(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Flexible(
                      child: Text(store.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ink)),
                    ),
                    if (store.badge.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      _badge(store.badge),
                    ],
                  ]),
                  const SizedBox(height: 3),
                  Text(store.category, style: const TextStyle(color: muted, fontSize: 12.5)),
                  if (store.tagline.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(store.tagline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12.5, height: 1.2, color: ink.withValues(alpha: 0.7))),
                  ],
                ]),
              ),
              const SizedBox(width: 6),
              _trailing(),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _thumb() {
    const size = 76.0;
    final img = store.image;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: size,
        height: size,
        child: img == null || img.isEmpty
            ? _mono()
            : CachedNetworkImage(
                imageUrl: img,
                fit: BoxFit.cover,
                placeholder: (_, _) => _mono(),
                errorWidget: (_, _, _) => _mono(),
              ),
      ),
    );
  }

  // Category monogram placeholder while the photo loads / if missing.
  Widget _mono() => Container(
        color: ink.withValues(alpha: 0.05),
        alignment: Alignment.center,
        child: Text(
          store.name.characters.first.toUpperCase(),
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: ink.withValues(alpha: 0.3)),
        ),
      );

  Widget _badge(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(color: signal, borderRadius: BorderRadius.circular(6)),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 0.6)),
      );

  Widget _trailing() => Row(mainAxisSize: MainAxisSize.min, children: [
        // visited tick - bounces in when the offer fires
        AnimatedScale(
          scale: visited ? 1 : 0,
          duration: const Duration(milliseconds: 380),
          curve: Curves.elasticOut,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: active.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, size: 16, color: active),
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: muted),
      ]);
}

// Flipkart-style filter sheet, opened from the app-bar filter button.
Future<void> showStoreFilterSheet(BuildContext context, AppDb db, StoreFilter filter) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true, // grow to fit content instead of capping at half screen
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (_) => FutureBuilder<List<dynamic>>(
      future: Future.wait([db.watchFloors().first, db.categories()]),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const SizedBox(height: 240, child: Center(child: CircularProgressIndicator()));
        }
        final floors = (snap.data![0] as List<Floor>)..sort((a, b) => a.number.compareTo(b.number));
        final cats = snap.data![1] as List<String>;
        return AnimatedBuilder(
          animation: filter,
          builder: (context, _) => _FilterSheet(filter: filter, floors: floors, cats: cats),
        );
      },
    ),
  );
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet({required this.filter, required this.floors, required this.cats});
  final StoreFilter filter;
  final List<Floor> floors;
  final List<String> cats;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: line, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            const Text('Filter', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: ink)),
            const Spacer(),
            if (filter.active)
              TextButton(
                onPressed: filter.clear,
                style: TextButton.styleFrom(foregroundColor: muted, padding: EdgeInsets.zero),
                child: const Text('Clear all', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
          ]),
          const SizedBox(height: 12),
          _label('FLOOR'),
          _wrap([
            for (final f in floors)
              _chip(f.name, filter.floor == f.id,
                  () => filter.setFloor(filter.floor == f.id ? null : f.id)),
          ]),
          const SizedBox(height: 18),
          _label('CATEGORY'),
          _wrap([
            for (final c in cats)
              _chip(c, filter.category == c,
                  () => filter.setCategory(filter.category == c ? null : c)),
          ]),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                  backgroundColor: ink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Show results', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(t,
            style: const TextStyle(
                fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w700, color: muted)),
      );

  Widget _wrap(List<Widget> chips) => Wrap(spacing: 8, runSpacing: 8, children: chips);

  Widget _chip(String label, bool sel, VoidCallback onTap) => ChoiceChip(
        label: Text(label),
        selected: sel,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        labelStyle: TextStyle(color: sel ? Colors.white : ink, fontWeight: FontWeight.w600, fontSize: 13),
        selectedColor: ink,
        backgroundColor: Colors.white,
        side: BorderSide(color: sel ? ink : line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      );
}
