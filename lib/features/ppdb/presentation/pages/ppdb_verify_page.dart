import 'package:flutter/material.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/ppdb_repository.dart';

/// Verifikasi PPDB: daftar pendaftar + verify/accept/reject + laporan.
/// Backend: `/admin/ppdb/*` (`ppdb.review`).
class PpdbVerifyPage extends StatelessWidget {
  const PpdbVerifyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PpdbRepository repo = PpdbRepository();
    return ModuleListPage(
      title: 'Verifikasi PPDB',
      loader: repo.adminApplications,
      emptyText: 'Belum ada pendaftar.',
      actions: <Widget>[
        IconButton(
          tooltip: 'Laporan',
          icon: const Icon(Icons.summarize_outlined),
          onPressed: () => _showReports(context, repo),
        ),
      ],
      itemBuilder: (BuildContext c, Map<String, dynamic> e) {
        final int id = (e['id'] as num).toInt();
        return Card(
          child: ListTile(
            leading: const Icon(Icons.person_add_outlined),
            title: Text(e['student_name']?.toString() ?? '-'),
            subtitle: Text(
                'Jalur ${e['jalur'] ?? '-'} • Status ${e['status'] ?? '-'}'),
            trailing: PopupMenuButton<String>(
              onSelected: (String v) async {
                if (v == 'verify') {
                  await runMutation(c, () => repo.verify(id));
                } else if (v == 'accept') {
                  await runMutation(c, () => repo.accept(id));
                } else if (v == 'reject') {
                  final Map<String, String>? f = await showFormDialog(
                    c,
                    title: 'Tolak Pendaftar',
                    fields: const <FormFieldDef>[
                      FormFieldDef(key: 'note', label: 'Alasan penolakan'),
                    ],
                  );
                  if (f == null || !c.mounted) return;
                  await runMutation(c, () => repo.reject(id, f['note']!));
                }
              },
              itemBuilder: (_) => const <PopupMenuItem<String>>[
                PopupMenuItem<String>(
                    value: 'verify', child: Text('Verifikasi')),
                PopupMenuItem<String>(value: 'accept', child: Text('Terima')),
                PopupMenuItem<String>(value: 'reject', child: Text('Tolak')),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showReports(BuildContext c, PpdbRepository repo) async {
    Map<String, dynamic> data = const <String, dynamic>{};
    String? error;
    try {
      data = await repo.reports();
    } catch (err) {
      error = err.toString();
    }
    if (!c.mounted) return;
    await showDialog<void>(
      context: c,
      builder: (BuildContext d) => AlertDialog(
        title: const Text('Laporan PPDB'),
        content: Text(error ?? data.toString()),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(d).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
