import 'package:flutter/material.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/discipline_repository.dart';

/// Disiplin: kategori, records, leaderboard.
/// Backend: `/discipline/*` (`discipline.manage` untuk catat).
class DisciplinePage extends StatelessWidget {
  const DisciplinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final DisciplineRepository repo = DisciplineRepository();
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Disiplin'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Records'),
              Tab(text: 'Kategori'),
              Tab(text: 'Leaderboard'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            ModuleListPage(
              title: 'Records',
              loader: repo.records,
              emptyText: 'Belum ada records.',
              onCreate: () async {
                final Map<String, String>? v = await showFormDialog(
                  context,
                  title: 'Catat Pelanggaran',
                  fields: const <FormFieldDef>[
                    FormFieldDef(key: 'student_id', label: 'ID Siswa', isNumber: true),
                    FormFieldDef(
                        key: 'discipline_category_id',
                        label: 'ID Kategori',
                        isNumber: true),
                    FormFieldDef(key: 'description', label: 'Deskripsi'),
                  ],
                );
                if (v == null || !context.mounted) return;
                await runMutation(
                  context,
                  () => repo.storeRecord(
                    studentId: int.parse(v['student_id']!),
                    categoryId: int.parse(v['discipline_category_id']!),
                    description: v['description']!,
                  ),
                );
              },
              itemBuilder: (BuildContext c, Map<String, dynamic> e) =>
                  Card(
                child: ListTile(
                  leading: const Icon(Icons.gavel_outlined),
                  title: Text(e['description']?.toString() ?? '-',
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                      'Siswa ${e['student_id'] ?? '-'} • ${e['incident_date'] ?? e['created_at'] ?? '-'}'),
                ),
              ),
            ),
            ModuleListPage(
              title: 'Kategori',
              loader: repo.categories,
              emptyText: 'Belum ada kategori.',
              onCreate: () async {
                final Map<String, String>? v = await showFormDialog(
                  context,
                  title: 'Kategori Baru',
                  fields: const <FormFieldDef>[
                    FormFieldDef(key: 'name', label: 'Nama'),
                    FormFieldDef(
                        key: 'type',
                        label: 'Tipe',
                        options: <String>['violation', 'achievement']),
                    FormFieldDef(key: 'point_value', label: 'Poin', isNumber: true, initial: '10'),
                  ],
                );
                if (v == null || !context.mounted) return;
                await runMutation(
                  context,
                  () => repo.storeCategory(
                    name: v['name']!,
                    type: v['type']!,
                    pointValue: int.tryParse(v['point_value']!) ?? 10,
                  ),
                );
              },
              itemBuilder: (BuildContext c, Map<String, dynamic> e) =>
                  Card(
                child: ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: Text(e['name']?.toString() ?? '-'),
                  subtitle:
                      Text('${e['type'] ?? '-'} • ${e['point_value'] ?? 0} poin'),
                ),
              ),
            ),
            ModuleListPage(
              title: 'Leaderboard',
              loader: repo.leaderboard,
              emptyText: 'Belum ada data.',
              itemBuilder: (BuildContext c, Map<String, dynamic> e) =>
                  Card(
                child: ListTile(
                  leading: const Icon(Icons.leaderboard_outlined),
                  title: Text(
                      e['name']?.toString() ?? 'Siswa ${e['student_id']}'),
                  trailing: Text('${e['points'] ?? e['total_points'] ?? 0}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
