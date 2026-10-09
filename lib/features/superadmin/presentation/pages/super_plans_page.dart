import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/superadmin_repository.dart';

/// Paket langganan platform (docs §super §4).
/// Backend: `GET /super/plans`, `GET /super/subscriptions`.
class SuperPlansPage extends StatelessWidget {
  const SuperPlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SuperAdminRepository repo = SuperAdminRepository();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Paket & Langganan'),
          bottom: const TabBar(
            tabs: <Widget>[Tab(text: 'Paket'), Tab(text: 'Transaksi')],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            ModuleListPage(
              title: 'Paket',
              loader: repo.plans,
              emptyText: 'Belum ada paket.',
              onCreate: () async {
                final Map<String, String>? v = await showFormDialog(
                  context,
                  title: 'Paket Baru',
                  fields: const <FormFieldDef>[
                    FormFieldDef(key: 'name', label: 'Nama'),
                    FormFieldDef(key: 'slug', label: 'Slug (unik)'),
                    FormFieldDef(
                        key: 'price', label: 'Harga (Rp)', isNumber: true),
                    FormFieldDef(
                        key: 'max_students',
                        label: 'Maks siswa',
                        isNumber: true),
                  ],
                );
                if (v == null || !context.mounted) return;
                await runMutation(
                  context,
                  () => repo.storePlan(
                    name: v['name']!,
                    slug: v['slug']!,
                    price: int.parse(v['price']!),
                    maxStudents: int.tryParse(v['max_students']!),
                  ),
                );
              },
              itemBuilder: (BuildContext c, Map<String, dynamic> e) => Card(
                child: ListTile(
                  leading: const Icon(Icons.workspace_premium_outlined),
                  title: Text(e['name']?.toString() ?? '-'),
                  subtitle: Text(
                      '${CurrencyFormatter.compact((e['price'] as num?)?.toInt() ?? 0)} • Maks ${e['max_students'] ?? '-'} siswa'),
                ),
              ),
            ),
            ModuleListPage(
              title: 'Transaksi',
              loader: repo.subscriptions,
              emptyText: 'Belum ada transaksi.',
              onCreate: () async {
                final Map<String, String>? v = await showFormDialog(
                  context,
                  title: 'Catat Langganan Manual',
                  fields: const <FormFieldDef>[
                    FormFieldDef(
                        key: 'school_id', label: 'ID Sekolah', isNumber: true),
                    FormFieldDef(
                        key: 'plan_id', label: 'ID Paket', isNumber: true),
                    FormFieldDef(
                        key: 'amount', label: 'Nominal (Rp)', isNumber: true),
                    FormFieldDef(
                        key: 'period_from', label: 'Dari (YYYY-MM-DD)'),
                    FormFieldDef(
                        key: 'period_to', label: 'Sampai (YYYY-MM-DD)'),
                  ],
                );
                if (v == null || !context.mounted) return;
                await runMutation(
                  context,
                  () => repo.storeSubscription(
                    schoolId: int.parse(v['school_id']!),
                    planId: int.parse(v['plan_id']!),
                    amount: int.parse(v['amount']!),
                    periodFrom: v['period_from']!,
                    periodTo: v['period_to']!,
                  ),
                );
              },
              itemBuilder: (BuildContext c, Map<String, dynamic> e) => Card(
                child: ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: Text(CurrencyFormatter.compact(
                      (e['amount'] as num?)?.toInt() ?? 0)),
                  subtitle:
                      Text('${e['status'] ?? '-'} • ${e['created_at'] ?? '-'}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
