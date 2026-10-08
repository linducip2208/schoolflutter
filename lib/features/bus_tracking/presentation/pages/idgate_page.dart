import 'package:flutter/material.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/bus_tracking_repository.dart';

/// ID Gate: terbitkan kartu + putar QR (RFID/QR check-in/out).
/// Backend: `/admin/students/{id}/id-card`, `/admin/id-cards/{id}/rotate-qr`.
/// Riwayat scan per anak ada di halaman Bus Tracking.
class IdGatePage extends StatelessWidget {
  const IdGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final BusTrackingRepository repo = BusTrackingRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('ID Gate')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: const Text('Terbitkan kartu ID'),
              subtitle:
                  const Text('Buat kartu gerbang elektronik untuk siswa.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final Map<String, String>? v = await showFormDialog(
                  context,
                  title: 'Terbitkan Kartu',
                  fields: const <FormFieldDef>[
                    FormFieldDef(
                        key: 'student_id', label: 'ID Siswa', isNumber: true),
                  ],
                );
                if (v == null || !context.mounted) return;
                Map<String, dynamic>? card;
                await runMutation(context, () async {
                  card = await repo.issueCard(int.parse(v['student_id']!));
                });
                if (context.mounted && card != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Kartu #${card!['id']} diterbitkan.')),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.qr_code_2_outlined),
              title: const Text('Putar QR kartu'),
              subtitle: const Text('Regenerasi QR bila bocor/hilang.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final Map<String, String>? v = await showFormDialog(
                  context,
                  title: 'Putar QR',
                  fields: const <FormFieldDef>[
                    FormFieldDef(key: 'card_id', label: 'ID Kartu', isNumber: true),
                  ],
                );
                if (v == null || !context.mounted) return;
                await runMutation(
                  context,
                  () => repo.rotateQr(int.parse(v['card_id']!)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
