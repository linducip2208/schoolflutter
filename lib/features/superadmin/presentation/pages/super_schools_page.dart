import 'package:flutter/material.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
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
                  final List<Map<String, dynamic>> items =
                      snap.data ?? const <Map<String, dynamic>>[];
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
                    itemBuilder: (BuildContext c, int i) => _SchoolCard(
                      school: items[i],
                      onChanged: _reload,
                    ),
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
  const _SchoolCard({required this.school, required this.onChanged});
  final Map<String, dynamic> school;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final bool active = school['is_active'] == true;
    final Map<String, dynamic>? plan = school['plan'] is Map
        ? Map<String, dynamic>.from(school['plan'] as Map)
        : null;
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
            if (expires != null) 's/d ${DateFormatter.dayMonthYear(expires)}',
          ].join(' • '),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Chip(
              label: Text(active ? 'Aktif' : 'Nonaktif',
                  style: const TextStyle(fontSize: 11)),
              visualDensity: VisualDensity.compact,
              backgroundColor:
                  active ? Colors.green.shade100 : Colors.red.shade100,
            ),
            PopupMenuButton<String>(
              onSelected: (String v) =>
                  _act(context, (school['id'] as num).toInt(), v, active),
              itemBuilder: (_) => <PopupMenuItem<String>>[
                PopupMenuItem<String>(
                    value: active ? 'suspend' : 'activate',
                    child: Text(active ? 'Suspend' : 'Aktifkan')),
                const PopupMenuItem<String>(
                    value: 'extend', child: Text('Extend langganan')),
                const PopupMenuItem<String>(
                    value: 'upgrade', child: Text('Upgrade paket')),
                const PopupMenuItem<String>(
                    value: 'log', child: Text('Activity log')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _act(
      BuildContext context, int id, String action, bool active) async {
    final SuperAdminRepository repo = SuperAdminRepository();
    if (action == 'suspend' || action == 'activate') {
      final bool ok = await runMutation(
        context,
        () => active ? repo.suspendSchool(id) : repo.activateSchool(id),
      );
      if (ok) onChanged();
    } else if (action == 'extend' || action == 'upgrade') {
      final Map<String, String>? v = await showFormDialog(
        context,
        title: action == 'extend' ? 'Extend Langganan' : 'Upgrade Paket',
        fields: const <FormFieldDef>[
          FormFieldDef(key: 'plan_id', label: 'ID Paket', isNumber: true),
          FormFieldDef(key: 'expires_at', label: 'Berakhir (YYYY-MM-DD)'),
        ],
      );
      if (v == null || !context.mounted) return;
      final bool ok = await runMutation(
        context,
        () => action == 'extend'
            ? repo.extendSubscription(id,
                planId: int.parse(v['plan_id']!), expiresAt: v['expires_at']!)
            : repo.upgradeSubscription(id,
                planId: int.parse(v['plan_id']!), expiresAt: v['expires_at']!),
      );
      if (ok) onChanged();
    } else if (action == 'log') {
      List<Map<String, dynamic>> items = const <Map<String, dynamic>>[];
      String? error;
      try {
        items = await repo.activityLog(id);
      } catch (e) {
        error = e.toString();
      }
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (BuildContext d) => AlertDialog(
          title: const Text('Activity Log'),
          content: SizedBox(
            width: double.maxFinite,
            child: error != null
                ? Text(error)
                : items.isEmpty
                    ? const Text('Belum ada aktivitas.')
                    : SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            for (final Map<String, dynamic> e in items)
                              ListTile(
                                dense: true,
                                title:
                                    Text(e['description']?.toString() ?? '-'),
                                subtitle: Text('${e['created_at'] ?? ''}'),
                              ),
                          ],
                        ),
                      ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(d).pop(),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    }
  }
}
