import 'package:flutter/material.dart';

import '../../../../core/widgets/module_list_page.dart';
import '../../data/analytics_repository.dart';

/// Learning analytics: siswa berisiko dropout + hitung ulang skor.
/// Backend: `/analytics/risk-scores/*`.
class RiskAnalyticsPage extends StatelessWidget {
  const RiskAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AnalyticsRepository repo = AnalyticsRepository();
    return ModuleListPage(
      title: 'Analitik Risiko',
      loader: repo.atRisk,
      emptyText: 'Tidak ada siswa berisiko.',
      actions: <Widget>[
        IconButton(
          tooltip: 'Hitung ulang skor',
          icon: const Icon(Icons.calculate_outlined),
          onPressed: () async {
            await runMutation(context, () => repo.compute());
          },
        ),
      ],
      itemBuilder: (BuildContext c, Map<String, dynamic> e) => Card(
        child: ListTile(
          leading: const Icon(Icons.warning_amber_outlined),
          title:
              Text(e['name']?.toString() ?? 'Siswa ${e['student_id'] ?? '-'}'),
          subtitle: Text('Skor ${e['risk_score'] ?? e['score'] ?? '-'}'),
          onTap: () => _showDetail(c, repo, e),
        ),
      ),
    );
  }

  Future<void> _showDetail(
      BuildContext c, AnalyticsRepository repo, Map<String, dynamic> e) async {
    final int? studentId = (e['student_id'] as num?)?.toInt();
    if (studentId == null) return;
    Map<String, dynamic>? detail;
    String? error;
    try {
      detail = await repo.studentRisk(studentId);
    } catch (err) {
      error = err.toString();
    }
    if (!c.mounted) return;
    await showDialog<void>(
      context: c,
      builder: (BuildContext d) => AlertDialog(
        title: const Text('Detail Risiko'),
        content: Text(error ?? detail.toString()),
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
