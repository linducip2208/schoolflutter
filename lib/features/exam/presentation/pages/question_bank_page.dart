import 'package:flutter/material.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/exam_repository.dart';
import '../../data/question_bank_repository.dart';

/// Bank soal: kategori, item soal, generate ujian otomatis.
/// Backend: `/question-bank/*`.
class QuestionBankPage extends StatelessWidget {
  const QuestionBankPage({super.key});

  @override
  Widget build(BuildContext context) {
    final QuestionBankRepository repo = QuestionBankRepository();
    return ModuleListPage(
      title: 'Bank Soal',
      loader: repo.items,
      pagedLoader: ({required int page}) => repo.items(page: page),
      pageSize: 50,
      emptyText: 'Belum ada soal.',
      actions: <Widget>[
        IconButton(
          tooltip: 'Generate paket soal',
          icon: const Icon(Icons.auto_awesome_outlined),
          onPressed: () => _generate(context, repo),
        ),
      ],
      onCreate: () async {
        final Map<String, String>? v = await showFormDialog(
          context,
          title: 'Soal Baru',
          fields: const <FormFieldDef>[
            FormFieldDef(key: 'subject_id', label: 'ID Mapel', isNumber: true),
            FormFieldDef(key: 'question_html', label: 'Pertanyaan'),
            FormFieldDef(
                key: 'type',
                label: 'Tipe',
                options: <String>['mcq', 'true_false', 'essay']),
            FormFieldDef(key: 'answer_key', label: 'Kunci (pisah koma)'),
            FormFieldDef(
                key: 'difficulty',
                label: 'Kesulitan',
                options: <String>['easy', 'medium', 'hard']),
            FormFieldDef(
                key: 'cognitive_level',
                label: 'Level Kognitif',
                options: <String>['c1', 'c2', 'c3', 'c4', 'c5', 'c6']),
          ],
        );
        if (v == null || !context.mounted) return;
        await runMutation(
          context,
          () => repo.store(
            subjectId: int.parse(v['subject_id']!),
            questionHtml: v['question_html']!,
            type: v['type']!,
            answerKey: v['answer_key']!
                .split(',')
                .map((String s) => s.trim())
                .where((String s) => s.isNotEmpty)
                .toList(),
            difficulty: v['difficulty']!,
            cognitiveLevel: v['cognitive_level']!,
          ),
        );
      },
      itemBuilder: (BuildContext c, Map<String, dynamic> e) => Card(
        child: ListTile(
          leading: const Icon(Icons.help_outline),
          title: Text(
            (e['question_html'] ?? e['question'] ?? '-').toString(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
              '${e['type'] ?? '-'} • ${e['difficulty'] ?? '-'} • ${e['cognitive_level'] ?? '-'}'),
        ),
      ),
    );
  }

  /// Generate paket soal dari bank lalu lampirkan ke ujian.
  /// Tipe yang kompatibel dengan soal ujian: mcq, true_false, essay.
  static const List<String> _compatible = <String>[
    'mcq',
    'true_false',
    'essay'
  ];

  Future<void> _generate(
      BuildContext context, QuestionBankRepository repo) async {
    final Map<String, String>? v = await showFormDialog(
      context,
      title: 'Generate Paket Soal',
      fields: const <FormFieldDef>[
        FormFieldDef(key: 'subject_id', label: 'ID Mapel', isNumber: true),
        FormFieldDef(key: 'easy', label: 'Jumlah mudah', isNumber: true),
        FormFieldDef(key: 'medium', label: 'Jumlah sedang', isNumber: true),
        FormFieldDef(key: 'hard', label: 'Jumlah sukar', isNumber: true),
      ],
    );
    if (v == null || !context.mounted) return;
    List<Map<String, dynamic>> items = const <Map<String, dynamic>>[];
    String? error;
    try {
      items = await repo.generateExam(
        subjectId: int.parse(v['subject_id']!),
        easy: int.tryParse(v['easy']!) ?? 0,
        medium: int.tryParse(v['medium']!) ?? 0,
        hard: int.tryParse(v['hard']!) ?? 0,
      );
    } catch (e) {
      error = e.toString();
    }
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    final List<Map<String, dynamic>> usable = items
        .where((Map<String, dynamic> e) =>
            _compatible.contains(e['type']?.toString()))
        .toList();
    final int skipped = items.length - usable.length;
    if (usable.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Tidak ada soal kompatibel (mcq/true_false/essay).')),
      );
      return;
    }
    final Map<String, String>? target = await showFormDialog(
      context,
      title: 'Hasil Generate (${usable.length} soal'
          '${skipped > 0 ? ', $skipped tipe tak kompatibel dilewati' : ''})',
      fields: const <FormFieldDef>[
        FormFieldDef(
            key: 'exam_id', label: 'Lampirkan ke ID Ujian', isNumber: true),
      ],
    );
    if (target == null || !context.mounted) return;
    final ExamRepository exams = ExamRepository();
    int attached = 0;
    final bool ok = await runMutation(context, () async {
      for (final Map<String, dynamic> q in usable) {
        final List<dynamic> keys =
            (q['answer_key'] as List?) ?? const <dynamic>[];
        await exams.addQuestion(
          int.parse(target['exam_id']!),
          question: (q['question_html'] ?? q['question'] ?? '').toString(),
          type: q['type'].toString(),
          correctAnswer: keys.isNotEmpty ? keys.first.toString() : null,
          marks: 10,
        );
        attached++;
      }
    });
    if (ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$attached soal dilampirkan.')),
      );
    }
  }
}
