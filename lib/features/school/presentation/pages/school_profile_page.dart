import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/school_repository.dart';

/// Profil sekolah: lihat, ubah, upload logo.
/// Backend: `/school/profile`, `/school/logo` (school.manage).
class SchoolProfilePage extends StatefulWidget {
  const SchoolProfilePage({super.key});

  @override
  State<SchoolProfilePage> createState() => _SchoolProfilePageState();
}

class _SchoolProfilePageState extends State<SchoolProfilePage> {
  final SchoolRepository _repo = SchoolRepository();
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.profile();
  }

  void _reload() {
    setState(() {
      _future = _repo.profile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Sekolah')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (BuildContext c, AsyncSnapshot<Map<String, dynamic>> snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Padding(
                padding: EdgeInsets.all(24), child: AppLoading());
          }
          if (snap.hasError) {
            return ListView(children: <Widget>[
              AppError(message: snap.error.toString(), onRetry: _reload),
            ]);
          }
          final Map<String, dynamic> d = snap.data ?? const <String, dynamic>{};
          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              for (final MapEntry<String, dynamic> e in d.entries)
                if (e.value is! Map && e.value is! List)
                  ListTile(
                    dense: true,
                    title: Text(e.key),
                    subtitle: Text('${e.value}'),
                  ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Ubah profil'),
                onPressed: () async {
                  final Map<String, String>? v = await showFormDialog(
                    context,
                    title: 'Ubah Profil Sekolah',
                    fields: <FormFieldDef>[
                      FormFieldDef(
                          key: 'name',
                          label: 'Nama',
                          initial: d['name']?.toString()),
                      FormFieldDef(
                          key: 'email',
                          label: 'Email',
                          initial: d['email']?.toString(),
                          optional: true),
                      FormFieldDef(
                          key: 'phone',
                          label: 'Telepon',
                          initial: d['phone']?.toString(),
                          optional: true),
                      FormFieldDef(
                          key: 'address',
                          label: 'Alamat',
                          initial: d['address']?.toString(),
                          optional: true),
                    ],
                  );
                  if (v == null || !context.mounted) return;
                  final Map<String, String> payload = <String, String>{
                    'name': v['name']!,
                    if (v['email']!.isNotEmpty) 'email': v['email']!,
                    if (v['phone']!.isNotEmpty) 'phone': v['phone']!,
                    if (v['address']!.isNotEmpty) 'address': v['address']!,
                  };
                  final bool ok = await runMutation(
                      context, () => _repo.updateProfile(payload));
                  if (ok) _reload();
                },
              ),
              const SizedBox(height: 8),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.upload_outlined),
                label: const Text('Upload logo'),
                onPressed: () async {
                  final FilePickerResult? picked =
                      await FilePicker.platform.pickFiles(type: FileType.image);
                  final String? path = picked?.files.single.path;
                  if (path == null || !context.mounted) return;
                  final bool ok =
                      await runMutation(context, () => _repo.uploadLogo(path));
                  if (ok) _reload();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
