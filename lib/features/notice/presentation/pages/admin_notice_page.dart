import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/notice_repository.dart';

class AdminNoticePage extends StatefulWidget {
  const AdminNoticePage({super.key});

  @override
  State<AdminNoticePage> createState() => _AdminNoticePageState();
}

class _AdminNoticePageState extends State<AdminNoticePage> {
  final NoticeRepository _repo = NoticeRepository();
  late Future<List<Map<String, dynamic>>> _future = _repo.list();

  void _reload() => setState(() => _future = _repo.list());

  Future<void> _showCreateSheet() async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController title = TextEditingController();
    final TextEditingController body = TextEditingController();
    final TextEditingController publishAt = TextEditingController();
    final TextEditingController roles = TextEditingController();
    bool sending = false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetCtx) {
        return StatefulBuilder(
          builder: (BuildContext c, void Function(void Function()) setS) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(c).viewInsets.bottom + 16,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Buat Pengumuman',
                        style: Theme.of(c).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: title,
                      decoration: const InputDecoration(labelText: 'Judul'),
                      validator: (String? v) =>
                          Validators.required(v, label: 'Judul'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: body,
                      maxLines: 5,
                      decoration: const InputDecoration(labelText: 'Isi'),
                      validator: (String? v) =>
                          Validators.required(v, label: 'Isi'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: roles,
                      decoration: const InputDecoration(
                        labelText: 'Target role (opsional, koma)',
                        hintText: 'student,parent,teacher',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: publishAt,
                      decoration: const InputDecoration(
                        labelText: 'Jadwal tayang (opsional)',
                        hintText: '2026-10-15 07:00',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: sending
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setS(() => sending = true);
                                try {
                                  await _repo.create(
                                    title: title.text.trim(),
                                    body: body.text.trim(),
                                    targetRoles: roles.text
                                        .split(',')
                                        .map((String s) => s.trim())
                                        .where((String s) => s.isNotEmpty)
                                        .toList(),
                                    publishAt: publishAt.text.trim().isEmpty
                                        ? null
                                        : publishAt.text.trim(),
                                  );
                                  if (!c.mounted) return;
                                  Navigator.of(c).pop();
                                  _reload();
                                } catch (e) {
                                  if (!c.mounted) return;
                                  ScaffoldMessenger.of(c).showSnackBar(
                                      SnackBar(content: Text(e.toString())));
                                } finally {
                                  if (c.mounted) setS(() => sending = false);
                                }
                              },
                        child: sending
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text('Publikasikan'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // notice.manage gate: principal & others read-only.
    final String role = context.watch<AuthBloc>().state.user?.role ?? 'admin';
    final bool canManage =
        role == 'admin' || role == 'school_admin' || role == 'super_admin';
    return Scaffold(
      appBar: AppBar(title: const Text('Pengumuman')),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: _showCreateSheet,
              icon: const Icon(Icons.add),
              label: const Text('Buat'),
            )
          : null,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder:
            (BuildContext c, AsyncSnapshot<List<Map<String, dynamic>>> snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const AppLoading();
          }
          if (snap.hasError) {
            return AppError(message: '${snap.error}', onRetry: _reload);
          }
          final List<Map<String, dynamic>> list =
              snap.data ?? <Map<String, dynamic>>[];
          if (list.isEmpty)
            return const AppEmpty(title: 'Belum ada pengumuman');
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (BuildContext c, int i) {
                final Map<String, dynamic> n = list[i];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    title: Text(n['title'] as String? ?? '-'),
                    subtitle: Text(
                      n['published_at'] != null
                          ? DateFormatter.relative(
                              DateTime.parse(n['published_at'] as String))
                          : '',
                    ),
                    trailing: canManage
                        ? IconButton(
                            tooltip: 'Hapus',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              final bool? ok = await showDialog<bool>(
                                context: c,
                                builder: (BuildContext d) => AlertDialog(
                                  title: const Text('Hapus pengumuman?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(d).pop(false),
                                      child: const Text('Batal'),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.of(d).pop(true),
                                      child: const Text('Hapus'),
                                    ),
                                  ],
                                ),
                              );
                              if (ok != true || !c.mounted) return;
                              final bool done = await runMutation(
                                c,
                                () => _repo.remove((n['id'] as num).toInt()),
                              );
                              if (done) _reload();
                            },
                          )
                        : null,
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
