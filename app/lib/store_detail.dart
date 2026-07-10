import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'db.dart';
import 'theme.dart';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _fmt(String iso) {
  final d = DateTime.parse(iso).toLocal();
  return '${d.day} ${_months[d.month - 1]}';
}

class StoreDetail extends StatelessWidget {
  const StoreDetail({super.key, required this.store, required this.db});

  final Store store;
  final AppDb db;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paper,
      body: FutureBuilder<List<Campaign>>(
        future: db.campaignsForStore(store.id),
        builder: (context, snap) {
          final camps = snap.data;
          return CustomScrollView(
            slivers: [
              _hero(context),
              if (camps == null)
                const SliverFillRemaining(
                    hasScrollBody: false, child: Center(child: CircularProgressIndicator()))
              else if (camps.isEmpty)
                SliverFillRemaining(hasScrollBody: false, child: _empty())
              else ...[
                _offersLabel(camps.length),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList.separated(
                    itemCount: camps.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _CampaignCard(c: camps[i]),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  // Big photo header (~30% of the screen): store name + description overlaid,
  // collapses to a compact bar as the offers scroll up.
  Widget _hero(BuildContext context) {
    final h = (MediaQuery.of(context).size.height * 0.30).clamp(220.0, 300.0);
    return SliverAppBar(
      pinned: true,
      expandedHeight: h,
      backgroundColor: ink,
      foregroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        titlePadding: const EdgeInsetsDirectional.only(start: 16, end: 64, bottom: 16),
        title: Text(store.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 19, color: Colors.white)),
        background: Stack(fit: StackFit.expand, children: [
          _photo(),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xE614181F)],
                stops: [0.35, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 58,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (store.badge.isNotEmpty) ...[
                  _badge(store.badge),
                  const SizedBox(height: 10),
                ],
                Text(
                  store.tagline.isNotEmpty ? '${store.category}  ·  ${store.tagline}' : store.category,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 13.5, height: 1.3, color: Colors.white.withValues(alpha: 0.92)),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _photo() {
    final img = store.image;
    if (img == null || img.isEmpty) {
      return Container(
        color: ink,
        alignment: Alignment.center,
        child: Text(store.name.characters.first.toUpperCase(),
            style: TextStyle(fontSize: 96, fontWeight: FontWeight.w800, color: Colors.white.withValues(alpha: 0.12))),
      );
    }
    return CachedNetworkImage(
      imageUrl: img,
      fit: BoxFit.cover,
      placeholder: (_, _) => Container(color: ink),
      errorWidget: (_, _, _) => Container(color: ink),
    );
  }

  Widget _badge(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: signal, borderRadius: BorderRadius.circular(6)),
        child: Text(t,
            style: const TextStyle(
                color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.6)),
      );

  Widget _offersLabel(int n) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(children: [
            const Text('OFFERS',
                style: TextStyle(
                    fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w700, color: muted)),
            const SizedBox(width: 8),
            Expanded(child: Container(height: 1, color: line)),
            const SizedBox(width: 8),
            Text('$n', style: const TextStyle(fontSize: 11, color: muted, fontFamily: 'monospace')),
          ]),
        ),
      );

  Widget _empty() => const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.local_offer_outlined, size: 48, color: muted),
          SizedBox(height: 12),
          Text('No active offers here yet.', style: TextStyle(color: muted, fontSize: 15)),
        ]),
      );
}

class _CampaignCard extends StatelessWidget {
  const _CampaignCard({required this.c});

  final Campaign c;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(c.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: ink)),
          const SizedBox(height: 6),
          Text(c.body, style: const TextStyle(fontSize: 14, color: ink, height: 1.35)),
          const SizedBox(height: 14),
          Row(
            children: [
              if (c.coupon.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: signal.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: signal.withValues(alpha: 0.4)),
                  ),
                  child: Text(c.coupon,
                      style: const TextStyle(
                          fontFamily: 'monospace', fontWeight: FontWeight.w700, fontSize: 13, color: ink)),
                ),
              const Spacer(),
              Text('Valid ${_fmt(c.starts)} – ${_fmt(c.ends)}', style: const TextStyle(fontSize: 12, color: muted)),
            ],
          ),
        ],
      ),
    );
  }
}
