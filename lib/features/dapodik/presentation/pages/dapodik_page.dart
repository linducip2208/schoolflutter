import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/dapodik_repository.dart';

/// Sinkronisasi Dapodik: config, tes koneksi, runs, konflik.
/// Backend: `/admin/dapodik/*`.
class DapodikPage extends StatefulWidget {
  const DapodikPage({super.key});

  @override
  State<DapodikPage> createState() => _DapodikPageState();
}

class _DapodikPageState extends State<DapodikPage> {
  final DapodikRepository _repo = DapodikRepository();
  late Future<Map<String, dynamic>> _config;

  @override
  void initState() {
    super.initState();
    _config = _repo.config();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dapodik Sync'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Config'),
              Tab(text: 'Runs'),
              Tab(text: 'Konflik'),
            ],
          ),
          actions: <Widget>[
            IconButton(
              tooltip: 'Export siswa (CSV)',
              icon: const Icon(Icons.download_outlined),
              onPressed: () async {
                await runMutation(context, () => _repo.exportStudents());
              },
            ),
            IconButton(
              tooltip: 'Import siswa (CSV)',
              icon: const Icon(Icons.upload_file_outlined),
              onPressed: () async {
                final FilePickerResult? picked = await FilePicker.platform
                    .pickFiles(
                        type: FileType.custom,
                        allowedExtensions: const <String>['csv', 'txt']);
                final String? path = picked?.files.single.path;
                if (path == null || !context.mounted) return;
                await runMutation(context, () => _repo.importStudents(path));
              },
            ),
            IconButton(
              tooltip: 'Tes koneksi',
              icon: const Icon(Icons.wifi_find_outlined),
              onPressed: () async {
                Map<String, dynamic>? res;
                String? error;
                try {
                  res = await _repo.testConnection();
                } catch (e) {
                  error = e.toString();
                }
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error ?? res.toString())),
                );
              },
            ),
          ],
        ),
        body: TabBarView(
          children: <Widget>[
            FutureBuilder<Map<String, dynamic>>(
              future: _config,
              builder:
                  (BuildContext c, AsyncSnapshot<Map<String, dynamic>> snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                      padding: EdgeInsets.all(24), child: AppLoading());
                }
                if (snap.hasError) {
                  return ListView(children: <Widget>[
                    AppError(
                      message: snap.error.toString(),
                      onRetry: () => setState(() {
                        _config = _repo.config();
                      }),
                    ),
                  ]);
                }
                final Map<String, dynamic> d =
                    snap.data ?? const <String, dynamic>{};
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    for (final MapEntry<String, dynamic> e in d.entries)
                      ListTile(
                        dense: true,
                        title: Text(e.key),
                        subtitle: Text('${e.value}'),
                      ),
                  ],
                );
              },
            ),
            ModuleListPage(
              title: 'Runs',
              loader: () async => _repo.runs(),
              emptyText: 'Belum ada run sinkronisasi.',
              itemBuilder: (BuildContext c, Map<String, dynamic> e) {
                final int id = (e['id'] as num?)?.toInt() ?? 0;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.sync_outlined),
                    title: Text('Run #$id • ${e['status'] ?? '-'}'),
                    subtitle: Text('${e['created_at'] ?? '-'}'),
                    trailing: IconButton(
                      tooltip: 'Konfirmasi',
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: () async {
                        await runMutation(c, () => _repo.confirmRun(id));
                      },
                    ),
                  ),
                );
              },
            ),
            ModuleListPage(
              title: 'Konflik',
              loader: () async => _repo.conflicts(),
              emptyText: 'Tidak ada konflik.',
              itemBuilder: (BuildContext c, Map<String, dynamic> e) {
                final int id = (e['id'] as num?)?.toInt() ?? 0;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.warning_amber_outlined),
                    title: Text(e['description']?.toString() ?? 'Konflik #$id'),
                    trailing: IconButton(
                      tooltip: 'Resolve (pakai data lokal)',
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: () async {
                        await runMutation(
                            c, () => _repo.resolveConflict(id, 'local'));
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
