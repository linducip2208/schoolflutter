import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../data/exam_repository.dart';
import 'exam_attempt_page.dart';

/// Daftar ujian + mulai attempt.
/// Backend: `GET /exams` (title, subject relasi, start_at).
class ExamListPage extends StatefulWidget {
  const ExamListPage({super.key});

  @override
  State<ExamListPage> createState() => _ExamListPageState();
}

class _ExamListPageState extends State<ExamListPage> {
  final ExamRepository _repo = ExamRepository();
  late Future<List<Map<String, dynamic>>> _future = _repo.list();

  void _reload() => setState(() => _future = _repo.list());

  String _subjectName(Map<String, dynamic> e) {
    final dynamic s = e['subject'];
    if (s is Map) return s['name']?.toString() ?? '-';
    return e['subject_name']?.toString() ?? '-';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ujian')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder:
            (BuildContext c, AsyncSnapshot<List<Map<String, dynamic>>> snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const AppLoading();
          }
          if (snap.hasError) {
            return AppError(message: '${snap.error}', onRetry: _reload);
          }
          final List<Map<String, dynamic>> list =
              snap.data ?? <Map<String, dynamic>>[];
          if (list.isEmpty) {
            return const AppEmpty(title: 'Belum ada ujian');
          }
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (BuildContext c, int i) {
                final Map<String, dynamic> e = list[i];
                final String status = e['status'] as String? ?? 'scheduled';
                final int id = (e['id'] as num).toInt();
                final String title = e['title'] as String? ?? '-';
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            _StatusChip(status: status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(_subjectName(e),
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 4),
                        if (e['start_at'] != null)
                          Text(
                            DateFormatter.dateTime(
                                DateTime.parse(e['start_at'] as String)),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            TextButton.icon(
                              icon: const Icon(Icons.visibility_outlined,
                                  size: 18),
                              label: const Text('Hasil'),
                              onPressed: () async {
                                try {
                                  final Map<String, dynamic> res =
                                      await _repo.examResult(id);
                                  if (!c.mounted) return;
                                  ScaffoldMessenger.of(c).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Skor ${res['score'] ?? res['total_score'] ?? '-'} • ${res['status'] ?? '-'}')),
                                  );
                                } catch (err) {
                                  if (!c.mounted) return;
                                  ScaffoldMessenger.of(c).showSnackBar(
                                      SnackBar(content: Text(err.toString())));
                                }
                              },
                            ),
                            FilledButton.tonalIcon(
                              icon: const Icon(Icons.play_arrow_outlined,
                                  size: 18),
                              label: const Text('Mulai'),
                              onPressed: () async {
                                final bool? done =
                                    await Navigator.of(c).push<bool>(
                                  MaterialPageRoute<bool>(
                                    builder: (_) => ExamAttemptPage(
                                        examId: id, title: title),
                                  ),
                                );
                                if (done == true) _reload();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (Color, String) sx = switch (status) {
      'ongoing' => (AppColors.warning, 'Berlangsung'),
      'completed' => (AppColors.success, 'Selesai'),
      'cancelled' => (AppColors.danger, 'Dibatalkan'),
      _ => (AppColors.info, 'Terjadwal'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: sx.$1.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(sx.$2,
          style: TextStyle(
              color: sx.$1, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
