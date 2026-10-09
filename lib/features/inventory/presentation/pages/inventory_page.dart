import 'package:flutter/material.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/inventory_repository.dart';

/// Inventaris: aset, pinjam, maintenance.
/// Backend: `/inventory/*`.
class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final InventoryRepository repo = InventoryRepository();
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inventaris'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Aset'),
              Tab(text: 'Pinjaman'),
              Tab(text: 'Maintenance'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            _AssetsTab(repo: repo),
            _LoansTab(repo: repo),
            _MaintenanceTab(repo: repo),
          ],
        ),
      ),
    );
  }
}

class _AssetsTab extends StatelessWidget {
  const _AssetsTab({required this.repo});
  final InventoryRepository repo;

  @override
  Widget build(BuildContext context) {
    return ModuleListPage(
      title: 'Aset',
      loader: repo.assets,
      pagedLoader: ({required int page}) => repo.assets(page: page),
      pageSize: 50,
      emptyText: 'Belum ada aset.',
      onCreate: () async {
        final Map<String, String>? v = await showFormDialog(
          context,
          title: 'Aset Baru',
          fields: const <FormFieldDef>[
            FormFieldDef(
                key: 'asset_category_id', label: 'ID Kategori', isNumber: true),
            FormFieldDef(key: 'name', label: 'Nama barang'),
            FormFieldDef(key: 'location', label: 'Lokasi'),
          ],
        );
        if (v == null || !context.mounted) return;
        await runMutation(
          context,
          () => repo.storeAsset(
            categoryId: int.parse(v['asset_category_id']!),
            name: v['name']!,
            location: v['location'],
          ),
        );
      },
      itemBuilder: (BuildContext c, Map<String, dynamic> e) => Card(
        child: ListTile(
          leading: const Icon(Icons.inventory_2_outlined),
          title: Text(e['name']?.toString() ?? '-'),
          subtitle: Text(
              '${e['asset_code'] ?? '-'} • ${e['status'] ?? '-'} • ${e['location'] ?? '-'}'),
        ),
      ),
    );
  }
}

class _LoansTab extends StatelessWidget {
  const _LoansTab({required this.repo});
  final InventoryRepository repo;

  @override
  Widget build(BuildContext context) {
    return ModuleListPage(
      title: 'Pinjaman',
      loader: repo.loans,
      pagedLoader: ({required int page}) => repo.loans(page: page),
      pageSize: 50,
      emptyText: 'Belum ada pinjaman.',
      itemBuilder: (BuildContext c, Map<String, dynamic> e) {
        final int id = (e['id'] as num).toInt();
        final String status = e['status']?.toString() ?? '-';
        return Card(
          child: ListTile(
            leading: const Icon(Icons.swap_horiz_outlined),
            title: Text(
                'Aset ${e['asset_id'] ?? '-'} → User ${e['user_id'] ?? '-'}'),
            subtitle:
                Text('Status $status • Jatuh tempo ${e['due_at'] ?? '-'}'),
            trailing: status == 'pending'
                ? IconButton(
                    tooltip: 'Setujui',
                    icon: const Icon(Icons.check_circle_outline),
                    onPressed: () async {
                      await runMutation(c, () => repo.approveLoan(id));
                    },
                  )
                : (status == 'approved' || status == 'borrowed')
                    ? IconButton(
                        tooltip: 'Kembalikan',
                        icon: const Icon(Icons.keyboard_return_outlined),
                        onPressed: () async {
                          await runMutation(c, () => repo.returnLoan(id));
                        },
                      )
                    : null,
          ),
        );
      },
    );
  }
}

class _MaintenanceTab extends StatelessWidget {
  const _MaintenanceTab({required this.repo});
  final InventoryRepository repo;

  @override
  Widget build(BuildContext context) {
    return ModuleListPage(
      title: 'Maintenance',
      loader: repo.maintenance,
      pagedLoader: ({required int page}) => repo.maintenance(page: page),
      pageSize: 50,
      emptyText: 'Belum ada laporan maintenance.',
      onCreate: () async {
        final Map<String, String>? v = await showFormDialog(
          context,
          title: 'Lapor Kerusakan',
          fields: const <FormFieldDef>[
            FormFieldDef(key: 'issue_description', label: 'Deskripsi masalah'),
            FormFieldDef(
                key: 'priority',
                label: 'Prioritas',
                options: <String>['low', 'medium', 'high', 'critical']),
          ],
        );
        if (v == null || !context.mounted) return;
        await runMutation(
          context,
          () => repo.reportMaintenance(
            issue: v['issue_description']!,
            priority: v['priority'],
          ),
        );
      },
      itemBuilder: (BuildContext c, Map<String, dynamic> e) {
        final int id = (e['id'] as num).toInt();
        return Card(
          child: ListTile(
            leading: const Icon(Icons.build_outlined),
            title: Text(e['issue_description']?.toString() ?? '-',
                maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text(
                'Prioritas ${e['priority'] ?? '-'} • Status ${e['status'] ?? '-'}'),
            trailing: IconButton(
              tooltip: 'Selesaikan',
              icon: const Icon(Icons.check_circle_outline),
              onPressed: () async {
                await runMutation(c, () => repo.resolveMaintenance(id));
              },
            ),
          ),
        );
      },
    );
  }
}
