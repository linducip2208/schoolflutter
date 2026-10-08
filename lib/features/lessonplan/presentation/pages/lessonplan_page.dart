import 'package:flutter/material.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/lessonplan_repository.dart';

/// RPP digital: buat, submit, approve/reject, tandai terlaksana.
/// Backend: `/lesson-plans/*`.
class LessonPlanPage extends StatelessWidget {
  const LessonPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LessonPlanRepository repo = LessonPlanRepository();
    return ModuleListPage(
      title: 'RPP / Lesson Plan',
      loader: repo.list,
      emptyText: 'Belum ada RPP.',
      onCreate: () async {
        final Map<String, String>? v = await showFormDialog(
          context,
          title: 'RPP Baru',
          fields: const <FormFieldDef>[
            FormFieldDef(key: 'class_section_id', label: 'ID Rombel', isNumber: true),
            FormFieldDef(key: 'subject_id', label: 'ID Mapel', isNumber: true),
            FormFieldDef(key: 'title', label: 'Judul'),
            FormFieldDef(key: 'lesson_date', label: 'Tanggal (YYYY-MM-DD)', hint: '2026-10-15'),
            FormFieldDef(key: 'duration_minutes', label: 'Durasi (menit)', isNumber: true, initial: '90'),
            FormFieldDef(key: 'objective', label: 'Tujuan pembelajaran'),
            FormFieldDef(key: 'material', label: 'Ringkasan materi'),
            FormFieldDef(key: 'activity', label: 'Aktivitas'),
          ],
        );
        if (v == null || !context.mounted) return;
        await runMutation(
          context,
          () => repo.store(
            classSectionId: int.parse(v['class_section_id']!),
            subjectId: int.parse(v['subject_id']!),
            title: v['title']!,
            lessonDate: v['lesson_date']!,
            durationMinutes: int.tryParse(v['duration_minutes']!) ?? 90,
            objectives: <String>[v['objective']!],
            materialSummary: v['material']!,
            activities: <String>[v['activity']!],
          ),
        );
      },
      itemBuilder: (BuildContext c, Map<String, dynamic> e) {
        final int id = (e['id'] as num).toInt();
        return Card(
          child: ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(e['title']?.toString() ?? '-'),
            subtitle: Text(
                'Status ${e['status'] ?? '-'} • ${e['lesson_date'] ?? '-'}'),
            trailing: PopupMenuButton<String>(
              onSelected: (String v) async {
                if (v == 'submit') {
                  await runMutation(c, () => repo.submit(id));
                } else if (v == 'approve') {
                  await runMutation(c, () => repo.approve(id));
                } else if (v == 'done') {
                  await runMutation(c, () => repo.markExecuted(id));
                } else if (v == 'reject') {
                  final Map<String, String>? f = await showFormDialog(
                    c,
                    title: 'Tolak RPP',
                    fields: const <FormFieldDef>[
                      FormFieldDef(key: 'feedback', label: 'Alasan penolakan'),
                    ],
                  );
                  if (f == null || !c.mounted) return;
                  await runMutation(c, () => repo.reject(id, f['feedback']!));
                }
              },
              itemBuilder: (_) => const <PopupMenuItem<String>>[
                PopupMenuItem<String>(value: 'submit', child: Text('Submit')),
                PopupMenuItem<String>(value: 'approve', child: Text('Approve')),
                PopupMenuItem<String>(value: 'reject', child: Text('Reject')),
                PopupMenuItem<String>(
                    value: 'done', child: Text('Tandai terlaksana')),
              ],
            ),
          ),
        );
      },
    );
  }
}
