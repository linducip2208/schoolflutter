import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../../../core/widgets/section_header.dart';
import '../../data/budget_repository.dart';

/// RKAS: ringkasan + item + realisasi (rupiah penuh).
/// Backend: `/budget/*` (`accounting.view|manage`).
class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final BudgetRepository _repo = BudgetRepository();
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.dashboard();
  }

  void _reload() {
    setState(() {
      _future = _repo.dashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anggaran (RKAS)'),
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.refresh), onPressed: _reload),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Realisasi'),
        onPressed: () async {
          final Map<String, String>? v = await showFormDialog(
            context,
            title: 'Catat Realisasi',
            fields: const <FormFieldDef>[
              FormFieldDef(
                  key: 'budget_item_id', label: 'ID Item', isNumber: true),
              FormFieldDef(
                  key: 'transaction_date', label: 'Tanggal (YYYY-MM-DD)'),
              FormFieldDef(key: 'amount', label: 'Nominal (Rp)', isNumber: true),
              FormFieldDef(key: 'description', label: 'Keterangan'),
            ],
          );
          if (v == null || !context.mounted) return;
          final bool ok = await runMutation(
            context,
            () => _repo.storeTransaction(
              itemId: int.parse(v['budget_item_id']!),
              date: v['transaction_date']!,
              amount: int.parse(v['amount']!),
              description: v['description'],
            ),
          );
          if (ok) _reload();
        },
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
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
          final int planned = (d['planned_total'] as num?)?.toInt() ?? 0;
          final int actual = (d['actual_total'] as num?)?.toInt() ?? 0;
          final List<dynamic> items =
              ((d['items'] as Map?)?['data'] as List?) ??
                  const <dynamic>[];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                          'Rencana ${CurrencyFormatter.compact(planned)}'),
                      Text(
                          'Realisasi ${CurrencyFormatter.compact(actual)}'),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                          value: planned <= 0
                              ? 0
                              : (actual / planned).clamp(0.0, 1.0).toDouble()),
                    ],
                  ),
                ),
              ),
              const SectionHeader(title: 'Item Anggaran'),
              if (items.isEmpty)
                const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Belum ada item.')),
              for (final dynamic it in items)
                Card(
                  child: ListTile(
                    dense: true,
                    title: Text((it as Map)['name']?.toString() ?? '-'),
                    subtitle: Text(
                        'Rencana ${CurrencyFormatter.compact(((it['planned_amount'] as num?)?.toInt() ?? 0))} • Realisasi ${CurrencyFormatter.compact(((it['actual_amount'] as num?)?.toInt() ?? 0))}'),
                    trailing: Text(it['status']?.toString() ?? ''),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
