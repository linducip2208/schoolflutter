import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/app_offline_banner.dart';

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
    this.fallbackIndex = 0,
  });

  final Widget child;
  final String location;
  final List<ShellNavItem> items;

  /// Index highlighted when [location] matches no tab (e.g. a detail page
  /// opened from the Menu hub). Shells pass their Menu tab index so detail
  /// pages no longer light up the wrong tab.
  final int fallbackIndex;

  int get _currentIndex {
    final int idx = items.indexWhere(
      (ShellNavItem it) =>
          location == it.route || location.startsWith('${it.route}/'),
    );
    if (idx >= 0) {
      return idx;
    }
    if (fallbackIndex >= 0 && fallbackIndex < items.length) {
      return fallbackIndex;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          // Shared banner: themed colors, pending count, manual retry.
          // Replaces the former private duplicate with hardcoded colors.
          const AppOfflineBanner(),
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
