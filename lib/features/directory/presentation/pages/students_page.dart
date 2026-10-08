import 'package:flutter/material.dart';

import '../../../../core/widgets/module_list_page.dart';
import '../../data/directory_repository.dart';

/// Direktori siswa: cari, filter rombel (docs §admin §2.7).
/// Backend: `GET /directory/students` (`student.view`).
class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final DirectoryRepository _repo = DirectoryRepository();
  final TextEditingController _search = TextEditingController();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.students();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = _repo.students(search: _search.text.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Siswa')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SearchBar(
              controller: _search,
              hintText: 'Cari nama / NIS…',
              leading: const Icon(Icons.search),
              onSubmitted: (_) => _reload(),
              trailing: <Widget>[
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _search.clear();
                    _reload();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _reload(),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _future,
                builder: (BuildContext c,
                    AsyncSnapshot<List<Map<String, dynamic>>> snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return ListView(children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: <Widget>[
                            Text('${snap.error}'),
                            TextButton(
                                onPressed: _reload,
                                child: const Text('Coba lagi')),
                          ],
                        ),
                      ),
                    ]);
                  }
                  final List<Map<String, dynamic>> items =
                      snap.data ?? const <Map<String, dynamic>>[];
                  if (items.isEmpty) {
                    return const Center(child: Text('Tidak ada siswa.'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (BuildContext c, int i) {
                      final Map<String, dynamic> e = items[i];
                      final Map<String, dynamic>? user = e['user'] is Map
                          ? Map<String, dynamic>.from(e['user'] as Map)
                          : null;
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(((user?['name'] ?? '?') as String)
                                    .isNotEmpty
                                ? ((user?['name'] ?? '?') as String)
                                    .substring(0, 1)
                                    .toUpperCase()
                                : '?'),
                          ),
                          title: Text(
                              user?['name']?.toString() ?? 'ID ${e['id']}'),
                          subtitle: Text(
                              'NIS ${e['admission_no'] ?? '-'} • Rombel ${e['class_section_id'] ?? '-'}'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
