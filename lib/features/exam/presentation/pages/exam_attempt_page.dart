import 'package:flutter/material.dart';

import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../data/exam_repository.dart';

/// Kerjakan ujian: start → jawab → kumpulkan → skor.
/// Backend: `GET /exams/{id}/start` (soal tanpa kunci),
/// `POST /exams/{id}/submit {answers:{qid:jawaban}}`.
class ExamAttemptPage extends StatefulWidget {
  const ExamAttemptPage({super.key, required this.examId, required this.title});
  final int examId;
  final String title;

  @override
  State<ExamAttemptPage> createState() => _ExamAttemptPageState();
}

class _ExamAttemptPageState extends State<ExamAttemptPage> {
  final ExamRepository _repo = ExamRepository();
  late Future<Map<String, dynamic>> _future;
  final Map<int, String> _answers = <int, String>{};
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _future = _repo.startExam(widget.examId);
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final Map<String, dynamic> res = await _repo.submitExam(
        widget.examId,
        <String, String>{
          for (final MapEntry<int, String> e in _answers.entries)
            e.key.toString(): e.value,
        },
      );
      if (!mounted) return;
      final dynamic score = res['score'] ?? res['total_score'] ?? '-';
      await showDialog<void>(
        context: context,
        builder: (BuildContext d) => AlertDialog(
          title: const Text('Ujian Terkumpul'),
          content: Text('Skor: $score\nStatus: ${res['status'] ?? '-'}'),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.of(d).pop();
                Navigator.of(context).pop(true);
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
                onRetry: () => setState(() {
                  _future = _repo.startExam(widget.examId);
                }),
              ),
            ]);
          }
          final Map<String, dynamic> data =
              snap.data ?? const <String, dynamic>{};
          final Map<String, dynamic> exam = data['exam'] is Map
              ? Map<String, dynamic>.from(data['exam'] as Map)
              : const <String, dynamic>{};
          final List<dynamic> questions =
              (exam['questions'] as List?) ?? const <dynamic>[];
          if (questions.isEmpty) {
            return const Center(child: Text('Belum ada soal.'));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            children: <Widget>[
              for (final dynamic q in questions)
                _ExamQuestionCard(
                  question: Map<String, dynamic>.from(q as Map),
                  value: _answers[((q as Map)['id'] as num).toInt()],
                  onChanged: (String v) => setState(() {
                    _answers[((q as Map)['id'] as num).toInt()] = v;
                  }),
                ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _busy ? null : _submit,
                icon: const Icon(Icons.send_outlined),
                label:
                    Text('Kumpulkan (${_answers.length}/${questions.length})'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ExamQuestionCard extends StatelessWidget {
  const _ExamQuestionCard({
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
    final String type = question['type']?.toString() ?? 'mcq';
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
            if (type == 'true_false')
              for (final String o in <String>['true', 'false'])
                RadioListTile<String>(
                  dense: true,
                  title: Text(o == 'true' ? 'Benar' : 'Salah'),
                  value: o,
                  groupValue: value,
                  onChanged: (String? v) {
                    if (v != null) onChanged(v);
                  },
                )
            else if (options.isNotEmpty)
              for (final dynamic o in options)
                RadioListTile<String>(
                  dense: true,
                  title: Text(o.toString()),
                  value: o.toString(),
                  groupValue: value,
                  onChanged: (String? v) {
                    if (v != null) onChanged(v);
                  },
                )
            else
              TextField(
                decoration: const InputDecoration(labelText: 'Jawaban essay'),
                maxLines: 3,
                onChanged: onChanged,
              ),
          ],
        ),
      ),
    );
  }
}
