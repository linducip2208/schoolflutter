import 'package:flutter/material.dart';

import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/superadmin_repository.dart';

/// System: config + health (docs §super §8, §10).
/// Backend: `/super/system/config`, `/health/deep`.
class SuperSystemPage extends StatefulWidget {
  const SuperSystemPage({super.key});

  @override
  State<SuperSystemPage> createState() => _SuperSystemPageState();
}

class _SuperSystemPageState extends State<SuperSystemPage> {
  final SuperAdminRepository _repo = SuperAdminRepository();
  late Future<Map<String, dynamic>> _config;
  late Future<Map<String, dynamic>> _health;

  @override
  void initState() {
    super.initState();
    _config = _repo.systemConfig();
    _health = _repo.deepHealth();
  }

  void _reload() {
    setState(() {
      _config = _repo.systemConfig();
      _health = _repo.deepHealth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistem'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text('Health Check', style: Theme.of(context).textTheme.titleSmall),
          FutureBuilder<Map<String, dynamic>>(
            future: _health,
            builder: (BuildContext c,
                AsyncSnapshot<Map<String, dynamic>> snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                    padding: EdgeInsets.all(12), child: AppLoading());
              }
              if (snap.hasError) {
                return AppError(message: snap.error.toString());
              }
              final Map<String, dynamic> d =
                  snap.data ?? const <String, dynamic>{};
              return Card(
                child: Column(
                  children: <Widget>[
                    for (final MapEntry<String, dynamic> e in d.entries)
                      ListTile(
                        dense: true,
                        title: Text(e.key),
                        trailing: Text('${e.value}'),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text('Konfigurasi',
              style: Theme.of(context).textTheme.titleSmall),
          FutureBuilder<Map<String, dynamic>>(
            future: _config,
            builder: (BuildContext c,
                AsyncSnapshot<Map<String, dynamic>> snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                    padding: EdgeInsets.all(12), child: AppLoading());
              }
              if (snap.hasError) {
                return AppError(message: snap.error.toString());
              }
              final Map<String, dynamic> d =
                  snap.data ?? const <String, dynamic>{};
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
        ],
      ),
    );
  }
}
