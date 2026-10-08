import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/section_header.dart';
import '../../data/superadmin_repository.dart';

/// Analitik platform (docs §super §7): revenue 12 bulan + growth.
/// Backend: `/super/analytics/revenue`, `/super/analytics/growth`.
/// Uang di sini bersatuan sen (kontrak super-dashboard) → /100 sekali.
class SuperAnalyticsPage extends StatefulWidget {
  const SuperAnalyticsPage({super.key});

  @override
  State<SuperAnalyticsPage> createState() => _SuperAnalyticsPageState();
}

class _SuperAnalyticsPageState extends State<SuperAnalyticsPage> {
  final SuperAdminRepository _repo = SuperAdminRepository();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final Map<String, dynamic> res = await _repo.revenueAnalytics();
    final dynamic raw = res['monthly'] ?? res['data'] ?? res['monthly_revenue'];
    if (raw is List) {
      return raw
          .map((dynamic e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return const <Map<String, dynamic>>[];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analitik Platform')),
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
                  _future = _load();
                }),
              ),
            ]);
          }
          final List<Map<String, dynamic>> items =
              snap.data ?? const <Map<String, dynamic>>[];
          if (items.isEmpty) {
            return const Center(child: Text('Belum ada data revenue.'));
          }
          final List<FlSpot> spots = <FlSpot>[];
          double maxY = 0;
          for (int i = 0; i < items.length; i++) {
            final num cents = (items[i]['amount_cents'] ??
                    items[i]['amount'] ??
                    items[i]['revenue'] ??
                    0) as num;
            final double v = cents.toDouble() / 100;
            if (v > maxY) maxY = v;
            spots.add(FlSpot(i.toDouble(), v));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              const SectionHeader(title: 'Revenue 12 Bulan'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        gridData:
                            const FlGridData(show: true, drawVerticalLine: false),
                        borderData: FlBorderData(show: false),
                        titlesData: const FlTitlesData(
                          show: true,
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        barGroups: <BarChartGroupData>[
                          for (int i = 0; i < spots.length; i++)
                            BarChartGroupData(
                              x: i,
                              barRods: <BarChartRodData>[
                                BarChartRodData(
                                    toY: spots[i].y,
                                    color: AppColors.primary),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              for (final Map<String, dynamic> e in items)
                ListTile(
                  dense: true,
                  title: Text(
                      '${e['month'] ?? e['label'] ?? '-'}'),
                  trailing: Text(CurrencyFormatter.compact(
                      (((e['amount_cents'] ?? e['amount'] ?? 0) as num)
                                  .toDouble() /
                              100)
                          .round())),
                ),
            ],
          );
        },
      ),
    );
  }
}
