import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/hostel_repository.dart';

class HostelPage extends StatefulWidget {
  const HostelPage({super.key});

  @override
  State<HostelPage> createState() => _HostelPageState();
}

class _HostelPageState extends State<HostelPage> {
  final HostelRepository _repo = HostelRepository();
  late Future<List<Map<String, dynamic>>> _future = _repo.hostels();

  void _reload() => setState(() => _future = _repo.hostels());

  @override
  Widget build(BuildContext context) {
    final String role = context.watch<AuthBloc>().state.user?.role ?? 'student';
    final bool canManage = role == 'admin' ||
        role == 'school_admin' ||
        role == 'super_admin' ||
        role == 'hostel_admin';
    return Scaffold(
      appBar: AppBar(title: const Text('Asrama')),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Asrama'),
              onPressed: () async {
                final Map<String, String>? v = await showFormDialog(
                  context,
                  title: 'Asrama Baru',
                  fields: const <FormFieldDef>[
                    FormFieldDef(key: 'name', label: 'Nama'),
                    FormFieldDef(
                        key: 'type',
                        label: 'Tipe',
                        options: <String>['boys', 'girls', 'mixed']),
                  ],
                );
                if (v == null || !context.mounted) return;
                final bool ok = await runMutation(
                  context,
                  () => _repo.store(name: v['name']!, type: v['type']!),
                );
                if (ok) _reload();
              },
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
          if (list.isEmpty) return const AppEmpty(title: 'Belum ada asrama');
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (BuildContext c, int i) {
                final Map<String, dynamic> h = list[i];
                final int totalRooms = (h['rooms_count'] as num?)?.toInt() ?? 0;
                final int occupied =
                    (h['occupied_count'] as num?)?.toInt() ?? 0;
                final double pct = totalRooms == 0 ? 0 : occupied / totalRooms;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            CircleAvatar(
                              backgroundColor:
                                  AppColors.secondary.withValues(alpha: 0.12),
                              child: const Icon(Icons.apartment_outlined,
                                  color: AppColors.secondary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(h['name'] as String? ?? '-',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge),
                                  Text(
                                    '${h['type'] ?? 'mixed'} • ${h['address'] ?? ''}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: pct,
                          backgroundColor: AppColors.borderLight,
                          color: pct > 0.85
                              ? AppColors.danger
                              : AppColors.secondary,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Terisi $occupied / $totalRooms kamar',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (canManage)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              icon: const Icon(Icons.bed_outlined, size: 18),
                              label: const Text('Kamar & alokasi'),
                              onPressed: () =>
                                  _openRooms(c, h, (h['id'] as num).toInt()),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _openRooms(
      BuildContext context, Map<String, dynamic> hostel, int hostelId) async {
    List<Map<String, dynamic>> rooms = const <Map<String, dynamic>>[];
    String? error;
    try {
      rooms = await _repo.rooms(hostelId);
    } catch (e) {
      error = e.toString();
    }
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (BuildContext d) => AlertDialog(
        title: Text('Kamar — ${hostel['name'] ?? ''}'),
        content: SizedBox(
          width: double.maxFinite,
          child: error != null
              ? Text(error)
              : rooms.isEmpty
                  ? const Text('Belum ada kamar.')
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          for (final Map<String, dynamic> r in rooms)
                            ListTile(
                              dense: true,
                              title: Text(
                                  'Kamar ${r['room_no'] ?? r['name'] ?? '-'}'),
                              subtitle:
                                  Text('Kapasitas ${r['capacity'] ?? '-'}'),
                              trailing: IconButton(
                                tooltip: 'Alokasikan siswa',
                                icon: const Icon(Icons.person_add_outlined),
                                onPressed: () async {
                                  final Map<String, String>? v =
                                      await showFormDialog(
                                    d,
                                    title: 'Alokasi Kamar',
                                    fields: const <FormFieldDef>[
                                      FormFieldDef(
                                          key: 'student_id',
                                          label: 'ID Siswa',
                                          isNumber: true),
                                      FormFieldDef(
                                          key: 'from_date',
                                          label: 'Mulai (YYYY-MM-DD)'),
                                    ],
                                  );
                                  if (v == null || !d.mounted) return;
                                  await runMutation(
                                    d,
                                    () => _repo.allocate(
                                      studentId: int.parse(v['student_id']!),
                                      roomId: (r['id'] as num).toInt(),
                                      fromDate: v['from_date']!,
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              final Map<String, String>? v = await showFormDialog(
                d,
                title: 'Kamar Baru',
                fields: const <FormFieldDef>[
                  FormFieldDef(key: 'room_no', label: 'Nomor kamar'),
                  FormFieldDef(
                      key: 'capacity',
                      label: 'Kapasitas',
                      isNumber: true,
                      initial: '4'),
                ],
              );
              if (v == null || !d.mounted) return;
              await runMutation(
                d,
                () => _repo.storeRoom(
                  hostelId: hostelId,
                  roomNo: v['room_no']!,
                  capacity: int.tryParse(v['capacity']!),
                ),
              );
              if (d.mounted) Navigator.of(d).pop();
            },
            child: const Text('Tambah kamar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(d).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
