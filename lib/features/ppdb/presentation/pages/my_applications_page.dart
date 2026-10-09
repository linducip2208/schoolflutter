import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/ppdb_repository.dart';

/// Aplikasi PPDB saya: status + upload dokumen.
/// Backend: `/ppdb/applications/me`, `/{id}/upload-doc`
/// (pdf/jpg/png ≤10MB + doc_type).
class MyApplicationsPage extends StatelessWidget {
  const MyApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PpdbRepository repo = PpdbRepository();
    return ModuleListPage(
      title: 'Aplikasi PPDB Saya',
      loader: repo.myApplications,
      emptyText: 'Belum ada aplikasi. Daftar via PPDB Online.',
      itemBuilder: (BuildContext c, Map<String, dynamic> e) {
        final int id = (e['id'] as num).toInt();
        final String status = e['status']?.toString() ?? '-';
        return Card(
          child: ListTile(
            leading: const Icon(Icons.how_to_reg_outlined),
            title: Text(e['student_name']?.toString() ?? '-'),
            subtitle: Text('Jalur ${e['jalur'] ?? '-'} • Status $status'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (status == 'draft')
                  IconButton(
                    tooltip: 'Kirim aplikasi',
                    icon: const Icon(Icons.send_outlined),
                    onPressed: () async {
                      await runMutation(c, () => repo.submitApplication(id));
                    },
                  ),
                IconButton(
                  tooltip: 'Upload dokumen',
                  icon: const Icon(Icons.upload_file_outlined),
                  onPressed: () async {
                    final Map<String, String>? v = await showFormDialog(
                      c,
                      title: 'Jenis Dokumen',
                      fields: const <FormFieldDef>[
                        FormFieldDef(
                            key: 'doc_type',
                            label: 'Tipe (mis. kk, akta, foto)'),
                      ],
                    );
                    if (v == null || !c.mounted) return;
                    final FilePickerResult? picked =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: const <String>[
                        'pdf',
                        'jpg',
                        'jpeg',
                        'png'
                      ],
                    );
                    final String? path = picked?.files.single.path;
                    if (path == null || !c.mounted) return;
                    await runMutation(
                      c,
                      () => repo.uploadDoc(
                        applicationId: id,
                        filePath: path,
                        docType: v['doc_type']!,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
