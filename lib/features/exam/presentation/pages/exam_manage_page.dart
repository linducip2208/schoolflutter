import 'package:flutter/material.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/exam_repository.dart';

/// Kelola ujian: buat, hapus, tambah soal, lihat submissions.
/// Backend: `/exams` CRUD + `/exams/{id}/questions|submissions`.
class ExamManagePage extends StatelessWidget {
  const ExamManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ExamRepository repo = ExamRepository();
    return ModuleListPage(
      title: 'Kelola Ujian',
      loader: repo.list,
      emptyText: 'Belum ada ujian.',
      onCreate: () async {
        final Map<String, String>? v = await showFormDialog(
          context,
          title: 'Ujian Baru',
          fields: const <FormFieldDef>[
            FormFieldDef(key: 'class_section_id', label: 'ID Rombel', isNumber: true),
            FormFieldDef(key: 'subject_id', label: 'ID Mapel', isNumber: true),
            FormFieldDef(key: 'title', label: 'Judul'),
            FormFieldDef(
                key: 'type',
                label: 'Tipe',
                options: <String>['offline', 'online']),
          ],
        );
        if (v == null || !context.mounted) return;
        await runMutation(
          context,
          () => repo.create(
            classSectionId: int.parse(v['class_section_id']!),
            subjectId: int.parse(v['subject_id']!),
            title: v['title']!,
            type: v['type']!,
          ),
        );
      },
      itemBuilder: (BuildContext c, Map<String, dynamic> e) => Card(
        child: ListTile(
          leading: const Icon(Icons.quiz_outlined),
          title: Text(e['title']?.toString() ?? '-'),
          subtitle: Text(
              'ID ${e['id']} • ${e['type'] ?? '-'} • ${e['start_at'] ?? '-'}'),
          trailing: PopupMenuButton<String>(
            onSelected: (String v) async {
              final int id = (e['id'] as num).toInt();
              if (v == 'soal') {
                final Map<String, String>? q = await showFormDialog(
                  c,
                  title: 'Tambah Soal',
                  fields: const <FormFieldDef>[
                    FormFieldDef(key: 'question', label: 'Pertanyaan'),
                    FormFieldDef(
                        key: 'type',
                        label: 'Tipe',
                        options: <String>['mcq', 'true_false', 'essay']),
                    FormFieldDef(key: 'correct_answer', label: 'Kunci Jawaban'),
                    FormFieldDef(key: 'marks', label: 'Bobot', isNumber: true, initial: '10'),
                  ],
                );
                if (q == null || !c.mounted) return;
                await runMutation(
                  c,
                  () => repo.addQuestion(
                    id,
                    question: q['question']!,
                    type: q['type']!,
                    correctAnswer: q['correct_answer'],
                    marks: int.tryParse(q['marks'] ?? '') ?? 10,
                  ),
                );
              } else if (v == 'hapus') {
                if (c.mounted) {
                  await runMutation(c, () => repo.remove(id));
                }
              }
            },
            itemBuilder: (_) => const <PopupMenuItem<String>>[
              PopupMenuItem<String>(value: 'soal', child: Text('Tambah soal')),
              PopupMenuItem<String>(value: 'hapus', child: Text('Hapus')),
            ],
          ),
          onTap: () => _showSubmissions(c, repo, e),
        ),
      ),
    );
  }

  Future<void> _showSubmissions(
      BuildContext c, ExamRepository repo, Map<String, dynamic> e) async {
    final int id = (e['id'] as num).toInt();
    List<Map<String, dynamic>> items = const <Map<String, dynamic>>[];
    String? error;
    try {
      items = await repo.submissions(id);
    } catch (err) {
      error = err.toString();
    }
    if (!c.mounted) return;
    await showDialog<void>(
      context: c,
      builder: (BuildContext d) => AlertDialog(
        title: Text('Submissions — ${e['title']}'),
        content: SizedBox(
          width: double.maxFinite,
          child: error != null
              ? Text(error)
              : items.isEmpty
                  ? const Text('Belum ada submissions.')
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          for (final Map<String, dynamic> s in items)
                            ListTile(
                              dense: true,
                              title: Text(
                                  'Siswa ${s['student_id'] ?? s['student'] ?? '-'}'),
                              subtitle: Text(
                                  'Skor ${s['score'] ?? s['total_score'] ?? '-'}'),
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
