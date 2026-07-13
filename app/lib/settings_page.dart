import 'package:flutter/material.dart';

import 'ble.dart';
import 'config.dart';
import 'payload_page.dart';
import 'theme.dart';

const _danger = Color(0xFFC43D2E);

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.scanner});

  final Scanner scanner;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

enum _Sync { idle, ok, fail }

class _SettingsPageState extends State<SettingsPage> with TickerProviderStateMixin {
  bool _syncing = false;
  _Sync _sync = _Sync.idle;

  bool _uploading = false;
  int _done = 0, _total = 0;
  bool _uploadJustFinished = false;

  late final AnimationController _spin =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 850));
  late final AnimationController _rise =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  final _mallCtrl = TextEditingController(text: '$mallId');
  final _urlCtrl = TextEditingController(text: baseUrl);
  final _cooldownCtrl = TextEditingController(text: '$cooldownMinutes');
  int? _localVersion;
  bool? _updateAvailable; // null = still checking on open

  @override
  void initState() {
    super.initState();
    _checkUpdate();
  }

  @override
  void dispose() {
    _spin.dispose();
    _rise.dispose();
    _mallCtrl.dispose();
    _urlCtrl.dispose();
    _cooldownCtrl.dispose();
    super.dispose();
  }

  // "no task -> no button": only offer Sync when the server has a newer version.
  Future<void> _checkUpdate() async {
    final local = await widget.scanner.db.version();
    final remote = await widget.scanner.api.version(mallId);
    if (!mounted) return;
    setState(() {
      _localVersion = local;
      _updateAvailable = remote != null && (local == null || remote > local);
    });
  }

  Future<void> _doSync() async {
    if (_syncing) return;
    setState(() {
      _syncing = true;
      _sync = _Sync.idle;
    });
    _spin.repeat();
    final ok = await widget.scanner.refresh();
    _spin.stop();
    _spin.animateTo(1, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    if (!mounted) return;
    setState(() {
      _syncing = false;
      _sync = ok ? _Sync.ok : _Sync.fail;
      if (ok) {
        _localVersion = widget.scanner.syncedVersion;
        _updateAvailable = false;
      }
    });
  }

  Future<void> _doUpload() async {
    if (_uploading) return;
    setState(() {
      _uploading = true;
      _uploadJustFinished = false;
      _done = 0;
      _total = 0;
    });
    _rise.repeat();
    await widget.scanner.uploadWithProgress((done, total) {
      if (mounted) setState(() { _done = done; _total = total; });
    });
    _rise.stop();
    if (!mounted) return;
    setState(() {
      _uploading = false;
      _uploadJustFinished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paper,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: ink,
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _syncCard(),
          const SizedBox(height: 12),
          _uploadCard(),
          const SizedBox(height: 12),
          _identityCard(),
          const SizedBox(height: 12),
          _advancedCard(),
        ],
      ),
    );
  }

  // Filled dark circular icon button - the action on the right of a card.
  Widget _iconBtn(IconData icon, VoidCallback? onTap, {bool busy = false}) {
    return FilledButton(
      onPressed: busy ? null : onTap,
      style: FilledButton.styleFrom(
        backgroundColor: ink,
        foregroundColor: Colors.white,
        disabledBackgroundColor: ink,
        disabledForegroundColor: Colors.white,
        padding: const EdgeInsets.all(12),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: const CircleBorder(),
      ),
      child: busy
          ? const SizedBox(
              width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Icon(icon, size: 20),
    );
  }

  Widget _syncCard() {
    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RotationTransition(turns: _spin, child: const Icon(Icons.sync, color: ink)),
          const SizedBox(width: 14),
          Expanded(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              alignment: Alignment.topLeft,
              curve: Curves.easeOut,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Sync now', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: ink)),
                  const SizedBox(height: 2),
                  const Text('Pull the latest stores, beacons and offers.',
                      style: TextStyle(color: muted, fontSize: 13)),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOut,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SizeTransition(sizeFactor: anim, alignment: Alignment.topLeft, child: child),
                    ),
                    child: _syncStatusLine(),
                  ),
                ],
              ),
            ),
          ),
          ..._syncAction(),
        ],
      ),
    );
  }

  // Only shown when there's an update (or a sync in flight) - "no task, no icon".
  List<Widget> _syncAction() {
    if (_syncing) return [const SizedBox(width: 12), _iconBtn(Icons.sync, null, busy: true)];
    if (_updateAvailable == true) return [const SizedBox(width: 12), _iconBtn(Icons.sync, _doSync)];
    return const [];
  }

  Widget _syncStatusLine() {
    if (_syncing) return const SizedBox.shrink(key: ValueKey('none'));
    if (_sync == _Sync.fail) {
      return _statusLine(const ValueKey('fail'), Icons.error_outline, _danger, "Couldn't reach the server");
    }
    if (_updateAvailable == true) {
      return _statusLine(const ValueKey('upd'), Icons.system_update_alt_rounded, signal, 'Update available');
    }
    if (_localVersion != null) {
      return _statusLine(const ValueKey('ok'), Icons.check_circle, active, 'Up to date · v$_localVersion');
    }
    return const SizedBox.shrink(key: ValueKey('none'));
  }

  Widget _statusLine(Key key, IconData icon, Color color, String text) => Padding(
        key: key,
        padding: const EdgeInsets.only(top: 8),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ]),
      );

  Widget _uploadCard() {
    return _Card(
      child: StreamBuilder<int>(
        stream: widget.scanner.db.watchPending(),
        builder: (context, snap) {
          final pending = snap.data ?? 0;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_upload_outlined, color: ink),
              const SizedBox(width: 14),
              Expanded(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  alignment: Alignment.topLeft,
                  curve: Curves.easeOut,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Upload data',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: ink)),
                      const SizedBox(height: 6),
                      if (_uploading)
                        _progress()
                      else if (pending == 0)
                        _caughtUp()
                      else
                        Text('$pending detection${pending == 1 ? '' : 's'} waiting to upload',
                            style: const TextStyle(color: muted, fontSize: 13)),
                      const SizedBox(height: 6),
                      _viewPayloadLink(),
                    ],
                  ),
                ),
              ),
              if (_uploading) ...[
                const SizedBox(width: 12),
                _iconBtn(Icons.arrow_upward_rounded, null, busy: true),
              ] else if (pending > 0) ...[
                const SizedBox(width: 12),
                _iconBtn(Icons.arrow_upward_rounded, _doUpload),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _viewPayloadLink() => Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => PayloadPage(scanner: widget.scanner))),
          style: TextButton.styleFrom(
            foregroundColor: ink,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: const Icon(Icons.data_object_rounded, size: 16),
          label: const Text('View payload', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      );

  Widget _progress() {
    final v = _total == 0 ? null : _done / _total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: v ?? 0),
            duration: const Duration(milliseconds: 300),
            builder: (_, val, _) => LinearProgressIndicator(
                value: v == null ? null : val, minHeight: 8, backgroundColor: line, color: signal),
          ),
        ),
        const SizedBox(height: 8),
        Row(children: [
          _risingArrow(),
          const SizedBox(width: 6),
          Text('Uploading $_done / $_total', style: const TextStyle(color: muted, fontSize: 12)),
        ]),
      ],
    );
  }

  // Up-arrow that keeps rising + fading while data is being sent.
  Widget _risingArrow() => SizedBox(
        width: 14,
        height: 16,
        child: AnimatedBuilder(
          animation: _rise,
          builder: (_, _) {
            final t = _rise.value;
            final op = (t < 0.5 ? t * 2 : (1 - t) * 2).clamp(0.0, 1.0);
            return Transform.translate(
              offset: Offset(0, 4 - t * 10),
              child: Opacity(
                opacity: op,
                child: const Icon(Icons.arrow_upward_rounded, size: 14, color: signal),
              ),
            );
          },
        ),
      );

  Widget _caughtUp() {
    const row = Row(
      children: [
        Icon(Icons.check_circle, size: 16, color: active),
        SizedBox(width: 6),
        Text('All caught up', style: TextStyle(color: active, fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
    if (!_uploadJustFinished) return row;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.elasticOut,
      builder: (_, s, child) => Transform.scale(scale: s, child: Opacity(opacity: s.clamp(0.0, 1.0), child: child)),
      child: row,
    );
  }

  Widget _identityCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your identity', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: ink)),
          const SizedBox(height: 6),
          const Text("You're anonymous - a one-way hash of a random ID, can't be traced to you.",
              style: TextStyle(color: muted, fontSize: 13, height: 1.35)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: paper, borderRadius: BorderRadius.circular(8), border: Border.all(color: line)),
            child: SelectableText(
              widget.scanner.deviceHash,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: ink, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // Collapsed by default; expand to tweak the app live, no rebuild.
  Widget _advancedCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: const Icon(Icons.build_rounded, size: 20, color: muted),
          title: const Text('Advanced', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: ink)),
          subtitle: const Text('Developer - tweak the app without a rebuild',
              style: TextStyle(color: muted, fontSize: 12)),
          children: [
            _devField('Backend URL', _urlCtrl, TextInputType.url),
            _devField('Mall ID', _mallCtrl, TextInputType.number),
            _devField('Offer cooldown (minutes)', _cooldownCtrl, TextInputType.number),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _applyDev,
                  style: FilledButton.styleFrom(
                    backgroundColor: ink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: const Text('Save & sync', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: _resetCooldowns,
                style: OutlinedButton.styleFrom(
                  foregroundColor: ink,
                  side: const BorderSide(color: line),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Reset cooldowns', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _devField(String label, TextEditingController c, TextInputType kb) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: c,
          keyboardType: kb,
          decoration: InputDecoration(
            labelText: label,
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );

  Future<void> _applyDev() async {
    final m = int.tryParse(_mallCtrl.text.trim());
    final cd = int.tryParse(_cooldownCtrl.text.trim());
    final url = _urlCtrl.text.trim();
    if (url.isEmpty) return _snack('Backend URL required');
    if (m == null || m <= 0) return _snack('Enter a valid mall ID');
    if (cd == null || cd < 0) return _snack('Enter a valid cooldown');
    baseUrl = url;
    mallId = m;
    cooldownMinutes = cd;
    final db = widget.scanner.db;
    await db.setMeta('base_url', url);
    await db.setMeta('mall_id', '$m');
    await db.setMeta('cooldown_min', '$cd');
    final ok = await widget.scanner.refresh();
    await _checkUpdate();
    if (!mounted) return;
    _snack(ok ? 'Saved · synced mall $m' : "Saved · couldn't reach $url");
  }

  Future<void> _resetCooldowns() async {
    await widget.scanner.db.clearDedup();
    if (!mounted) return;
    _snack('Offer cooldowns cleared - offers can fire again');
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration,
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}
