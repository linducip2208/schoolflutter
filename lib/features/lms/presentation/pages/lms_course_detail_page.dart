import 'package:flutter/material.dart';

import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/lms_repository.dart';
import 'quiz_attempt_page.dart';

/// Detail kursus: enroll, materi + tandai selesai, kuis, sertifikat.
/// Backend: `/lms/courses/{id}`, `/lms/enroll`, `/lms/complete-lesson`
/// (butuh enrollment_id + lesson_id), `/lms/enrollments/{id}/certificate`.
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
  int? _enrollmentId;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  /// Course detail + cari enrollment saya (untuk complete-lesson).
  Future<Map<String, dynamic>> _load() async {
    final Map<String, dynamic> detail =
        await _repo.courseDetail(widget.courseId);
    try {
      final Map<String, dynamic> progress = await _repo.progress();
      final List<dynamic> enrollments = (progress['enrollments'] as List?) ??
          (progress['data'] as List?) ??
          const <dynamic>[];
      for (final dynamic e in enrollments) {
        final Map<String, dynamic> m = Map<String, dynamic>.from(e as Map);
        final int? courseId = (m['course_id'] as num?)?.toInt();
        if (courseId == widget.courseId) {
          _enrollmentId = (m['id'] as num?)?.toInt();
          break;
        }
      }
    } catch (_) {
      // progress opsional; enroll manual tetap bisa.
    }
    return detail;
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (BuildContext c, AsyncSnapshot<Map<String, dynamic>> snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Padding(
                padding: EdgeInsets.all(24), child: AppLoading());
          }
          if (snap.hasError) {
            return ListView(children: <Widget>[
              AppError(
                message: snap.error.toString(),
                onRetry: _reload,
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
              if (_enrollmentId == null)
                FilledButton.tonal(
                  onPressed: () async {
                    Map<String, dynamic>? res;
                    final bool ok = await runMutation(context, () async {
                      res = await _repo.enroll(widget.courseId);
                    });
                    if (ok) {
                      _enrollmentId = (res?['id'] as num?)?.toInt();
                      _reload();
                    }
                  },
                  child: const Text('Enroll Kursus Ini'),
                )
              else ...<Widget>[
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.verified_outlined),
                    title: const Text('Terdaftar'),
                    subtitle: Text('Enrollment #$_enrollmentId'),
                    trailing: IconButton(
                      tooltip: 'Sertifikat',
                      icon: const Icon(Icons.workspace_premium_outlined),
                      onPressed: () async {
                        try {
                          final Map<String, dynamic> cert =
                              await _repo.certificate(_enrollmentId!);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Sertifikat: ${cert['certificate_no'] ?? cert['status'] ?? 'tersedia'}')),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())));
                        }
                      },
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text('Materi', style: Theme.of(context).textTheme.titleSmall),
              for (final dynamic l in lessons)
                Card(
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.article_outlined),
                    title: Text((l as Map)['title']?.toString() ?? '-'),
                    trailing: _enrollmentId == null
                        ? const Tooltip(
                            message: 'Enroll dulu',
                            child: Icon(Icons.lock_outline, size: 18),
                          )
                        : IconButton(
                            tooltip: 'Tandai selesai',
                            icon: const Icon(Icons.check_circle_outline),
                            onPressed: () async {
                              await runMutation(
                                context,
                                () => _repo.completeLesson(
                                  enrollmentId: _enrollmentId!,
                                  lessonId: ((l as Map)['id'] as num).toInt(),
                                ),
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
                    title: Text((q as Map)['title']?.toString() ?? 'Kuis'),
                    subtitle:
                        Text('${(q as Map)['questions_count'] ?? '-'} soal'),
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
