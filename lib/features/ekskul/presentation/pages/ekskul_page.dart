import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/ekskul_repository.dart';

/// Ekstrakurikuler: daftar, buat, enroll, absensi.
/// Backend: `/ekskul*` (`ekskul.manage` untuk kelola).
class EkskulPage extends StatelessWidget {
  const EkskulPage({super.key});

  static bool _canManage(String role) =>
      role == 'admin' ||
      role == 'school_admin' ||
      role == 'super_admin' ||
      role == 'teacher';

  @override
  Widget build(BuildContext context) {
    final EkskulRepository repo = EkskulRepository();
    final String role = context.watch<AuthBloc>().state.user?.role ?? 'student';
    final bool canManage = _canManage(role);
    return ModuleListPage(
      title: 'Ekstrakurikuler',
      loader: repo.list,
      emptyText: 'Belum ada ekskul.',
      onCreate: canManage
          ? () async {
              final Map<String, String>? v = await showFormDialog(
                context,
                title: 'Ekskul Baru',
                fields: const <FormFieldDef>[
                  FormFieldDef(key: 'name', label: 'Nama'),
                  FormFieldDef(key: 'description', label: 'Deskripsi'),
                ],
              );
              if (v == null || !context.mounted) return;
              await runMutation(
                context,
                () =>
                    repo.store(name: v['name']!, description: v['description']),
              );
            }
          : null,
      itemBuilder: (BuildContext c, Map<String, dynamic> e) {
        final int id = (e['id'] as num).toInt();
        return Card(
          child: ListTile(
            leading: const Icon(Icons.sports_soccer_outlined),
            title: Text(e['name']?.toString() ?? '-'),
            subtitle: Text(e['description']?.toString() ?? '-',
                maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: canManage
                ? IconButton(
                    tooltip: 'Enroll siswa',
                    icon: const Icon(Icons.person_add_outlined),
                    onPressed: () async {
                      final Map<String, String>? v = await showFormDialog(
                        c,
                        title: 'Enroll Siswa',
                        fields: const <FormFieldDef>[
                          FormFieldDef(
                              key: 'student_id',
                              label: 'ID Siswa',
                              isNumber: true),
                        ],
                      );
                      if (v == null || !c.mounted) return;
                      await runMutation(
                        c,
                        () => repo.enroll(id, int.parse(v['student_id']!)),
                      );
                    },
                  )
                : null,
          ),
        );
      },
    );
  }
}
