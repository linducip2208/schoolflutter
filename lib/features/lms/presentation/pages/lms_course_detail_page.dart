import 'package:flutter/material.dart';

import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/lms_repository.dart';
import 'quiz_attempt_page.dart';

/// Detail kursus: materi, selesaikan lesson, kuis, sertifikat.
/// Backend: `/lms/courses/{id}`, `/lms/complete-lesson`,
/// `/lms/quiz/submit`, `/lms/enrollments/{id}/certificate`.
class LmsCourseDetailPage extends StatefulWidget {
  const LmsCourseDetailPage(
      {super.key, required this.courseId, required this.title});
  final int courseId;
  final String title;

  @override
  State<LmsCourseDetailPage> createState() => _LmsCourseDetailPageState();
}

class _LmsCourseDetailPageState extends State<LmsCourseDetailPage> {
  final LmsRepository _repo = LmsRepository();
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.courseDetail(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder:
            (BuildContext c, AsyncSnapshot<Map<String, dynamic>> snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Padding(
                padding: EdgeInsets.all(24), child: AppLoading());
          }
          if (snap.hasError) {
            return ListView(children: <Widget>[
              AppError(
                message: snap.error.toString(),
                onRetry: () => setState(() {
                  _future = _repo.courseDetail(widget.courseId);
                }),
              ),
            ]);
          }
          final Map<String, dynamic> d = snap.data ?? const <String, dynamic>{};
          final List<dynamic> lessons =
              (d['lessons'] as List?) ?? const <dynamic>[];
          final List<dynamic> quizzes =
              (d['quizzes'] as List?) ?? const <dynamic>[];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              FilledButton.tonal(
                onPressed: () async {
                  await runMutation(
                      context, () => _repo.enroll(widget.courseId));
                },
                child: const Text('Enroll Kursus Ini'),
              ),
              const SizedBox(height: 12),
              Text('Materi',
                  style: Theme.of(context).textTheme.titleSmall),
              for (final dynamic l in lessons)
                Card(
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.article_outlined),
                    title: Text((l as Map)['title']?.toString() ?? '-'),
                    trailing: IconButton(
                      tooltip: 'Tandai selesai',
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: () async {
                        await runMutation(
                          context,
                          () => _repo.completeLesson(
                              ((l as Map)['id'] as num).toInt()),
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Text('Kuis', style: Theme.of(context).textTheme.titleSmall),
              for (final dynamic q in quizzes)
                Card(
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.quiz_outlined),
                    title:
                        Text((q as Map)['title']?.toString() ?? 'Kuis'),
                    subtitle: Text(
                        '${(q as Map)['questions_count'] ?? '-'} soal'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => QuizAttemptPage(
                          quizId: ((q as Map)['id'] as num).toInt(),
                          title: (q as Map)['title']?.toString() ?? 'Kuis',
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
