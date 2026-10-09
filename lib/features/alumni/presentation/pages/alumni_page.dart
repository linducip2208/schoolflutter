import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/alumni_repository.dart';

/// Alumni: profil saya + verifikasi admin.
/// Backend: `/alumni/profile`, `/admin/alumni/{id}/verify` (`role:admin`).
class AlumniPage extends StatefulWidget {
  const AlumniPage({super.key});

  @override
  State<AlumniPage> createState() => _AlumniPageState();
}

class _AlumniPageState extends State<AlumniPage> {
  final AlumniRepository _repo = AlumniRepository();
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.profile();
  }

  @override
  Widget build(BuildContext context) {
    final String role = context.watch<AuthBloc>().state.user?.role ?? 'student';
    final bool isAdmin =
        role == 'admin' || role == 'school_admin' || role == 'super_admin';
    return Scaffold(
      appBar: AppBar(title: const Text('Alumni')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          FutureBuilder<Map<String, dynamic>>(
            future: _future,
            builder:
                (BuildContext c, AsyncSnapshot<Map<String, dynamic>> snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                    padding: EdgeInsets.all(24), child: AppLoading());
              }
              if (snap.hasError) {
                return AppError(
                  message: snap.error.toString(),
                  onRetry: () => setState(() {
                    _future = _repo.profile();
                  }),
                );
              }
              final Map<String, dynamic> d =
                  snap.data ?? const <String, dynamic>{};
              if (d.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Belum ada profil alumni.'),
                  ),
                );
              }
              return Card(
                child: Column(
                  children: <Widget>[
                    for (final MapEntry<String, dynamic> e in d.entries)
                      ListTile(
                        dense: true,
                        title: Text(e.key),
                        subtitle: Text('${e.value}'),
                      ),
                  ],
                ),
              );
            },
          ),
          if (isAdmin) ...<Widget>[
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.verified_outlined),
              label: const Text('Verifikasi alumni (by ID)'),
              onPressed: () async {
                final Map<String, String>? v = await showFormDialog(
                  context,
                  title: 'Verifikasi',
                  fields: const <FormFieldDef>[
                    FormFieldDef(key: 'id', label: 'ID Alumni', isNumber: true),
                  ],
                );
                if (v == null || !context.mounted) return;
                await runMutation(
                    context, () => _repo.verify(int.parse(v['id']!)));
              },
            ),
          ],
        ],
      ),
    );
  }
}
