import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/router/routes.dart';

/// Hub wali (docs §parent): anak, layanan, komunikasi.
/// Setiap tile membuka screen real ber-API.
class ParentMenuPage extends StatelessWidget {
  const ParentMenuPage({super.key});

  static const List<_MenuEntry> _entries = <_MenuEntry>[
    _MenuEntry(icon: Icons.family_restroom_outlined, label: 'Anak Saya', route: Routes.parentChildren),
    _MenuEntry(icon: Icons.event_outlined, label: 'Event', route: Routes.parentEvent),
    _MenuEntry(icon: Icons.volunteer_activism_outlined, label: 'Donasi', route: Routes.parentDonasi),
    _MenuEntry(icon: Icons.chat_outlined, label: 'Chat', route: Routes.parentChat),
    _MenuEntry(icon: Icons.campaign_outlined, label: 'Pengumuman', route: Routes.notice),
    _MenuEntry(icon: Icons.notifications_outlined, label: 'Notifikasi', route: Routes.notifications),
    _MenuEntry(icon: Icons.report_outlined, label: 'Lapor Bullying', route: Routes.parentBullying),
    _MenuEntry(icon: Icons.sos_outlined, label: 'Darurat', route: Routes.parentEmergency),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu Wali')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.35,
        children: <Widget>[
          for (final _MenuEntry e in _entries)
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.push(e.route),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(e.icon,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 8),
                    Text(e.label,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
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
