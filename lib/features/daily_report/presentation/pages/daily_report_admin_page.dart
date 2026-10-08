import 'package:flutter/material.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/daily_report_repository.dart';

/// Daily report admin: generate + kirim ke wali.
/// Backend: `POST /admin/daily-reports/generate {date?}`,
/// `POST /admin/daily-reports/{id}/send` (`role:admin`).
class DailyReportAdminPage extends StatelessWidget {
  const DailyReportAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DailyReportRepository repo = DailyReportRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Report')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: ListTile(
              leading: const Icon(Icons.auto_awesome_outlined),
              title: const Text('Generate laporan harian'),
              subtitle:
                  const Text('Buat laporan seluruh sekolah per tanggal.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final Map<String, String>? v = await showFormDialog(
                  context,
                  title: 'Generate Laporan',
                  fields: const <FormFieldDef>[
                    FormFieldDef(
                        key: 'date',
                        label: 'Tanggal (YYYY-MM-DD, kosongkan=hari ini)',
                        optional: true),
                  ],
                );
                if (v == null || !context.mounted) return;
                int n = 0;
                await runMutation(context, () async {
                  final Map<String, dynamic> res =
                      await repo.generate(<String, dynamic>{
                    if (v['date']!.isNotEmpty) 'date': v['date']!,
                  });
                  n = (res['count'] as num?)?.toInt() ?? 0;
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$n laporan dibuat.')),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.send_outlined),
              title: const Text('Kirim laporan ke wali'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final Map<String, String>? v = await showFormDialog(
                  context,
                  title: 'Kirim Laporan',
                  fields: const <FormFieldDef>[
                    FormFieldDef(
                        key: 'id', label: 'ID Laporan', isNumber: true),
                  ],
                );
                if (v == null || !context.mounted) return;
                await runMutation(
                  context,
                  () => repo.send(int.parse(v['id']!)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
