import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/payroll_repository.dart';

/// Slip gaji: daftar + generate + tandai lunas + struktur.
/// Backend: `/payroll/*` (rupiah penuh; generate `{staff_id, month}`).
class PayrollPage extends StatefulWidget {
  const PayrollPage({super.key});

  @override
  State<PayrollPage> createState() => _PayrollPageState();
}

class _PayrollPageState extends State<PayrollPage> {
  final PayrollRepository _repo = PayrollRepository();
  late Future<List<Map<String, dynamic>>> _future = _fetch();

  Future<List<Map<String, dynamic>>> _fetch() => _repo.slips();

  void _reload() => setState(() => _future = _fetch());

  String _staffName(Map<String, dynamic> p) {
    final dynamic staff = p['staff'];
    if (staff is Map) {
      final dynamic user = staff['user'];
      if (user is Map && user['name'] != null) {
        return user['name'].toString();
      }
      if (staff['employee_id'] != null) {
        return 'ID ${staff['employee_id']}';
      }
    }
    return 'Staf ${p['staff_id'] ?? '-'}';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Penggajian'),
          bottom: const TabBar(
            tabs: <Widget>[Tab(text: 'Slip'), Tab(text: 'Struktur')],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            _SlipsTab(repo: _repo, onChanged: _reload, future: _future),
            ModuleListPage(
              title: 'Struktur',
              loader: _repo.structures,
              emptyText: 'Belum ada struktur gaji.',
              onCreate: () async {
                final Map<String, String>? v = await showFormDialog(
                  context,
                  title: 'Struktur Baru',
                  fields: const <FormFieldDef>[
                    FormFieldDef(key: 'name', label: 'Nama'),
                    FormFieldDef(
                        key: 'type',
                        label: 'Tipe',
                        options: <String>['allowance', 'deduction']),
                    FormFieldDef(
                        key: 'calculation',
                        label: 'Hitung',
                        options: <String>['fixed', 'percentage']),
                    FormFieldDef(
                        key: 'value', label: 'Nilai (Rp / %)', isNumber: true),
                  ],
                );
                if (v == null || !context.mounted) return;
                await runMutation(
                  context,
                  () => _repo.storeStructure(
                    name: v['name']!,
                    type: v['type']!,
                    calculation: v['calculation']!,
                    value: int.parse(v['value']!),
                  ),
                );
              },
              itemBuilder: (BuildContext c, Map<String, dynamic> e) => Card(
                child: ListTile(
                  leading: const Icon(Icons.request_quote_outlined),
                  title: Text(e['name']?.toString() ?? '-'),
                  subtitle:
                      Text('${e['type'] ?? '-'} • ${e['calculation'] ?? '-'}'),
                  trailing: Text('${e['value'] ?? '-'}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlipsTab extends StatelessWidget {
  const _SlipsTab(
      {required this.repo, required this.onChanged, required this.future});
  final PayrollRepository repo;
  final VoidCallback onChanged;
  final Future<List<Map<String, dynamic>>> future;

  String _staffName(Map<String, dynamic> p) {
    final dynamic staff = p['staff'];
    if (staff is Map) {
      final dynamic user = staff['user'];
      if (user is Map && user['name'] != null) {
        return user['name'].toString();
      }
    }
    return 'Staf ${p['staff_id'] ?? '-'}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Slip'),
        onPressed: () async {
          final Map<String, String>? v = await showFormDialog(
            context,
            title: 'Generate Slip',
            fields: const <FormFieldDef>[
              FormFieldDef(key: 'staff_id', label: 'ID Staf', isNumber: true),
              FormFieldDef(
                  key: 'month', label: 'Bulan (YYYY-MM)', hint: '2026-10'),
            ],
          );
          if (v == null || !context.mounted) return;
          final bool ok = await runMutation(
            context,
            () => repo.generateSlip(
                staffId: int.parse(v['staff_id']!), month: v['month']!),
          );
          if (ok) onChanged();
        },
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: future,
        builder:
            (BuildContext c, AsyncSnapshot<List<Map<String, dynamic>>> snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const AppLoading();
          }
          if (snap.hasError) {
            return AppError(message: '${snap.error}', onRetry: onChanged);
          }
          final List<Map<String, dynamic>> list =
              snap.data ?? <Map<String, dynamic>>[];
          if (list.isEmpty) {
            return const AppEmpty(title: 'Belum ada slip gaji');
          }
          return RefreshIndicator(
            onRefresh: () async => onChanged(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (BuildContext c, int i) {
                final Map<String, dynamic> p = list[i];
                final int net = (p['net_salary'] as num?)?.toInt() ?? 0;
                final String status = p['status']?.toString() ?? '-';
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    title: Text(_staffName(p)),
                    subtitle: Text('${p['month'] ?? '-'} • Status $status'),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(CurrencyFormatter.compact(net),
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        if (status != 'paid')
                          TextButton(
                            onPressed: () async {
                              final bool ok = await runMutation(
                                c,
                                () => repo.markPaid((p['id'] as num).toInt()),
                              );
                              if (ok) onChanged();
                            },
                            child: const Text('Tandai lunas'),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
