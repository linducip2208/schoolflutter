import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../app/router/routes.dart';
import '../core/widgets/menu_tile.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';

/// Hub modul siswa (docs §student): 6 menu + layanan.
/// Setiap tile membuka screen real ber-API.
class StudentMenuPage extends StatelessWidget {
  const StudentMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<int> studentIds =
        context.watch<AuthBloc>().state.user?.studentIds ?? const <int>[];
    final int? sid = studentIds.isNotEmpty ? studentIds.first : null;
    final List<_MenuEntry> entries = <_MenuEntry>[
      const _MenuEntry(
          icon: Icons.grade_outlined,
          label: 'Nilai',
          route: Routes.studentMarks),
      const _MenuEntry(
          icon: Icons.fact_check_outlined,
          label: 'Absensi',
          route: Routes.studentAttendance),
      const _MenuEntry(
          icon: Icons.menu_book_outlined,
          label: 'Perpus',
          route: Routes.studentLibrary),
      const _MenuEntry(
          icon: Icons.sports_soccer_outlined,
          label: 'Ekskul',
          route: Routes.studentEkskul),
      const _MenuEntry(
          icon: Icons.event_outlined,
          label: 'Event',
          route: Routes.studentEvent),
      const _MenuEntry(
          icon: Icons.school_outlined,
          label: 'Beasiswa',
          route: Routes.studentBeasiswa),
      const _MenuEntry(
          icon: Icons.work_outline,
          label: 'Karier',
          route: Routes.studentKarier),
      const _MenuEntry(
          icon: Icons.emoji_events_outlined,
          label: 'Prestasi',
          route: Routes.studentPrestasi),
      const _MenuEntry(
          icon: Icons.play_lesson_outlined,
          label: 'LMS',
          route: Routes.studentLms),
      const _MenuEntry(
          icon: Icons.quiz_outlined,
          label: 'Kuis',
          route: Routes.studentQuizzes),
      const _MenuEntry(
          icon: Icons.videocam_outlined,
          label: 'Live Class',
          route: Routes.studentLive),
      const _MenuEntry(
          icon: Icons.auto_awesome_outlined,
          label: 'AI',
          route: Routes.studentAi),
      const _MenuEntry(
          icon: Icons.campaign_outlined,
          label: 'Pengumuman',
          route: Routes.notice),
      const _MenuEntry(
          icon: Icons.notifications_outlined,
          label: 'Notifikasi',
          route: Routes.notifications),
      const _MenuEntry(
          icon: Icons.report_outlined,
          label: 'Lapor Bullying',
          route: Routes.studentBullying),
      const _MenuEntry(
          icon: Icons.sos_outlined,
          label: 'Darurat',
          route: Routes.studentEmergency),
      if (sid != null)
        _MenuEntry(
            icon: Icons.fastfood_outlined,
            label: 'Kantin',
            route: '/student/canteen/$sid'),
      if (sid != null)
        _MenuEntry(
            icon: Icons.directions_bus_outlined,
            label: 'Bus',
            route: '/student/bus/$sid'),
    ];
    const List<Color> tints = <Color>[
      Color(0xFF2563EB),
      Color(0xFF14B8A6),
      Color(0xFF7C3AED),
      Color(0xFFF59E0B),
      Color(0xFF0EA5E9),
      Color(0xFF16A34A),
      Color(0xFFDB2777),
      Color(0xFFDC2626),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Menu Siswa')),
      body: GridView.count(
        crossAxisCount: 3,
        padding: const EdgeInsets.all(12),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.92,
        children: <Widget>[
          for (int i = 0; i < entries.length; i++)
            MenuTile(
              icon: entries[i].icon,
              label: entries[i].label,
              color: tints[i % tints.length],
              onTap: () => context.push(entries[i].route),
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
