import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/router/routes.dart';
import '../core/widgets/menu_tile.dart';

/// Hub modul guru (docs §teacher): semua menu mengajar dalam satu tempat.
/// Setiap tile membuka screen real ber-API.
class TeacherMenuPage extends StatelessWidget {
  const TeacherMenuPage({super.key});

  static const List<_MenuEntry> _entries = <_MenuEntry>[
    _MenuEntry(
        icon: Icons.description_outlined,
        label: 'RPP',
        route: Routes.teacherRpp),
    _MenuEntry(
        icon: Icons.help_outline,
        label: 'Bank Soal',
        route: Routes.teacherBankSoal),
    _MenuEntry(
        icon: Icons.grade_outlined,
        label: 'Input Nilai',
        route: Routes.teacherNilai),
    _MenuEntry(
        icon: Icons.videocam_outlined,
        label: 'Live Class',
        route: Routes.teacherLive),
    _MenuEntry(
        icon: Icons.auto_awesome_outlined,
        label: 'AI Tools',
        route: Routes.teacherAi),
    _MenuEntry(
        icon: Icons.account_tree_outlined,
        label: 'Kurikulum',
        route: Routes.teacherKurikulum),
    _MenuEntry(
        icon: Icons.menu_book_outlined,
        label: 'Hafalan',
        route: Routes.hafalanInput),
    _MenuEntry(
        icon: Icons.gavel_outlined,
        label: 'Disiplin',
        route: Routes.teacherDisiplin),
    _MenuEntry(
        icon: Icons.emoji_events_outlined,
        label: 'Prestasi',
        route: Routes.teacherPrestasi),
    _MenuEntry(
        icon: Icons.chat_outlined, label: 'Chat', route: Routes.teacherChat),
    _MenuEntry(
        icon: Icons.notifications_outlined,
        label: 'Notifikasi',
        route: Routes.notifications),
    _MenuEntry(
        icon: Icons.lock_outlined,
        label: 'Kunci & Koreksi',
        route: Routes.teacherAttendanceTools),
    _MenuEntry(
        icon: Icons.flag_outlined,
        label: 'Target Hafalan',
        route: Routes.teacherHafalanTargets),
    _MenuEntry(
        icon: Icons.quiz_outlined,
        label: 'Kuis LMS',
        route: Routes.teacherQuizzes),
    _MenuEntry(
        icon: Icons.sos_outlined,
        label: 'Darurat',
        route: Routes.teacherEmergency),
  ];

  static const List<Color> _tints = <Color>[
    Color(0xFF7C3AED),
    Color(0xFF2563EB),
    Color(0xFF14B8A6),
    Color(0xFFF59E0B),
    Color(0xFF0EA5E9),
    Color(0xFF16A34A),
    Color(0xFFDB2777),
    Color(0xFFDC2626),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu Guru')),
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
