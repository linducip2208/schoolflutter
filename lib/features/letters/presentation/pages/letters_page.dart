import 'package:flutter/material.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/letters_repository.dart';

/// Surat-menyurat: daftar + buat (nomor otomatis server).
/// Backend: `/letters*`.
class LettersPage extends StatelessWidget {
  const LettersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LettersRepository repo = LettersRepository();
    return ModuleListPage(
      title: 'Surat',
      loader: repo.list,
      emptyText: 'Belum ada surat.',
      onCreate: () async {
        final Map<String, String>? v = await showFormDialog(
          context,
          title: 'Surat Baru',
          fields: const <FormFieldDef>[
            FormFieldDef(
                key: 'recipient_type',
                label: 'Penerima',
                options: <String>['student', 'staff', 'other']),
            FormFieldDef(key: 'recipient_name', label: 'Nama penerima'),
            FormFieldDef(key: 'subject', label: 'Perihal'),
            FormFieldDef(key: 'content', label: 'Isi surat'),
            FormFieldDef(
                key: 'status',
                label: 'Status',
                options: <String>['draft', 'sent']),
          ],
        );
        if (v == null || !context.mounted) return;
        await runMutation(
          context,
          () => repo.store(
            recipientType: v['recipient_type']!,
            recipientName: v['recipient_name']!,
            subject: v['subject']!,
            content: v['content']!,
            status: v['status']!,
          ),
        );
      },
      itemBuilder: (BuildContext c, Map<String, dynamic> e) {
        final int id = (e['id'] as num).toInt();
        return Card(
          child: ListTile(
            leading: const Icon(Icons.mail_outline),
            title: Text(e['subject']?.toString() ?? '-'),
            subtitle: Text(
                '${e['letter_number'] ?? '-'} • ${e['recipient_name'] ?? '-'} • ${e['status'] ?? '-'}'),
            trailing: IconButton(
              tooltip: 'Kirim',
              icon: const Icon(Icons.send_outlined),
              onPressed: () async {
                await runMutation(c, () => repo.updateStatus(id, 'sent'));
              },
            ),
          ),
        );
      },
    );
  }
}
