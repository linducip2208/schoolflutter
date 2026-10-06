import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/sync/sync_engine.dart';

class ShellNavItem {
  const ShellNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
}

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({
    super.key,
    required this.child,
    required this.location,
    required this.items,
  });

  final Widget child;
  final String location;
  final List<ShellNavItem> items;

  int get _currentIndex {
    final int idx = items.indexWhere((ShellNavItem it) =>
        location == it.route || location.startsWith('${it.route}/'));
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          const _OfflineBanner(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int i) => context.go(items[i].route),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: <NavigationDestination>[
          for (final ShellNavItem it in items)
            NavigationDestination(
              icon: Icon(it.icon),
              selectedIcon: Icon(it.activeIcon),
              label: it.label,
            ),
        ],
      ),
    );
  }
}

/// Slim offline indicator shown above every role shell. Also surfaces the
/// pending outbox count so users know mutations will sync automatically.
class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      initialData: const <ConnectivityResult>[ConnectivityResult.wifi],
      builder: (BuildContext c,
          AsyncSnapshot<List<ConnectivityResult>> snap) {
        final List<ConnectivityResult> results =
            snap.data ?? const <ConnectivityResult>[ConnectivityResult.wifi];
        final bool offline = results.contains(ConnectivityResult.none);
        if (!offline) return const SizedBox.shrink();
        return ValueListenableBuilder<int>(
          valueListenable: SyncEngine.instance.pendingCount,
          builder: (BuildContext c, int pending, _) {
            return Container(
              width: double.infinity,
              color: Colors.orange.shade800,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.cloud_off, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        pending > 0
                            ? 'Offline — $pending perubahan menunggu sinkron'
                            : 'Offline — menampilkan data tersimpan',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
