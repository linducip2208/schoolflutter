import 'package:flutter/material.dart';

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
              itemBuilder: (BuildContext c, Map<String, dynamic> e) =>
                  Card(
                child: ListTile(
                  leading: const Icon(Icons.workspace_premium_outlined),
                  title: Text(e['name']?.toString() ?? '-'),
                  subtitle: Text(
                      'Rp ${e['price'] ?? '-'} • Maks ${e['max_students'] ?? '-'} siswa'),
                ),
              ),
            ),
            ModuleListPage(
              title: 'Transaksi',
              loader: repo.subscriptions,
              emptyText: 'Belum ada transaksi.',
              itemBuilder: (BuildContext c, Map<String, dynamic> e) =>
                  Card(
                child: ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: Text('Rp ${e['amount'] ?? '-'}'),
                  subtitle: Text(
                      '${e['status'] ?? '-'} • ${e['created_at'] ?? '-'}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
