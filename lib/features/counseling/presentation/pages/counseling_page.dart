import 'package:flutter/material.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/wellness_repository.dart';

/// BP/BK: sesi konseling + laporan bullying.
/// Backend: `/counseling/*`.
class CounselingPage extends StatelessWidget {
  const CounselingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final WellnessRepository repo = WellnessRepository();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Konseling (BK)'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Sesi'),
              Tab(text: 'Bullying'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            ModuleListPage(
              title: 'Sesi',
              loader: repo.sessions,
              pagedLoader: ({required int page}) => repo.sessions(page: page),
              pageSize: 50,
              emptyText: 'Belum ada sesi.',
              onCreate: () async {
                final Map<String, String>? v = await showFormDialog(
                  context,
                  title: 'Jadwalkan Sesi',
                  fields: const <FormFieldDef>[
                    FormFieldDef(
                        key: 'student_id', label: 'ID Siswa', isNumber: true),
                    FormFieldDef(
                        key: 'counselor_id',
                        label: 'ID Konselor',
                        isNumber: true),
                    FormFieldDef(
                        key: 'scheduled_at',
                        label: 'Jadwal (YYYY-MM-DD HH:MM)'),
                    FormFieldDef(key: 'type', label: 'Tipe', options: <String>[
                      'academic',
                      'behavior',
                      'mental_health',
                      'career',
                      'family',
                      'social'
                    ]),
                  ],
                );
                if (v == null || !context.mounted) return;
                await runMutation(
                  context,
                  () => repo.scheduleSession(
                    studentId: int.parse(v['student_id']!),
                    counselorId: int.parse(v['counselor_id']!),
                    scheduledAt: v['scheduled_at']!,
                    type: v['type']!,
                  ),
                );
              },
              itemBuilder: (BuildContext c, Map<String, dynamic> e) {
                final int id = (e['id'] as num?)?.toInt() ?? 0;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.forum_outlined),
                    title: Text(
                        'Siswa ${e['student_id'] ?? '-'} • ${e['type'] ?? '-'}'),
                    subtitle: Text(
                        '${e['scheduled_at'] ?? '-'} • ${e['status'] ?? '-'}'),
                    trailing: IconButton(
                      tooltip: 'Selesaikan',
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: () async {
                        await runMutation(c, () => repo.completeSession(id));
                      },
                    ),
                  ),
                );
              },
            ),
            ModuleListPage(
              title: 'Bullying',
              loader: repo.bullyingReports,
              pagedLoader: ({required int page}) =>
                  repo.bullyingReports(page: page),
              pageSize: 50,
              emptyText: 'Belum ada laporan.',
              onCreate: () async {
                final Map<String, String>? v = await showFormDialog(
                  context,
                  title: 'Lapor Bullying',
                  fields: const <FormFieldDef>[
                    FormFieldDef(key: 'type', label: 'Tipe', options: <String>[
                      'verbal',
                      'physical',
                      'cyber',
                      'social',
                      'other'
                    ]),
                    FormFieldDef(key: 'description', label: 'Deskripsi'),
                  ],
                );
                if (v == null || !context.mounted) return;
                await runMutation(
                  context,
                  () => repo.reportBullying(
                    type: v['type']!,
                    description: v['description']!,
                  ),
                );
              },
              itemBuilder: (BuildContext c, Map<String, dynamic> e) {
                final int id = (e['id'] as num?)?.toInt() ?? 0;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.report_outlined),
                    title: Text(e['description']?.toString() ?? '-',
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle:
                        Text('${e['type'] ?? '-'} • ${e['status'] ?? '-'}'),
                    trailing: IconButton(
                      tooltip: 'Tutup laporan',
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: () async {
                        await runMutation(c, () => repo.closeBullying(id));
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
