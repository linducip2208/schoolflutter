import 'package:flutter/material.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/transport_repository.dart';

/// Transport admin: rute, kendaraan, assign, trip aktif.
/// Backend: `/transport/*` + `/admin/transport/active-trips`.
class TransportAdminPage extends StatelessWidget {
  const TransportAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TransportRepository repo = TransportRepository();
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transport'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Rute'),
              Tab(text: 'Kendaraan'),
              Tab(text: 'Trip Aktif'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            ModuleListPage(
              title: 'Rute',
              loader: repo.routes,
              emptyText: 'Belum ada rute.',
              onCreate: () async {
                final Map<String, String>? v = await showFormDialog(
                  context,
                  title: 'Rute Baru',
                  fields: const <FormFieldDef>[
                    FormFieldDef(key: 'name', label: 'Nama rute'),
                    FormFieldDef(
                        key: 'stops',
                        label: 'Halte (pisah koma)',
                        hint: 'Halte A, Halte B'),
                  ],
                );
                if (v == null || !context.mounted) return;
                await runMutation(
                  context,
                  () => repo.storeRoute(
                    name: v['name']!,
                    stops: v['stops']!
                        .split(',')
                        .map((String s) => s.trim())
                        .where((String s) => s.isNotEmpty)
                        .toList(),
                  ),
                );
              },
              itemBuilder: (BuildContext c, Map<String, dynamic> e) =>
                  Card(
                child: ListTile(
                  leading: const Icon(Icons.route_outlined),
                  title: Text(e['name']?.toString() ?? '-'),
                  subtitle: Text(
                      '${(e['stops'] is List) ? (e['stops'] as List).length : '-'} halte'),
                  trailing: IconButton(
                    tooltip: 'Assign siswa',
                    icon: const Icon(Icons.person_add_outlined),
                    onPressed: () async {
                      final Map<String, String>? v = await showFormDialog(
                        c,
                        title: 'Assign Siswa',
                        fields: const <FormFieldDef>[
                          FormFieldDef(
                              key: 'student_id',
                              label: 'ID Siswa',
                              isNumber: true),
                        ],
                      );
                      if (v == null || !c.mounted) return;
                      await runMutation(
                        c,
                        () => repo.assignStudent(
                          studentId: int.parse(v['student_id']!),
                          routeId: (e['id'] as num).toInt(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            ModuleListPage(
              title: 'Kendaraan',
              loader: repo.vehicles,
              emptyText: 'Belum ada kendaraan.',
              onCreate: () async {
                final Map<String, String>? v = await showFormDialog(
                  context,
                  title: 'Kendaraan Baru',
                  fields: const <FormFieldDef>[
                    FormFieldDef(key: 'registration_no', label: 'Nopol'),
                    FormFieldDef(key: 'name', label: 'Nama/tipe'),
                  ],
                );
                if (v == null || !context.mounted) return;
                await runMutation(
                  context,
                  () => repo.storeVehicle(
                    registrationNo: v['registration_no']!,
                    name: v['name'],
                  ),
                );
              },
              itemBuilder: (BuildContext c, Map<String, dynamic> e) =>
                  Card(
                child: ListTile(
                  leading: const Icon(Icons.directions_bus_outlined),
                  title: Text(e['registration_no']?.toString() ?? '-'),
                  subtitle: Text(e['name']?.toString() ?? '-'),
                ),
              ),
            ),
            ModuleListPage(
              title: 'Trip Aktif',
              loader: repo.activeTrips,
              emptyText: 'Tidak ada trip aktif.',
              itemBuilder: (BuildContext c, Map<String, dynamic> e) => Card(
                child: ListTile(
                  leading: const Icon(Icons.navigation_outlined),
                  title: Text('Trip ${e['id'] ?? '-'}'),
                  subtitle:
                      Text('${e['route'] ?? e['vehicle'] ?? '-'}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
