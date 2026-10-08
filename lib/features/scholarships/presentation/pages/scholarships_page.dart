import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/scholarships_repository.dart';

/// Beasiswa: admin buat program + grant, siswa apply.
/// Backend: `/scholarship/*`.
class ScholarshipsPage extends StatelessWidget {
  const ScholarshipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ScholarshipsRepository repo = ScholarshipsRepository();
    final String role =
        context.watch<AuthBloc>().state.user?.role ?? 'student';
    final bool canManage = role == 'admin' ||
        role == 'school_admin' ||
        role == 'super_admin';
    return ModuleListPage(
      title: 'Beasiswa',
      loader: repo.programs,
      emptyText: 'Belum ada program beasiswa.',
      onCreate: canManage
          ? () async {
              final Map<String, String>? v = await showFormDialog(
                context,
                title: 'Program Baru',
                fields: const <FormFieldDef>[
                  FormFieldDef(key: 'name', label: 'Nama program'),
                  FormFieldDef(
                      key: 'source',
                      label: 'Sumber',
                      options: <String>[
                        'internal_school',
                        'external_donor',
                        'government',
                        'foundation'
                      ]),
                  FormFieldDef(
                      key: 'discount_type',
                      label: 'Tipe potongan',
                      options: <String>['percentage', 'fixed', 'full']),
                  FormFieldDef(key: 'discount_value', label: 'Nilai potongan', isNumber: true),
                  FormFieldDef(key: 'open_date', label: 'Buka (YYYY-MM-DD)'),
                  FormFieldDef(key: 'close_date', label: 'Tutup (YYYY-MM-DD)'),
                ],
              );
              if (v == null || !context.mounted) return;
              await runMutation(
                context,
                () => repo.storeProgram(
                  name: v['name']!,
                  source: v['source']!,
                  discountType: v['discount_type']!,
                  discountValue: int.parse(v['discount_value']!),
                  openDate: v['open_date']!,
                  closeDate: v['close_date']!,
                ),
              );
            }
          : null,
      itemBuilder: (BuildContext c, Map<String, dynamic> e) {
        final int id = (e['id'] as num).toInt();
        return Card(
          child: ListTile(
            leading: const Icon(Icons.school_outlined),
            title: Text(e['name']?.toString() ?? '-'),
            subtitle: Text(
                '${e['source'] ?? '-'} • ${e['discount_type']} ${e['discount_value'] ?? ''}'),
            trailing: canManage
                ? IconButton(
                    tooltip: 'Lihat pendaftar & grant',
                    icon: const Icon(Icons.how_to_reg_outlined),
                    onPressed: () => _showApplications(c, repo, id),
                  )
                : FilledButton.tonal(
                    onPressed: () async {
                      final Map<String, String>? v = await showFormDialog(
                        c,
                        title: 'Ajukan Beasiswa',
                        fields: const <FormFieldDef>[
                          FormFieldDef(key: 'student_id', label: 'ID Siswa', isNumber: true),
                          FormFieldDef(key: 'motivation', label: 'Motivasi'),
                        ],
                      );
                      if (v == null || !c.mounted) return;
                      await runMutation(
                        c,
                        () => repo.apply(
                          programId: id,
                          studentId: int.parse(v['student_id']!),
                          motivation: v['motivation'],
                        ),
                      );
                    },
                    child: const Text('Ajukan'),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _showApplications(
      BuildContext c, ScholarshipsRepository repo, int programId) async {
    List<Map<String, dynamic>> items = const <Map<String, dynamic>>[];
    String? error;
    try {
      final List<Map<String, dynamic>> all = await repo.applications();
      items = all
          .where((Map<String, dynamic> a) =>
              (a['scholarship_program_id'] as num?)?.toInt() == programId)
          .toList();
    } catch (err) {
      error = err.toString();
    }
    if (!c.mounted) return;
    await showDialog<void>(
      context: c,
      builder: (BuildContext d) => AlertDialog(
        title: const Text('Pendaftar'),
        content: SizedBox(
          width: double.maxFinite,
          child: error != null
              ? Text(error)
              : items.isEmpty
                  ? const Text('Belum ada pendaftar.')
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          for (final Map<String, dynamic> a in items)
                            ListTile(
                              dense: true,
                              title: Text('Siswa ${a['student_id']}'),
                              subtitle:
                                  Text('${a['status'] ?? '-'}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  IconButton(
                                    tooltip: 'Terapkan ke invoice',
                                    icon: const Icon(
                                        Icons.receipt_long_outlined),
                                    onPressed: () async {
                                      final Map<String, String>? f =
                                          await showFormDialog(
                                        d,
                                        title: 'Terapkan ke Invoice',
                                        fields: const <FormFieldDef>[
                                          FormFieldDef(
                                              key: 'invoice_id',
                                              label: 'ID Invoice',
                                              isNumber: true),
                                        ],
                                      );
                                      if (f == null || !d.mounted) return;
                                      final int appId =
                                          (a['id'] as num).toInt();
                                      await runMutation(
                                        d,
                                        () => repo.applyToInvoice(appId,
                                            int.parse(f['invoice_id']!)),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    tooltip: 'Grant',
                                    icon:
                                        const Icon(Icons.check_circle_outline),
                                    onPressed: () async {
                                      final int appId =
                                          (a['id'] as num).toInt();
                                      await runMutation(
                                          d, () => repo.grant(appId));
                                      if (d.mounted) Navigator.of(d).pop();
                                    },
                                  ),
                                ],
                              ),
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
  }
}
