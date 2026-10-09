import 'package:flutter/material.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/curriculum_repository.dart';

/// Kurikulum & CP/TP: kerangka + kompetensi.
/// Backend: `/curriculum/*`.
class CurriculumPage extends StatelessWidget {
  const CurriculumPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CurriculumRepository repo = CurriculumRepository();
    return ModuleListPage(
      title: 'Kurikulum',
      loader: repo.frameworks,
      emptyText: 'Belum ada kerangka kurikulum.',
      onCreate: () async {
        final Map<String, String>? v = await showFormDialog(
          context,
          title: 'Kerangka Baru',
          fields: const <FormFieldDef>[
            FormFieldDef(key: 'name', label: 'Nama (mis. Kurikulum Merdeka)'),
            FormFieldDef(key: 'type', label: 'Tipe', options: <String>[
              'merdeka',
              'k13',
              'cambridge',
              'ib',
              'custom'
            ]),
          ],
        );
        if (v == null || !context.mounted) return;
        await runMutation(
          context,
          () => repo.storeFramework(name: v['name']!, type: v['type']!),
        );
      },
      itemBuilder: (BuildContext c, Map<String, dynamic> e) {
        final int id = (e['id'] as num).toInt();
        return Card(
          child: ListTile(
            leading: const Icon(Icons.account_tree_outlined),
            title: Text(e['name']?.toString() ?? '-'),
            subtitle: Text(
                'Tipe ${e['type'] ?? '-'} • Aktif ${e['is_active'] ?? '-'}'),
            onTap: () => _showCompetencies(c, repo, id, e['name']?.toString()),
            trailing: IconButton(
              tooltip: 'Tambah kompetensi',
              icon: const Icon(Icons.add),
              onPressed: () async {
                final Map<String, String>? v = await showFormDialog(
                  c,
                  title: 'Kompetensi Baru',
                  fields: const <FormFieldDef>[
                    FormFieldDef(
                        key: 'subject_id', label: 'ID Mapel', isNumber: true),
                    FormFieldDef(
                        key: 'class_room_id',
                        label: 'ID Kelas',
                        isNumber: true),
                    FormFieldDef(key: 'code', label: 'Kode (mis. CP-1)'),
                    FormFieldDef(key: 'description', label: 'Deskripsi'),
                    FormFieldDef(
                        key: 'level_type',
                        label: 'Level',
                        options: <String>['cp', 'tp', 'ki', 'kd', 'outcome']),
                  ],
                );
                if (v == null || !c.mounted) return;
                await runMutation(
                  c,
                  () => repo.storeCompetency(
                    frameworkId: id,
                    subjectId: int.parse(v['subject_id']!),
                    classRoomId: int.parse(v['class_room_id']!),
                    code: v['code']!,
                    description: v['description']!,
                    levelType: v['level_type']!,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _showCompetencies(BuildContext c, CurriculumRepository repo,
      int frameworkId, String? name) async {
    List<Map<String, dynamic>> items = const <Map<String, dynamic>>[];
    String? error;
    try {
      items = await repo.competencies(frameworkId: frameworkId);
    } catch (err) {
      error = err.toString();
    }
    if (!c.mounted) return;
    await showDialog<void>(
      context: c,
      builder: (BuildContext d) => AlertDialog(
        title: Text('Kompetensi — ${name ?? ''}'),
        content: SizedBox(
          width: double.maxFinite,
          child: error != null
              ? Text(error)
              : items.isEmpty
                  ? const Text('Belum ada kompetensi.')
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          for (final Map<String, dynamic> e in items)
                            ListTile(
                              dense: true,
                              title: Text(
                                  '${e['code'] ?? '-'} • ${e['level_type'] ?? '-'}'),
                              subtitle: Text(
                                  e['description']?.toString() ?? '-',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                            ),
                        ],
                      ),
                    ),
        ),
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
