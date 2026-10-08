import 'package:flutter/material.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../data/superadmin_repository.dart';

/// List of all schools (platform view) for `super_admin`.
/// Backend: `GET /api/v1/super/schools` (`paginate(20)`).
class SuperSchoolsPage extends StatefulWidget {
  const SuperSchoolsPage({super.key});

  @override
  State<SuperSchoolsPage> createState() => _SuperSchoolsPageState();
}

class _SuperSchoolsPageState extends State<SuperSchoolsPage> {
  final SuperAdminRepository _repo = SuperAdminRepository();
  final TextEditingController _search = TextEditingController();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.fetchSchools();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = _repo.fetchSchools(search: _search.text.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sekolah')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SearchBar(
              controller: _search,
              hintText: 'Cari sekolah…',
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
                    return const Padding(
                        padding: EdgeInsets.all(24), child: AppLoading());
                  }
                  if (snap.hasError) {
                    return ListView(
                      children: <Widget>[
                        AppError(
                          message: snap.error.toString(),
                          onRetry: _reload,
                        ),
                      ],
                    );
                  }
                  final List<Map<String, dynamic>> items = snap.data ?? const <Map<String, dynamic>>[];
                  if (items.isEmpty) {
                    return ListView(
                      children: const <Widget>[
                        Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                              child: Text('Belum ada sekolah terdaftar.')),
                        ),
                      ],
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (BuildContext c, int i) =>
                        _SchoolCard(school: items[i]),
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

class _SchoolCard extends StatelessWidget {
  const _SchoolCard({required this.school});
  final Map<String, dynamic> school;

  @override
  Widget build(BuildContext context) {
    final bool active = school['is_active'] == true;
    final Map<String, dynamic>? plan =
        school['plan'] is Map ? Map<String, dynamic>.from(school['plan'] as Map) : null;
    final DateTime? expires =
        DateTime.tryParse(school['plan_expires_at']?.toString() ?? '');
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            (school['name']?.toString() ?? '?').isNotEmpty
                ? (school['name'] as String).substring(0, 1).toUpperCase()
                : '?',
          ),
        ),
        title: Text(school['name']?.toString() ?? '-'),
        subtitle: Text(
          <String>[
            if (school['subdomain'] != null) '${school['subdomain']}',
            if (plan?['name'] != null) 'Paket ${plan!['name']}',
            if (expires != null)
              's/d ${DateFormatter.dayMonthYear(expires)}',
          ].join(' • '),
        ),
        trailing: Chip(
          label: Text(active ? 'Aktif' : 'Nonaktif',
              style: const TextStyle(fontSize: 11)),
          visualDensity: VisualDensity.compact,
          backgroundColor: active ? Colors.green.shade100 : Colors.red.shade100,
        ),
      ),
    );
  }
}
