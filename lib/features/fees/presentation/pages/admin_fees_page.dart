import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/fees_repository.dart';

/// Keuangan admin: tagihan (bayar manual) + struktur biaya.
/// Backend: `/fee/*` (rupiah penuh).
class AdminFeesPage extends StatefulWidget {
  const AdminFeesPage({super.key});

  @override
  State<AdminFeesPage> createState() => _AdminFeesPageState();
}

class _AdminFeesPageState extends State<AdminFeesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 3, vsync: this);
  final FeesRepository _repo = FeesRepository();
  late Future<List<Map<String, dynamic>>> _unpaid = _repo.all(status: 'unpaid');
  late Future<List<Map<String, dynamic>>> _paid = _repo.all(status: 'paid');

  void _reload() {
    setState(() {
      _unpaid = _repo.all(status: 'unpaid');
      _paid = _repo.all(status: 'paid');
    });
  }

  String _title(Map<String, dynamic> inv) {
    final dynamic fs = inv['fee_structure'];
    if (fs is Map && fs['name'] != null) return fs['name'].toString();
    return inv['title']?.toString() ??
        inv['invoice_no']?.toString() ??
        'Invoice ${inv['id']}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keuangan'),
        bottom: TabBar(controller: _tab, tabs: const <Widget>[
          Tab(text: 'Belum Bayar'),
          Tab(text: 'Lunas'),
          Tab(text: 'Struktur'),
        ]),
      ),
      body: TabBarView(
        controller: _tab,
        children: <Widget>[
          _List(
              future: _unpaid,
              isPaid: false,
              onRefresh: _reload,
              titleOf: _title,
              onPay: (Map<String, dynamic> inv) async {
                final Map<String, String>? v = await showFormDialog(
                  context,
                  title: 'Bayar Manual',
                  fields: const <FormFieldDef>[
                    FormFieldDef(
                        key: 'amount', label: 'Nominal (Rp)', isNumber: true),
                    FormFieldDef(
                        key: 'payment_method',
                        label: 'Metode',
                        options: <String>['cash', 'transfer', 'qris']),
                  ],
                );
                if (v == null || !context.mounted) return;
                final bool ok = await runMutation(
                  context,
                  () => _repo.recordPayment(
                    invoiceId: (inv['id'] as num).toInt(),
                    amount: int.parse(v['amount']!),
                    method: v['payment_method']!,
                  ),
                );
                if (ok) _reload();
              }),
          _List(
              future: _paid, isPaid: true, onRefresh: _reload, titleOf: _title),
          _StructuresTab(repo: _repo),
        ],
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List(
      {required this.future,
      required this.isPaid,
      required this.onRefresh,
      required this.titleOf,
      this.onPay});

  final Future<List<Map<String, dynamic>>> future;
  final bool isPaid;
  final VoidCallback onRefresh;
  final String Function(Map<String, dynamic>) titleOf;
  final Future<void> Function(Map<String, dynamic>)? onPay;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder:
          (BuildContext c, AsyncSnapshot<List<Map<String, dynamic>>> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const AppLoading();
        }
        if (snap.hasError) {
          return AppError(message: '${snap.error}', onRetry: onRefresh);
        }
        final List<Map<String, dynamic>> list =
            snap.data ?? <Map<String, dynamic>>[];
        if (list.isEmpty) return const AppEmpty(title: 'Tidak ada data');
        return RefreshIndicator(
          onRefresh: () async => onRefresh(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (BuildContext c, int i) {
              final Map<String, dynamic> inv = list[i];
              final int amount = (inv['amount'] as num?)?.toInt() ?? 0;
              final int paid = (inv['paid_amount'] as num?)?.toInt() ?? 0;
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: CircleAvatar(
                    backgroundColor:
                        (isPaid ? AppColors.success : AppColors.warning)
                            .withValues(alpha: 0.12),
                    child: Icon(
                      isPaid
                          ? Icons.check_circle_outline
                          : Icons.schedule_outlined,
                      color: isPaid ? AppColors.success : AppColors.warning,
                    ),
                  ),
                  title: Text(titleOf(inv)),
                  subtitle: Text(
                      'Siswa ${inv['student_id'] ?? '-'} • Jatuh tempo ${inv['due_date'] ?? inv['due_at'] ?? '-'}${isPaid ? '' : ' • Kurang ${CurrencyFormatter.compact(amount - paid)}'}'),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(CurrencyFormatter.compact(amount),
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      if (!isPaid && onPay != null)
                        TextButton(
                          onPressed: () => onPay!(inv),
                          child: const Text('Bayar'),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _StructuresTab extends StatelessWidget {
  const _StructuresTab({required this.repo});
  final FeesRepository repo;

  @override
  Widget build(BuildContext context) {
    return ModuleListPage(
      title: 'Struktur',
      loader: repo.structures,
      emptyText: 'Belum ada struktur biaya.',
      onCreate: () async {
        final Map<String, String>? v = await showFormDialog(
          context,
          title: 'Struktur Baru',
          fields: const <FormFieldDef>[
            FormFieldDef(key: 'name', label: 'Nama (mis. SPP Bulanan)'),
            FormFieldDef(
                key: 'frequency',
                label: 'Frekuensi',
                options: <String>[
                  'monthly',
                  'quarterly',
                  'annual',
                  'one-time'
                ]),
            FormFieldDef(key: 'amount', label: 'Nominal (Rp)', isNumber: true),
          ],
        );
        if (v == null || !context.mounted) return;
        await runMutation(
          context,
          () => repo.storeStructure(
            name: v['name']!,
            frequency: v['frequency']!,
            amount: int.parse(v['amount']!),
          ),
        );
      },
      itemBuilder: (BuildContext c, Map<String, dynamic> e) => Card(
        child: ListTile(
          leading: const Icon(Icons.request_quote_outlined),
          title: Text(e['name']?.toString() ?? '-'),
          subtitle: Text('${e['frequency'] ?? '-'}'),
          trailing: Text(
              CurrencyFormatter.compact((e['amount'] as num?)?.toInt() ?? 0)),
        ),
      ),
    );
  }
}
