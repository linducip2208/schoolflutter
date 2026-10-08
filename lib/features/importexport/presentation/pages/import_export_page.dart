import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/module_list_page.dart';
import '../../data/import_export_repository.dart';

/// Bulk import siswa (CSV) + export nilai/keuangan (CSV).
/// Backend: `POST /import/students` (multipart `file`),
/// `GET /export/marks`, `GET /export/fee-collection`.
class ImportExportPage extends StatelessWidget {
  const ImportExportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ImportExportRepository repo = ImportExportRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('Import / Export')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: ListTile(
              leading: const Icon(Icons.upload_file_outlined),
              title: const Text('Import siswa (CSV)'),
              subtitle: const Text('Pilih file CSV sesuai template.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final FilePickerResult? picked = await FilePicker.platform
                    .pickFiles(type: FileType.custom, allowedExtensions: <String>['csv']);
                final String? path = picked?.files.single.path;
                if (path == null || !context.mounted) return;
                await runMutation(
                    context, () => repo.importStudents(path));
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('Export nilai (CSV)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                await runMutation(
                    context, () => repo.downloadExport('marks'));
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('Export keuangan (CSV)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                await runMutation(
                    context, () => repo.downloadExport('fee'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
