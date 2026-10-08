import 'package:flutter/material.dart';

import '../app/router/routes.dart';
import '_shell_scaffold.dart';

/// Bottom-nav shell for platform operators (`super_admin`).
/// Backend: `GET /api/v1/super/*` (`role:super_admin`, bypass SchoolScope).
class SuperAdminShell extends StatelessWidget {
  const SuperAdminShell(
      {super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  static const List<ShellNavItem> _items = <ShellNavItem>[
    ShellNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
      route: Routes.superDashboard,
    ),
    ShellNavItem(
      icon: Icons.apartment_outlined,
      activeIcon: Icons.apartment,
      label: 'Sekolah',
      route: Routes.superSchools,
    ),
    ShellNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profil',
      route: Routes.superProfile,
    ),
  ];

  @override
  Widget build(BuildContext context) =>
      ShellScaffold(child: child, location: location, items: _items);
}
