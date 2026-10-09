import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../data/reports_repository.dart';

/// Laporan keuangan: cash summary, aging 30/60/90, outstanding.
/// Backend: `/reports/*` (rupiah penuh, `accounting.view`).
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final ReportsRepository _repo = ReportsRepository();
  late Future<Map<String, dynamic>> _cash;
  late Future<Map<String, dynamic>> _aging;

  @override
  void initState() {
    super.initState();
    _cash = _repo.cashSummary();
    _aging = _repo.aging();
  }

  void _reload() {
    setState(() {
      _cash = _repo.cashSummary();
      _aging = _repo.aging();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Laporan Keuangan'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Kas'),
              Tab(text: 'Aging'),
              Tab(text: 'Tunggakan'),
            ],
          ),
          actions: <Widget>[
            IconButton(icon: const Icon(Icons.refresh), onPressed: _reload),
          ],
        ),
        body: TabBarView(
          children: <Widget>[
            FutureBuilder<Map<String, dynamic>>(
              future: _cash,
              builder:
                  (BuildContext c, AsyncSnapshot<Map<String, dynamic>> snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                      padding: EdgeInsets.all(24), child: AppLoading());
                }
                if (snap.hasError) {
                  return ListView(children: <Widget>[
                    AppError(message: snap.error.toString(), onRetry: _reload),
                  ]);
                }
                final Map<String, dynamic> d =
                    snap.data ?? const <String, dynamic>{};
                int v(String k) => (d[k] as num?)?.toInt() ?? 0;
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: <Widget>[
                        StatCard(
                            label: 'Masuk Bulan Ini',
                            value:
                                CurrencyFormatter.compact(v('collected_month')),
                            icon: Icons.trending_up_outlined),
                        StatCard(
                            label: 'Masuk Tahun Ini',
                            value:
                                CurrencyFormatter.compact(v('collected_year')),
                            icon: Icons.account_balance_wallet_outlined),
                        StatCard(
                            label: 'Belum Terbayar',
                            value: CurrencyFormatter.compact(v('pending')),
                            icon: Icons.warning_amber_outlined),
                      ],
                    ),
                    const SectionHeader(title: 'Per Metode (Bulan Ini)'),
                    for (final dynamic m
                        in (d['by_method'] as List?) ?? const <dynamic>[])
                      ListTile(
                        dense: true,
                        title: Text(
                            (m as Map)['payment_method']?.toString() ?? '-'),
                        trailing: Text(CurrencyFormatter.compact(
                            ((m['total'] as num?)?.toInt() ?? 0))),
                      ),
                  ],
                );
              },
            ),
            FutureBuilder<Map<String, dynamic>>(
              future: _aging,
              builder:
                  (BuildContext c, AsyncSnapshot<Map<String, dynamic>> snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                      padding: EdgeInsets.all(24), child: AppLoading());
                }
                if (snap.hasError) {
                  return ListView(children: <Widget>[
                    AppError(message: snap.error.toString(), onRetry: _reload),
                  ]);
                }
                final Map<String, dynamic> d =
                    snap.data ?? const <String, dynamic>{};
                const List<Map<String, String>> buckets = <Map<String, String>>[
                  {'k': 'current', 'l': 'Belum jatuh tempo'},
                  {'k': 'd1_30', 'l': 'Telat 1–30 hari'},
                  {'k': 'd31_60', 'l': 'Telat 31–60 hari'},
                  {'k': 'd61_90', 'l': 'Telat 61–90 hari'},
                  {'k': 'd90_plus', 'l': 'Telat > 90 hari'},
                ];
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    for (final Map<String, String> b in buckets)
                      Card(
                        child: ListTile(
                          title: Text(b['l']!),
                          trailing: Text(CurrencyFormatter.compact(
                              (d[b['k']] as num?)?.toInt() ?? 0)),
                        ),
                      ),
                  ],
                );
              },
            ),
            ModuleListPage(
              title: 'Tunggakan',
              loader: _repo.outstanding,
              emptyText: 'Tidak ada tunggakan.',
              itemBuilder: (BuildContext c, Map<String, dynamic> e) {
                final int amount = (e['amount'] as num?)?.toInt() ?? 0;
                final int paid = (e['paid_amount'] as num?)?.toInt() ?? 0;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: Text(
                        'Invoice ${e['invoice_no'] ?? e['id']} • ${CurrencyFormatter.compact(amount - paid)}'),
                    subtitle: Text(
                        'Jatuh tempo ${e['due_date'] ?? '-'} • ${e['status'] ?? '-'}'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
