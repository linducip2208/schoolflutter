import 'package:flutter/material.dart';

import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/lms_repository.dart';

/// Kerjakan kuis: soal tanpa kunci + submit jawaban.
/// Backend: `GET /lms/quizzes/{id}/questions` (tanpa correct_answer),
/// `POST /lms/quiz/submit {quiz_id, answers:{qid:jawaban}}`.
class QuizAttemptPage extends StatefulWidget {
  const QuizAttemptPage(
      {super.key, required this.quizId, required this.title});
  final int quizId;
  final String title;

  @override
  State<QuizAttemptPage> createState() => _QuizAttemptPageState();
}

class _QuizAttemptPageState extends State<QuizAttemptPage> {
  final LmsRepository _repo = LmsRepository();
  late Future<List<Map<String, dynamic>>> _future;
  final Map<int, String> _answers = <int, String>{};
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _future = _repo.questions(widget.quizId);
  }

  Future<void> _submit(List<Map<String, dynamic>> questions) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final Map<String, dynamic> res = await _repo.submitQuiz(
        quizId: widget.quizId,
        answers: <String, String>{
          for (final MapEntry<int, String> e in _answers.entries)
            e.key.toString(): e.value,
        },
      );
      if (!mounted) return;
      final int score = (res['score'] as num?)?.toInt() ?? 0;
      final int total = (res['total'] as num?)?.toInt() ?? questions.length;
      await showDialog<void>(
        context: context,
        builder: (BuildContext d) => AlertDialog(
          title: const Text('Hasil'),
          content: Text('Skor $score dari $total soal.'),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.of(d).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Selesai'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (BuildContext c,
            AsyncSnapshot<List<Map<String, dynamic>>> snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Padding(
                padding: EdgeInsets.all(24), child: AppLoading());
          }
          if (snap.hasError) {
            return ListView(children: <Widget>[
              AppError(
                message: snap.error.toString(),
                onRetry: () => setState(() {
                  _future = _repo.questions(widget.quizId);
                }),
              ),
            ]);
          }
          final List<Map<String, dynamic>> items =
              snap.data ?? const <Map<String, dynamic>>[];
          if (items.isEmpty) {
            return const Center(child: Text('Belum ada soal.'));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            children: <Widget>[
              for (final Map<String, dynamic> q in items)
                _QuestionCard(
                  question: q,
                  value: _answers[(q['id'] as num).toInt()],
                  onChanged: (String v) => setState(() {
                    _answers[(q['id'] as num).toInt()] = v;
                  }),
                ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _busy ? null : () => _submit(items),
                icon: const Icon(Icons.send_outlined),
                label: Text(
                    'Kumpulkan (${_answers.length}/${items.length})'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.value,
    required this.onChanged,
  });
  final Map<String, dynamic> question;
  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final List<dynamic> options =
        (question['options'] as List?) ?? const <dynamic>[];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(question['question']?.toString() ?? '-',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (options.isEmpty)
              TextField(
                decoration:
                    const InputDecoration(labelText: 'Jawaban singkat'),
                onChanged: onChanged,
              )
            else
              for (final dynamic o in options)
                RadioListTile<String>(
                  dense: true,
                  title: Text(o.toString()),
                  value: o.toString(),
                  groupValue: value,
                  onChanged: (String? v) {
                    if (v != null) onChanged(v);
                  },
                ),
          ],
        ),
      ),
    );
  }
}
