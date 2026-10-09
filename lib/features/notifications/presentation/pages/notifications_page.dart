import 'package:flutter/material.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/notifications_repository.dart';

/// Notifikasi: daftar + tandai dibaca (tap) + tandai semua.
/// Backend: `/notifications*` via repository (bukan Dio langsung).
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationsRepository _repo = NotificationsRepository();
  late Future<List<Map<String, dynamic>>> _future = _fetch();

  Future<List<Map<String, dynamic>>> _fetch() => _repo.list();

  void _reload() => setState(() => _future = _fetch());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              final bool ok =
                  await runMutation(context, () => _repo.markAllRead());
              if (ok) _reload();
            },
            child: const Text('Tandai semua',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
          if (list.isEmpty) {
            return const AppEmpty(title: 'Belum ada notifikasi');
          }
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
              itemBuilder: (BuildContext c, int i) {
                final Map<String, dynamic> n = list[i];
                final bool unread = (n['read_at'] as String?) == null;
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: const Icon(Icons.notifications_outlined),
                  ),
                  title: Text(n['title'] as String? ?? '-',
                      style: TextStyle(
                          fontWeight:
                              unread ? FontWeight.w700 : FontWeight.w500)),
                  subtitle: Text(n['body'] as String? ?? ''),
                  trailing: Text(
                    n['created_at'] != null
                        ? DateFormatter.relative(
                            DateTime.parse(n['created_at'] as String))
                        : '',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: unread
                      ? () async {
                          final bool ok = await runMutation(
                            c,
                            () => _repo.markRead((n['id'] as num).toInt()),
                          );
                          if (ok) _reload();
                        }
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
