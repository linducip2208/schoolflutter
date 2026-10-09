import 'package:flutter/material.dart';

import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../data/foundation_repository.dart';

/// Dashboard yayasan: multi-school overview.
/// Backend: `/foundations/mine`, `/foundations/{id}/dashboard`.
class FoundationPage extends StatefulWidget {
  const FoundationPage({super.key});

  @override
  State<FoundationPage> createState() => _FoundationPageState();
}

class _FoundationPageState extends State<FoundationPage> {
  final FoundationRepository _repo = FoundationRepository();
  late Future<List<Map<String, dynamic>>> _mine;
  Future<Map<String, dynamic>>? _dashboard;
  int? _selected;

  @override
  void initState() {
    super.initState();
    _mine = _repo.mine();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yayasan')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _mine,
        builder:
            (BuildContext c, AsyncSnapshot<List<Map<String, dynamic>>> snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Padding(
                padding: EdgeInsets.all(24), child: AppLoading());
          }
          if (snap.hasError) {
            return ListView(children: <Widget>[
              AppError(
                message: snap.error.toString(),
                onRetry: () => setState(() {
                  _mine = _repo.mine();
                }),
              ),
            ]);
          }
          final List<Map<String, dynamic>> items =
              snap.data ?? const <Map<String, dynamic>>[];
          if (items.isEmpty) {
            return const Center(child: Text('Tidak ada yayasan terdaftar.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              DropdownButtonFormField<int>(
                initialValue: _selected,
                decoration: const InputDecoration(labelText: 'Pilih yayasan'),
                items: <DropdownMenuItem<int>>[
                  for (final Map<String, dynamic> f in items)
                    DropdownMenuItem<int>(
                      value: (f['id'] as num).toInt(),
                      child: Text(f['name']?.toString() ?? '-'),
                    ),
                ],
                onChanged: (int? v) => setState(() {
                  _selected = v;
                  _dashboard = v == null ? null : _repo.dashboard(v);
                }),
              ),
              const SizedBox(height: 12),
              if (_dashboard != null)
                FutureBuilder<Map<String, dynamic>>(
                  future: _dashboard,
                  builder: (BuildContext c2,
                      AsyncSnapshot<Map<String, dynamic>> s2) {
                    if (s2.connectionState == ConnectionState.waiting) {
                      return const Padding(
                          padding: EdgeInsets.all(24), child: AppLoading());
                    }
                    if (s2.hasError) {
                      return AppError(message: s2.error.toString());
                    }
                    final Map<String, dynamic> d =
                        s2.data ?? const <String, dynamic>{};
                    return Column(
                      children: <Widget>[
                        for (final MapEntry<String, dynamic> e in d.entries)
                          Card(
                            child: ListTile(
                              dense: true,
                              title: Text(e.key),
                              subtitle: Text('${e.value}'),
                            ),
                          ),
                      ],
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
