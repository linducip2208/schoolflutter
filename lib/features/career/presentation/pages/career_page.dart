import 'package:flutter/material.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/career_repository.dart';

/// Karier/BKK: magang + assessment.
/// Backend: `/career/*`.
class CareerPage extends StatelessWidget {
  const CareerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CareerRepository repo = CareerRepository();
    return ModuleListPage(
      title: 'Karier & Magang',
      loader: repo.internships,
      emptyText: 'Belum ada data magang.',
      onCreate: () async {
        final Map<String, String>? v = await showFormDialog(
          context,
          title: 'Magang Baru',
          fields: const <FormFieldDef>[
            FormFieldDef(key: 'student_id', label: 'ID Siswa', isNumber: true),
            FormFieldDef(key: 'company_name', label: 'Perusahaan'),
            FormFieldDef(key: 'position', label: 'Posisi'),
            FormFieldDef(key: 'start_date', label: 'Mulai (YYYY-MM-DD)'),
            FormFieldDef(key: 'end_date', label: 'Selesai (YYYY-MM-DD)'),
          ],
        );
        if (v == null || !context.mounted) return;
        await runMutation(
          context,
          () => repo.storeInternship(
            studentId: int.parse(v['student_id']!),
            company: v['company_name']!,
            position: v['position']!,
            startDate: v['start_date']!,
            endDate: v['end_date']!,
          ),
        );
      },
      itemBuilder: (BuildContext c, Map<String, dynamic> e) => Card(
        child: ListTile(
          leading: const Icon(Icons.work_outline),
          title: Text(
              '${e['position'] ?? '-'} @ ${e['company_name'] ?? e['company'] ?? '-'}'),
          subtitle: Text(
              'Siswa ${e['student_id'] ?? '-'} • Status ${e['status'] ?? '-'}'),
        ),
      ),
    );
  }
}
