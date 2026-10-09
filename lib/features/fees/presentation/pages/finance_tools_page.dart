import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/fees_repository.dart';

/// Aksi keuangan admin: generate invoice batch + bayar manual.
/// Backend: `POST /fee/generate-monthly {period:YYYY-MM}`,
/// `POST /fee/invoices/{id}/pay {amount,payment_method}`.
class FinanceToolsPage extends StatelessWidget {
  const FinanceToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FeesRepository repo = FeesRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('Aksi Keuangan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: ListTile(
              leading: const Icon(Icons.auto_awesome_outlined),
              title: const Text('Generate invoice batch'),
              subtitle: const Text('Buat invoice seluruh rombel per periode.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final Map<String, String>? v = await showFormDialog(
                  context,
                  title: 'Generate Invoice',
                  fields: const <FormFieldDef>[
                    FormFieldDef(
                        key: 'period',
                        label: 'Periode (YYYY-MM)',
                        hint: '2026-10'),
                  ],
                );
                if (v == null || !context.mounted) return;
                int n = 0;
                await runMutation(context, () async {
                  n = await repo.generateMonthly(v['period']!);
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$n invoice dibuat.')),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.payments_outlined),
              title: const Text('Bayar manual (tunai/transfer)'),
              subtitle: const Text('Catat pembayaran + kuitansi.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final Map<String, String>? v = await showFormDialog(
                  context,
                  title: 'Bayar Manual',
                  fields: const <FormFieldDef>[
                    FormFieldDef(
                        key: 'invoice_id', label: 'ID Invoice', isNumber: true),
                    FormFieldDef(
                        key: 'amount', label: 'Nominal (Rp)', isNumber: true),
                    FormFieldDef(
                        key: 'payment_method',
                        label: 'Metode',
                        options: <String>['cash', 'transfer', 'qris']),
                  ],
                );
                if (v == null || !context.mounted) return;
                Map<String, dynamic>? res;
                await runMutation(context, () async {
                  res = await repo.recordPayment(
                    invoiceId: int.parse(v['invoice_id']!),
                    amount: int.parse(v['amount']!),
                    method: v['payment_method']!,
                  );
                });
                if (context.mounted && res != null) {
                  final int paid = (res!['paid_amount'] as num?)?.toInt() ?? 0;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Tercatat ${CurrencyFormatter.idr(paid)}.')),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
