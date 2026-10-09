import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/router/routes.dart';

/// Admin module hub: every tile opens a real working screen.
/// Only modules whose repositories call role-agnostic endpoints
/// (backend-permitted for `admin`) are listed — student/teacher-scoped
/// pages (jadwal, ujian-attempt, nilai) are deliberately excluded.
class AdminMenuPage extends StatelessWidget {
  const AdminMenuPage({super.key});

  static const List<_MenuEntry> _entries = <_MenuEntry>[
    _MenuEntry(
        icon: Icons.fact_check_outlined,
        label: 'Absensi',
        route: Routes.adminAttendance),
    _MenuEntry(
        icon: Icons.class_outlined,
        label: 'Kelas Online',
        route: Routes.adminClassroom),
    _MenuEntry(
        icon: Icons.menu_book_outlined,
        label: 'Perpustakaan',
        route: Routes.adminLibrary),
    _MenuEntry(
        icon: Icons.apartment_outlined, label: 'Asrama', route: Routes.hostel),
    _MenuEntry(
        icon: Icons.directions_bus_outlined,
        label: 'Transport',
        route: Routes.adminTransportManage),
    _MenuEntry(
        icon: Icons.campaign_outlined,
        label: 'Pengumuman',
        route: Routes.adminNotice),
    _MenuEntry(
        icon: Icons.payments_outlined,
        label: 'Payroll',
        route: Routes.adminPayroll),
    _MenuEntry(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Aksi Keuangan',
        route: Routes.adminFinanceTools),
    _MenuEntry(
        icon: Icons.chat_outlined, label: 'Chat', route: Routes.adminChat),
    _MenuEntry(
        icon: Icons.notifications_outlined,
        label: 'Notifikasi',
        route: Routes.notifications),
    _MenuEntry(
        icon: Icons.person_add_outlined,
        label: 'PPDB',
        route: Routes.adminPpdb),
    _MenuEntry(
        icon: Icons.calendar_month_outlined,
        label: 'Tahun Ajaran',
        route: Routes.adminTahunAjaran),
    _MenuEntry(
        icon: Icons.quiz_outlined,
        label: 'Ujian',
        route: Routes.adminExamManage),
    _MenuEntry(
        icon: Icons.help_outline,
        label: 'Bank Soal',
        route: Routes.adminBankSoal),
    _MenuEntry(
        icon: Icons.description_outlined, label: 'RPP', route: Routes.adminRpp),
    _MenuEntry(
        icon: Icons.account_tree_outlined,
        label: 'Kurikulum',
        route: Routes.adminKurikulum),
    _MenuEntry(
        icon: Icons.grade_outlined,
        label: 'Nilai Batch',
        route: Routes.adminNilaiBatch),
    _MenuEntry(
        icon: Icons.event_outlined, label: 'Event', route: Routes.adminEvent),
    _MenuEntry(
        icon: Icons.volunteer_activism_outlined,
        label: 'Donasi',
        route: Routes.adminDonasi),
    _MenuEntry(
        icon: Icons.emoji_events_outlined,
        label: 'Prestasi',
        route: Routes.adminPrestasi),
    _MenuEntry(
        icon: Icons.school_outlined,
        label: 'Beasiswa',
        route: Routes.adminBeasiswa),
    _MenuEntry(
        icon: Icons.work_outline, label: 'Karier', route: Routes.adminKarier),
    _MenuEntry(
        icon: Icons.sports_soccer_outlined,
        label: 'Ekskul',
        route: Routes.adminEkskul),
    _MenuEntry(
        icon: Icons.inventory_2_outlined,
        label: 'Inventaris',
        route: Routes.adminInventaris),
    _MenuEntry(
        icon: Icons.badge_outlined,
        label: 'Visitor',
        route: Routes.adminVisitor),
    _MenuEntry(
        icon: Icons.fastfood_outlined,
        label: 'Kantin',
        route: Routes.adminKantin),
    _MenuEntry(
        icon: Icons.sync_outlined,
        label: 'Dapodik',
        route: Routes.adminDapodik),
    _MenuEntry(
        icon: Icons.medical_services_outlined,
        label: 'UKS',
        route: Routes.adminMedis),
    _MenuEntry(
        icon: Icons.gavel_outlined,
        label: 'Disiplin',
        route: Routes.adminDisiplin),
    _MenuEntry(
        icon: Icons.forum_outlined,
        label: 'Konseling',
        route: Routes.adminKonseling),
    _MenuEntry(
        icon: Icons.qr_code_2_outlined,
        label: 'ID Gate',
        route: Routes.adminGate),
    _MenuEntry(
        icon: Icons.videocam_outlined,
        label: 'Live Class',
        route: Routes.adminLive),
    _MenuEntry(
        icon: Icons.auto_awesome_outlined,
        label: 'AI Tools',
        route: Routes.adminAiTools),
    _MenuEntry(
        icon: Icons.smart_toy_outlined,
        label: 'AI Provider',
        route: Routes.adminAiProvider),
    _MenuEntry(
        icon: Icons.account_balance_outlined,
        label: 'Payment',
        route: Routes.adminPayProvider),
    _MenuEntry(
        icon: Icons.palette_outlined,
        label: 'Branding',
        route: Routes.adminBranding),
    _MenuEntry(
        icon: Icons.import_export_outlined,
        label: 'Import/Export',
        route: Routes.adminImportExport),
    _MenuEntry(
        icon: Icons.analytics_outlined,
        label: 'Risiko',
        route: Routes.adminRisiko),
    _MenuEntry(
        icon: Icons.foundation_outlined,
        label: 'Yayasan',
        route: Routes.adminYayasan),
    _MenuEntry(
        icon: Icons.summarize_outlined,
        label: 'Laporan Harian',
        route: Routes.adminLaporanHarian),
    _MenuEntry(
        icon: Icons.group_outlined, label: 'Alumni', route: Routes.adminAlumni),
    _MenuEntry(
        icon: Icons.play_lesson_outlined, label: 'LMS', route: Routes.adminLms),
    _MenuEntry(
        icon: Icons.sos_outlined,
        label: 'Darurat',
        route: Routes.adminEmergency),
    _MenuEntry(
        icon: Icons.calendar_view_month_outlined,
        label: 'Kalender',
        route: Routes.adminCalendar),
    _MenuEntry(
        icon: Icons.business_outlined,
        label: 'Sekolah',
        route: Routes.adminSchool),
    _MenuEntry(
        icon: Icons.lock_outlined,
        label: 'Kunci & Koreksi',
        route: Routes.adminAttendanceTools),
    _MenuEntry(
        icon: Icons.flag_outlined,
        label: 'Target Hafalan',
        route: Routes.adminHafalanTargets),
    _MenuEntry(
        icon: Icons.people_outline,
        label: 'Siswa',
        route: Routes.adminStudents),
    _MenuEntry(
        icon: Icons.badge_outlined, label: 'Staf', route: Routes.adminStaff),
    _MenuEntry(
        icon: Icons.assessment_outlined,
        label: 'Laporan',
        route: Routes.adminReports),
    _MenuEntry(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Anggaran',
        route: Routes.adminBudget),
    _MenuEntry(
        icon: Icons.mail_outline, label: 'Surat', route: Routes.adminLetters),
    _MenuEntry(
        icon: Icons.quiz_outlined,
        label: 'Kuis LMS',
        route: Routes.adminQuizzes),
    _MenuEntry(
        icon: Icons.info_outlined, label: 'Tentang', route: Routes.about),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu Modul')),
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
                        size: 32, color: Theme.of(context).colorScheme.primary),
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
