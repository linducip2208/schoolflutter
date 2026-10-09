import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../dashboard/data/dashboard_repository.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../dashboard/presentation/widgets/greeting_header.dart';

/// Platform dashboard for `super_admin`.
/// Backend: `GET /api/v1/super/dashboard` via [DashboardRepository]
/// (`super_admin` → [ApiEndpoints.superDashboard]).
class SuperDashboardPage extends StatelessWidget {
  const SuperDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardBloc>(
      create: (_) => DashboardBloc(DashboardRepository())
        ..add(const DashboardLoadRequested('super_admin')),
      child: const _SuperDashboardView(),
    );
  }
}

class _SuperDashboardView extends StatelessWidget {
  const _SuperDashboardView();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (BuildContext c, DashboardState state) {
            return RefreshIndicator(
              onRefresh: () async => c
                  .read<DashboardBloc>()
                  .add(const DashboardRefreshRequested('super_admin')),
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  GreetingHeader(
                    name: user?.name ?? 'Super Admin',
                    subtitle: 'Operator Platform',
                    avatarUrl: user?.avatarUrl,
                  ),
                  if (state.status == DashboardStatus.loading)
                    const Padding(
                        padding: EdgeInsets.all(24), child: AppLoading())
                  else if (state.status == DashboardStatus.error)
                    AppError(
                      message: state.errorMessage ?? 'Gagal memuat',
                      onRetry: () => c
                          .read<DashboardBloc>()
                          .add(const DashboardRefreshRequested('super_admin')),
                    )
                  else
                    _content(context, state.data ?? const <String, dynamic>{}),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _content(BuildContext context, Map<String, dynamic> d) {
    final Map<String, dynamic> overview = (d['overview'] as Map?) != null
        ? Map<String, dynamic>.from(d['overview'] as Map)
        : const <String, dynamic>{};
    final int totalSchools = (overview['total_schools'] as num?)?.toInt() ?? 0;
    final int activeSchools =
        (overview['active_schools'] as num?)?.toInt() ?? 0;
    final int suspendedSchools =
        (overview['suspended_schools'] as num?)?.toInt() ?? 0;
    final int totalStudents =
        (overview['total_students'] as num?)?.toInt() ?? 0;
    // NOTE: super-dashboard money keys are raw cents (backend divides by 100
    // for web display too) — unlike school-level endpoints that already
    // return whole rupiah. Hence the single /100 here.
    final int revenueCents =
        (overview['total_revenue_this_month_cents'] as num?)?.toInt() ?? 0;
    final int newSchools = (d['new_schools_this_month'] as num?)?.toInt() ?? 0;
    final List<dynamic> trend =
        (d['monthly_revenue'] as List<dynamic>?) ?? const <dynamic>[];
    final List<dynamic> expiring =
        (d['subscriptions_expiring_soon'] as List<dynamic>?) ??
            const <dynamic>[];
    final List<dynamic> plans =
        (d['plan_distribution'] as List<dynamic>?) ?? const <dynamic>[];

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
                label: 'Total Sekolah',
                value: '$totalSchools',
                icon: Icons.apartment_outlined,
              ),
              StatCard(
                label: 'Sekolah Aktif',
                value: '$activeSchools',
                icon: Icons.verified_outlined,
                color: AppColors.success,
              ),
              StatCard(
                label: 'Suspended',
                value: '$suspendedSchools',
                icon: Icons.block_outlined,
                color: AppColors.danger,
              ),
              StatCard(
                label: 'Sekolah Baru Bulan Ini',
                value: '$newSchools',
                icon: Icons.add_business_outlined,
                color: AppColors.secondary,
              ),
              StatCard(
                label: 'Total Siswa',
                value: '$totalStudents',
                icon: Icons.school_outlined,
                color: AppColors.info,
              ),
              StatCard(
                label: 'Pendapatan Bulan Ini',
                value: CurrencyFormatter.compact(revenueCents ~/ 100),
                icon: Icons.payments_outlined,
                color: AppColors.success,
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
                  icon: Icons.apartment_outlined,
                  label: 'Kelola Sekolah',
                  color: AppColors.secondary,
                  onTap: () => context.push(Routes.superSchools),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.person_outline,
                  label: 'Profil',
                  color: AppColors.info,
                  onTap: () => context.push(Routes.superProfile),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: _QuickAction(
                  icon: Icons.workspace_premium_outlined,
                  label: 'Paket',
                  color: AppColors.warning,
                  onTap: () => context.push(Routes.superPlans),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.analytics_outlined,
                  label: 'Analitik',
                  color: AppColors.secondary,
                  onTap: () => context.push(Routes.superAnalytics),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.settings_outlined,
                  label: 'Sistem',
                  color: AppColors.info,
                  onTap: () => context.push(Routes.superSystem),
                ),
              ),
            ],
          ),
        ),
        const SectionHeader(title: 'Pendapatan 12 Bulan'),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: SizedBox(
                height: 200,
                child: trend.isEmpty
                    ? const Center(child: Text('Belum ada data'))
                    : LineChart(_chart(trend)),
              ),
            ),
          ),
        ),
        if (plans.isNotEmpty) ...<Widget>[
          const SectionHeader(title: 'Distribusi Paket'),
          for (final dynamic p in plans)
            ListTile(
              leading: const Icon(Icons.workspace_premium_outlined),
              title: Text((p as Map)['plan']?.toString() ?? '-'),
              trailing:
                  Text('${p['count'] ?? 0} sekolah (${p['percentage'] ?? 0}%)'),
              dense: true,
            ),
        ],
        if (expiring.isNotEmpty) ...<Widget>[
          const SectionHeader(title: 'Langganan Segera Berakhir'),
          for (final dynamic e in expiring)
            Builder(builder: (BuildContext context) {
              final Map<String, dynamic> m =
                  Map<String, dynamic>.from(e as Map);
              final DateTime? exp =
                  DateTime.tryParse(m['expires_at']?.toString() ?? '');
              return ListTile(
                leading: const Icon(Icons.schedule_outlined),
                title: Text(m['school']?.toString() ?? '-'),
                subtitle: Text(
                    '${m['plan'] ?? '-'} • ${exp != null ? DateFormatter.dayMonthYear(exp) : (m['expires_at']?.toString() ?? '-')}'),
                dense: true,
              );
            }),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  LineChartData _chart(List<dynamic> data) {
    final List<FlSpot> spots = <FlSpot>[];
    double maxY = 0;
    for (int i = 0; i < data.length; i++) {
      final num cents = ((data[i] as Map)['amount_cents'] as num?) ?? 0;
      final double v = cents.toDouble() / 100;
      if (v > maxY) maxY = v;
      spots.add(FlSpot(i.toDouble(), v));
    }
    return LineChartData(
      gridData: const FlGridData(show: true, drawVerticalLine: false),
      borderData: FlBorderData(show: false),
      titlesData: const FlTitlesData(
        show: true,
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      minY: 0,
      maxY: maxY <= 0 ? 100 : maxY * 1.2,
      lineBarsData: <LineChartBarData>[
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors.primary,
          barWidth: 3,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primary.withValues(alpha: 0.12),
          ),
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
