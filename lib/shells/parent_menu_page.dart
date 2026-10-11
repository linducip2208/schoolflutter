import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/router/routes.dart';
import '../core/widgets/menu_tile.dart';

/// Hub wali (docs §parent): anak, layanan, komunikasi.
/// Setiap tile membuka screen real ber-API.
class ParentMenuPage extends StatelessWidget {
  const ParentMenuPage({super.key});

  static const List<_MenuEntry> _entries = <_MenuEntry>[
    _MenuEntry(
        icon: Icons.family_restroom_outlined,
        label: 'Anak Saya',
        route: Routes.parentChildren),
    _MenuEntry(
        icon: Icons.how_to_reg_outlined,
        label: 'PPDB Saya',
        route: Routes.parentApplications),
    _MenuEntry(
        icon: Icons.event_outlined, label: 'Event', route: Routes.parentEvent),
    _MenuEntry(
        icon: Icons.volunteer_activism_outlined,
        label: 'Donasi',
        route: Routes.parentDonasi),
    _MenuEntry(
        icon: Icons.chat_outlined, label: 'Chat', route: Routes.parentChat),
    _MenuEntry(
        icon: Icons.campaign_outlined,
        label: 'Pengumuman',
        route: Routes.notice),
    _MenuEntry(
        icon: Icons.notifications_outlined,
        label: 'Notifikasi',
        route: Routes.notifications),
    _MenuEntry(
        icon: Icons.report_outlined,
        label: 'Lapor Bullying',
        route: Routes.parentBullying),
    _MenuEntry(
        icon: Icons.sos_outlined,
        label: 'Darurat',
        route: Routes.parentEmergency),
  ];

  static const List<Color> _tints = <Color>[
    Color(0xFF14B8A6),
    Color(0xFF2563EB),
    Color(0xFFF59E0B),
    Color(0xFF7C3AED),
    Color(0xFF0EA5E9),
    Color(0xFF16A34A),
    Color(0xFFDB2777),
    Color(0xFFDC2626),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu Wali')),
      body: GridView.count(
        crossAxisCount: 3,
        padding: const EdgeInsets.all(12),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.92,
        children: <Widget>[
          for (int i = 0; i < _entries.length; i++)
            MenuTile(
              icon: _entries[i].icon,
              label: _entries[i].label,
              color: _tints[i % _tints.length],
              onTap: () => context.push(_entries[i].route),
            ),
        ],
      ),
    );
  }
}

class _MenuEntry {
  const _MenuEntry({
    required this.icon,
    required this.label,
    required this.route,
  });
  final IconData icon;
  final String label;
  final String route;
}
