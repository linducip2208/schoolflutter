import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/dashboard_repository.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/greeting_header.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardBloc>(
      create: (_) => DashboardBloc(DashboardRepository())
        ..add(const DashboardLoadRequested('admin')),
      child: const _AdminDashboardView(),
    );
  }
}

class _AdminDashboardView extends StatelessWidget {
  const _AdminDashboardView();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    final school = context.watch<AuthBloc>().state.school;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (BuildContext c, DashboardState state) {
            return RefreshIndicator(
              onRefresh: () async => c
                  .read<DashboardBloc>()
                  .add(const DashboardRefreshRequested('admin')),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: <Widget>[
                  GreetingHeader(
                    name: user?.name ?? 'Admin',
                    subtitle: school?.name ?? '',
                    avatarUrl: user?.avatarUrl,
                  ),
                  if (state.status == DashboardStatus.loading ||
                      state.status == DashboardStatus.initial)
                    const Padding(
                        padding: EdgeInsets.all(24), child: AppLoading())
                  else if (state.status == DashboardStatus.error)
                    AppError(
                      message: state.errorMessage ?? 'Gagal memuat',
                      onRetry: () => c
                          .read<DashboardBloc>()
                          .add(const DashboardRefreshRequested('admin')),
                    )
                  else
                    _content(c, state.data ?? const <String, dynamic>{}),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _content(BuildContext context, Map<String, dynamic> d) {
    final int totalStudents = (d['total_students'] as num?)?.toInt() ?? 0;
    final int totalTeachers = (d['total_teachers'] as num?)?.toInt() ?? 0;
    final int feesCollected = (d['fees_collected'] as num?)?.toInt() ?? 0;
    final int feesPending = (d['fees_pending'] as num?)?.toInt() ?? 0;
    final List<dynamic> trend =
        (d['attendance_trend'] as List<dynamic>?) ?? const <dynamic>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: <Widget>[
              StatCard(
                label: 'Total Siswa',
                value: '$totalStudents',
                icon: Icons.school_outlined,
                onTap: () => context.push(Routes.adminStudents),
              ),
              StatCard(
                label: 'Total Guru/Staf',
                value: '$totalTeachers',
                icon: Icons.badge_outlined,
                color: AppColors.secondary,
                onTap: () => context.push(Routes.adminStaff),
              ),
              StatCard(
                label: 'Iuran Diterima',
                value: CurrencyFormatter.compact(feesCollected),
                icon: Icons.payments_outlined,
                color: AppColors.success,
                onTap: () => context.push(Routes.adminFees),
              ),
              StatCard(
                label: 'Tunggakan',
                value: CurrencyFormatter.compact(feesPending),
                icon: Icons.warning_amber_outlined,
                color: AppColors.danger,
                onTap: () => context.push(Routes.adminFees),
              ),
            ],
          ),
        ),
        const SectionHeader(title: 'Akses Cepat'),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: _QuickAction(
                  icon: Icons.receipt_long_outlined,
                  label: 'Keuangan',
                  color: AppColors.success,
                  onTap: () => context.push(Routes.adminFees),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.fact_check_outlined,
                  label: 'Absensi',
                  color: AppColors.primary,
                  onTap: () => context.push(Routes.adminAttendance),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.assessment_outlined,
                  label: 'Laporan',
                  color: AppColors.secondary,
                  onTap: () => context.push(Routes.adminReports),
                ),
              ),
            ],
          ),
        ),
        const SectionHeader(title: 'Komposisi Iuran'),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: SizedBox(
                height: 190,
                child: (feesCollected + feesPending) <= 0
                    ? const AppEmpty(
                        icon: Icons.pie_chart_outline,
                        title: 'Belum ada data',
                        subtitle: 'Data muncul setelah invoice terbit',
                      )
                    : Row(
                        children: <Widget>[
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 3,
                                centerSpaceRadius: 42,
                                sections: <PieChartSectionData>[
                                  PieChartSectionData(
                                    value: feesCollected.toDouble(),
                                    title:
                                        '${_pct(feesCollected, feesCollected + feesPending)}%',
                                    color: AppColors.success,
                                    radius: 52,
                                    titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  PieChartSectionData(
                                    value: feesPending.toDouble(),
                                    title:
                                        '${_pct(feesPending, feesCollected + feesPending)}%',
                                    color: AppColors.danger,
                                    radius: 52,
                                    titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _Legend(
                                  color: AppColors.success,
                                  label: 'Diterima',
                                  value:
                                      CurrencyFormatter.compact(feesCollected)),
                              const SizedBox(height: 8),
                              _Legend(
                                  color: AppColors.danger,
                                  label: 'Tunggakan',
                                  value:
                                      CurrencyFormatter.compact(feesPending)),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
        const SectionHeader(title: 'Tren Kehadiran (7 hari)'),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: SizedBox(
                height: 200,
                child: trend.isEmpty
                    ? const AppEmpty(
                        icon: Icons.show_chart_outlined,
                        title: 'Belum ada data',
                        subtitle: 'Data tren muncul setelah absensi tercatat',
                      )
                    : LineChart(_chart(trend)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData _chart(List<dynamic> data) {
    final List<FlSpot> spots = <FlSpot>[];
    final List<String> labels = <String>[];
    double maxSeen = 0;
    for (int i = 0; i < data.length; i++) {
      final Map<String, dynamic> row =
          Map<String, dynamic>.from(data[i] as Map);
      final num v = (row['value'] as num?) ?? 0;
      if (v.toDouble() > maxSeen) maxSeen = v.toDouble();
      spots.add(FlSpot(i.toDouble(), v.toDouble()));
      labels.add(_shortDate(row['date']?.toString()));
    }
    return LineChartData(
      gridData: const FlGridData(show: true, drawVerticalLine: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        show: true,
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double v, TitleMeta m) {
              final int i = v.toInt();
              if (i < 0 || i >= labels.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(labels[i], style: const TextStyle(fontSize: 10)),
              );
            },
          ),
        ),
      ),
      minY: 0,
      // Scale to the data (percent charts cap at 100; counts grow freely).
      maxY: maxSeen <= 100 ? 100 : (maxSeen * 1.1).ceilToDouble(),
      lineBarsData: <LineChartBarData>[
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: const LinearGradient(
            colors: <Color>[AppColors.primary, AppColors.secondary],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: <Color>[
                AppColors.primary.withValues(alpha: 0.25),
                AppColors.primary.withValues(alpha: 0.02),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  static String _shortDate(String? iso) {
    if (iso == null || iso.length < 10) return '';
    // 2026-10-04 -> 04/10
    return '${iso.substring(8, 10)}/${iso.substring(5, 7)}';
  }

  static int _pct(int part, int total) =>
      total <= 0 ? 0 : ((part / total) * 100).round();
}

class _Legend extends StatelessWidget {
  const _Legend(
      {required this.color, required this.label, required this.value});
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
