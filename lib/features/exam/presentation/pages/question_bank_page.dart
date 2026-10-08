import 'package:flutter/material.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
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
      emptyText: 'Belum ada soal.',
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
}
