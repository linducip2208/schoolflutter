import 'package:flutter/material.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/marks_repository.dart';

/// Input nilai batch + generate raport.
/// Backend: `POST /marks/bulk {marks:[...]}` → `{saved:N}`,
/// `POST /report-cards/generate {semester_id}` → `{generated:N}`.
class MarksBulkPage extends StatelessWidget {
  const MarksBulkPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MarksRepository repo = MarksRepository();
    return ModuleListPage(
      title: 'Input Nilai Batch',
      loader: repo.gradeSystems,
      emptyText: 'Belum ada sistem grading. Tambahkan nilai di bawah.',
      actions: <Widget>[
        IconButton(
          tooltip: 'Publish raport by ID',
          icon: const Icon(Icons.publish_outlined),
          onPressed: () async {
            final Map<String, String>? v = await showFormDialog(
              context,
              title: 'Publish Raport',
              fields: const <FormFieldDef>[
                FormFieldDef(
                    key: 'report_card_id', label: 'ID Raport', isNumber: true),
              ],
            );
            if (v == null || !context.mounted) return;
            await runMutation(
              context,
              () => repo.publishReportCard(int.parse(v['report_card_id']!)),
            );
          },
        ),
        IconButton(
          tooltip: 'Generate raport',
          icon: const Icon(Icons.picture_as_pdf_outlined),
          onPressed: () async {
            final Map<String, String>? v = await showFormDialog(
              context,
              title: 'Generate Raport',
              fields: const <FormFieldDef>[
                FormFieldDef(
                    key: 'semester_id', label: 'ID Semester', isNumber: true),
              ],
            );
            if (v == null || !context.mounted) return;
            final List<int> saved = <int>[];
            await runMutation(context, () async {
              final int n =
                  await repo.generateReportCards(int.parse(v['semester_id']!));
              saved.add(n);
            });
            if (context.mounted && saved.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${saved.first} raport dibuat.')),
              );
            }
          },
        ),
      ],
      onCreate: () async {
        final Map<String, String>? v = await showFormDialog(
          context,
          title: 'Input Nilai',
          fields: const <FormFieldDef>[
            FormFieldDef(key: 'student_id', label: 'ID Siswa', isNumber: true),
            FormFieldDef(key: 'subject_id', label: 'ID Mapel', isNumber: true),
            FormFieldDef(
                key: 'semester_id', label: 'ID Semester', isNumber: true),
            FormFieldDef(
                key: 'obtained', label: 'Nilai diperoleh', isNumber: true),
            FormFieldDef(
                key: 'total',
                label: 'Nilai maksimal',
                isNumber: true,
                initial: '100'),
          ],
        );
        if (v == null || !context.mounted) return;
        await runMutation(
          context,
          () => repo.bulk(<Map<String, dynamic>>[
            <String, dynamic>{
              'student_id': int.parse(v['student_id']!),
              'subject_id': int.parse(v['subject_id']!),
              'semester_id': int.parse(v['semester_id']!),
              'obtained_marks': int.parse(v['obtained']!),
              'total_marks': int.tryParse(v['total']!) ?? 100,
            },
          ]),
        );
      },
      itemBuilder: (BuildContext c, Map<String, dynamic> e) => Card(
        child: ListTile(
          leading: const Icon(Icons.grade_outlined),
          title: Text(e['name']?.toString() ?? 'Sistem grading'),
          subtitle: Text((e['rules'] is List)
              ? '${(e['rules'] as List).length} aturan'
              : e.toString()),
        ),
      ),
    );
  }
}
