import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../sync/sync_engine.dart';

/// Offline banner: shows when device offline OR outbox has pending mutations.
///
/// Place above body content on network-driven screens.
class AppOfflineBanner extends StatefulWidget {
  const AppOfflineBanner({super.key});

  @override
  State<AppOfflineBanner> createState() => _AppOfflineBannerState();
}

class _AppOfflineBannerState extends State<AppOfflineBanner> {
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    unawaited(_probe());
    _sub = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> r) {
      if (mounted)
        setState(() => _offline = r.contains(ConnectivityResult.none));
    });
    SyncEngine.instance.pendingCount.addListener(_onPending);
  }

  Future<void> _probe() async {
    final List<ConnectivityResult> r = await Connectivity().checkConnectivity();
    if (mounted) setState(() => _offline = r.contains(ConnectivityResult.none));
  }

  void _onPending() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _sub?.cancel();
    SyncEngine.instance.pendingCount.removeListener(_onPending);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int pending = SyncEngine.instance.pendingCount.value;
    if (!_offline && pending == 0) return const SizedBox.shrink();

    final String text = _offline
        ? (pending > 0
            ? 'Offline — $pending perubahan tersimpan, akan dikirim otomatis.'
            : 'Anda sedang offline. Data yang tampil mungkin tidak terbaru.')
        : '$pending perubahan menunggu sinkronisasi…';

    return Material(
      color: _offline
          ? Theme.of(context).colorScheme.errorContainer
          : Theme.of(context).colorScheme.secondaryContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: <Widget>[
              Icon(
                _offline ? Icons.wifi_off_outlined : Icons.sync_outlined,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(text, style: Theme.of(context).textTheme.bodySmall),
              ),
              if (!_offline && pending > 0)
                TextButton(
                  onPressed: () => SyncEngine.instance.retryFailed(),
                  child: const Text('Kirim'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
