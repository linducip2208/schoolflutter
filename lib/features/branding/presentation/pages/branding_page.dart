import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/branding_admin_repository.dart';

/// Branding white-label sekolah: lihat, ubah, upload logo.
/// Backend: `GET /branding`, `PUT /admin/branding`,
/// `POST /admin/branding/upload-logo`.
class BrandingPage extends StatefulWidget {
  const BrandingPage({super.key});

  @override
  State<BrandingPage> createState() => _BrandingPageState();
}

class _BrandingPageState extends State<BrandingPage> {
  final BrandingAdminRepository _repo = BrandingAdminRepository();
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.mine();
  }

  void _reload() {
    setState(() {
      _future = _repo.mine();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Branding')),
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
                ListTile(
                  dense: true,
                  title: Text(e.key),
                  subtitle: Text('${e.value}'),
                ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Ubah (nama / warna)'),
                onPressed: () async {
                  final Map<String, String>? v = await showFormDialog(
                    context,
                    title: 'Ubah Branding',
                    fields: <FormFieldDef>[
                      FormFieldDef(
                          key: 'display_name',
                          label: 'Nama tampil sekolah',
                          initial: d['display_name']?.toString()),
                      FormFieldDef(
                          key: 'color_primary',
                          label: 'Warna primer (hex)',
                          hint: '#2563EB',
                          initial: d['color_primary']?.toString()),
                    ],
                  );
                  if (v == null || !context.mounted) return;
                  final Map<String, String> payload = <String, String>{
                    if (v['display_name']!.isNotEmpty)
                      'display_name': v['display_name']!,
                    if (v['color_primary']!.isNotEmpty)
                      'color_primary': v['color_primary']!,
                  };
                  final bool ok =
                      await runMutation(context, () => _repo.update(payload));
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
