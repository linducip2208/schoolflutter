import 'package:flutter/material.dart';

import '../../../../core/widgets/module_list_page.dart';
import '../../data/lms_repository.dart';
import 'quiz_attempt_page.dart';

/// Daftar kuis published + kerjakan.
/// Backend: `GET /lms/quizzes`, attempt via QuizAttemptPage.
class QuizzesPage extends StatelessWidget {
  const QuizzesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LmsRepository repo = LmsRepository();
    return ModuleListPage(
      title: 'Kuis',
      loader: repo.quizzes,
      emptyText: 'Belum ada kuis.',
      itemBuilder: (BuildContext c, Map<String, dynamic> e) {
        final int id = (e['id'] as num).toInt();
        return Card(
          child: ListTile(
            leading: const Icon(Icons.quiz_outlined),
            title: Text(e['title']?.toString() ?? '-'),
            subtitle: Text(
                '${e['questions_count'] ?? '-'} soal • Lulus ${e['pass_score'] ?? '-'}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(c).push(
              MaterialPageRoute<void>(
                builder: (_) => QuizAttemptPage(
                    quizId: id, title: e['title']?.toString() ?? 'Kuis'),
              ),
            ),
          ),
        );
      },
    );
  }
}
