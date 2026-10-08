import 'package:flutter/material.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/attendance_repository.dart';

/// Kunci/buka absensi + koreksi kehadiran.
/// Backend: `/attendance/class/{id}/lock|reopen`, `/attendance/corrections*`.
class AttendanceToolsPage extends StatelessWidget {
  const AttendanceToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AttendanceRepository repo = AttendanceRepository();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kunci & Koreksi'),
          bottom: const TabBar(
            tabs: <Widget>[Tab(text: 'Kunci'), Tab(text: 'Koreksi')],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.lock_outlined),
                    title: const Text('Kunci / buka absensi rombel'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final Map<String, String>? v = await showFormDialog(
                        context,
                        title: 'Kunci Absensi',
                        fields: const <FormFieldDef>[
                          FormFieldDef(
                              key: 'section_id',
                              label: 'ID Rombel',
                              isNumber: true),
                          FormFieldDef(
                              key: 'aksi',
                              label: 'Aksi',
                              options: <String>['lock', 'reopen']),
                        ],
                      );
                      if (v == null || !context.mounted) return;
                      final int id = int.parse(v['section_id']!);
                      await runMutation(
                        context,
                        () => v['aksi'] == 'lock'
                            ? repo.lock(id)
                            : repo.reopen(id),
                      );
                    },
                  ),
                ),
              ],
            ),
            ModuleListPage(
              title: 'Koreksi',
              loader: repo.corrections,
              emptyText: 'Tidak ada pengajuan koreksi.',
              itemBuilder: (BuildContext c, Map<String, dynamic> e) {
                final int id = (e['id'] as num?)?.toInt() ??
                    (e['workflow_request_id'] as num?)?.toInt() ??
                    0;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.edit_note_outlined),
                    title: Text(e['reason']?.toString() ?? 'Koreksi #$id'),
                    subtitle: Text('${e['status'] ?? '-'}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          tooltip: 'Setujui',
                          icon: const Icon(Icons.check_circle_outline),
                          onPressed: () async {
                            await runMutation(
                                c, () => repo.approveCorrection(id));
                          },
                        ),
                        IconButton(
                          tooltip: 'Tolak',
                          icon: const Icon(Icons.cancel_outlined),
                          onPressed: () async {
                            await runMutation(
                                c, () => repo.rejectCorrection(id));
                          },
                        ),
                      ],
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
