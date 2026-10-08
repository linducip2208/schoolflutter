import 'package:flutter/material.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/hafalan_repository.dart';

/// Target hafalan pesantren (rentang juz/surah + deadline).
/// Backend: `/religious/hafalan/targets`.
class HafalanTargetsPage extends StatelessWidget {
  const HafalanTargetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final HafalanRepository repo = HafalanRepository();
    return ModuleListPage(
      title: 'Target Hafalan',
      loader: repo.targets,
      emptyText: 'Belum ada target hafalan.',
      onCreate: () async {
        final Map<String, String>? v = await showFormDialog(
          context,
          title: 'Target Baru',
          fields: const <FormFieldDef>[
            FormFieldDef(key: 'name', label: 'Nama target'),
            FormFieldDef(
                key: 'ranges',
                label: 'Rentang (pisah koma)',
                hint: 'Juz 1, Juz 2'),
            FormFieldDef(key: 'start_date', label: 'Mulai (YYYY-MM-DD)'),
            FormFieldDef(key: 'deadline', label: 'Deadline (YYYY-MM-DD)'),
          ],
        );
        if (v == null || !context.mounted) return;
        await runMutation(
          context,
          () => repo.storeTarget(
            name: v['name']!,
            ranges: v['ranges']!
                .split(',')
                .map((String s) => s.trim())
                .where((String s) => s.isNotEmpty)
                .toList(),
            startDate: v['start_date']!,
            deadline: v['deadline']!,
          ),
        );
      },
      itemBuilder: (BuildContext c, Map<String, dynamic> e) => Card(
        child: ListTile(
          leading: const Icon(Icons.menu_book_outlined),
          title: Text(e['name']?.toString() ?? '-'),
          subtitle: Text(
              '${(e['target_ranges'] is List) ? (e['target_ranges'] as List).join(', ') : '-'} • s/d ${e['deadline'] ?? '-'}'),
        ),
      ),
    );
  }
}
