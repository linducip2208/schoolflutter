import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/canteen_repository.dart';

/// Kantin merchant: pesanan hari ini + ubah status.
/// Backend: `/canteen/orders/today`, `PUT /canteen/orders/{id}/status`
/// (`pending,preparing,ready,picked_up,cancelled`).
class CanteenMerchantPage extends StatelessWidget {
  const CanteenMerchantPage({super.key});

  static const List<String> _statuses = <String>[
    'pending',
    'preparing',
    'ready',
    'picked_up',
    'cancelled'
  ];

  @override
  Widget build(BuildContext context) {
    final CanteenRepository repo = CanteenRepository();
    return ModuleListPage(
      title: 'Pesanan Kantin',
      loader: repo.ordersToday,
      emptyText: 'Belum ada pesanan hari ini.',
      actions: <Widget>[
        IconButton(
          tooltip: 'Riwayat dompet siswa',
          icon: const Icon(Icons.receipt_long_outlined),
          onPressed: () async {
            final Map<String, String>? v = await showFormDialog(
              context,
              title: 'Riwayat Dompet',
              fields: const <FormFieldDef>[
                FormFieldDef(
                    key: 'student_id', label: 'ID Siswa', isNumber: true),
              ],
            );
            if (v == null || !context.mounted) return;
            List<Map<String, dynamic>> items = const <Map<String, dynamic>>[];
            String? error;
            try {
              items = await repo.transactions(int.parse(v['student_id']!));
            } catch (e) {
              error = e.toString();
            }
            if (!context.mounted) return;
            await showDialog<void>(
              context: context,
              builder: (BuildContext d) => AlertDialog(
                title: const Text('Riwayat Transaksi'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: error != null
                      ? Text(error)
                      : items.isEmpty
                          ? const Text('Belum ada transaksi.')
                          : SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  for (final Map<String, dynamic> e in items)
                                    ListTile(
                                      dense: true,
                                      title: Text(
                                          '${e['type'] ?? e['kind'] ?? '-'} • Rp ${e['amount'] ?? '-'}'),
                                      subtitle:
                                          Text('${e['created_at'] ?? ''}'),
                                    ),
                                ],
                              ),
                            ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(d).pop(),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
      itemBuilder: (BuildContext c, Map<String, dynamic> e) {
        final int id = (e['id'] as num).toInt();
        final int total = (e['total_amount'] as num?)?.toInt() ?? 0;
        return Card(
          child: ListTile(
            leading: const Icon(Icons.fastfood_outlined),
            title: Text('Order #$id • ${CurrencyFormatter.compact(total)}'),
            subtitle: Text(
                'Status ${e['status'] ?? '-'} • Siswa ${e['student_id'] ?? '-'}'),
            trailing: PopupMenuButton<String>(
              onSelected: (String v) async {
                await runMutation(c, () => repo.updateOrderStatus(id, v));
              },
              itemBuilder: (_) => <PopupMenuItem<String>>[
                for (final String s in _statuses)
                  PopupMenuItem<String>(value: s, child: Text(s)),
              ],
            ),
          ),
        );
      },
    );
  }
}
