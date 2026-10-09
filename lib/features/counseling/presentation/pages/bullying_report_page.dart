import 'package:flutter/material.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/wellness_repository.dart';

/// Lapor bullying — terbuka untuk semua peran terautentikasi.
/// Backend: `POST /counseling/bullying-reports` (tanpa permission khusus).
class BullyingReportPage extends StatelessWidget {
  const BullyingReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final WellnessRepository repo = WellnessRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('Lapor Bullying')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                  'Laporan Anda diteruskan ke tim BK. Identitas pelapor dilindungi.'),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            icon: const Icon(Icons.report_outlined),
            label: const Text('Buat Laporan'),
            onPressed: () async {
              final Map<String, String>? v = await showFormDialog(
                context,
                title: 'Laporan Baru',
                fields: const <FormFieldDef>[
                  FormFieldDef(key: 'type', label: 'Tipe', options: <String>[
                    'verbal',
                    'physical',
                    'cyber',
                    'social',
                    'other'
                  ]),
                  FormFieldDef(key: 'location', label: 'Lokasi'),
                  FormFieldDef(key: 'description', label: 'Deskripsi'),
                ],
              );
              if (v == null || !context.mounted) return;
              await runMutation(
                context,
                () => repo.reportBullying(
                  type: v['type']!,
                  description:
                      '${v['description']!}${v['location']!.isNotEmpty ? ' [${v['location']}]' : ''}',
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
