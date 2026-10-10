import 'package:flutter/material.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/academic_years_repository.dart';

/// Tahun ajaran + hari libur. Backend: `/academic-years*`, `/holidays`.
class AcademicYearsPage extends StatelessWidget {
  const AcademicYearsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AcademicYearsRepository repo = AcademicYearsRepository();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tahun Ajaran'),
          bottom: const TabBar(
            tabs: <Widget>[Tab(text: 'Tahun'), Tab(text: 'Libur')],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            ModuleListPage(
              title: 'Tahun Ajaran',
              loader: repo.list,
              emptyText: 'Belum ada tahun ajaran.',
              onCreate: () async {
                final Map<String, String>? v = await showFormDialog(
                  context,
                  title: 'Tahun Ajaran Baru',
                  fields: const <FormFieldDef>[
                    FormFieldDef(key: 'name', label: 'Nama (mis. 2026/2027)'),
                    FormFieldDef(
                        key: 'start_date', label: 'Mulai (YYYY-MM-DD)'),
                    FormFieldDef(
                        key: 'end_date', label: 'Selesai (YYYY-MM-DD)'),
                  ],
                );
                if (v == null || !context.mounted) return;
                await runMutation(
                  context,
                  () => repo.store(
                    name: v['name']!,
                    startDate: v['start_date']!,
                    endDate: v['end_date']!,
                  ),
                );
              },
              itemBuilder: (BuildContext c, Map<String, dynamic> e) => Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_month_outlined),
                  title: Text(e['name']?.toString() ?? '-'),
                  subtitle: Text(
                      '${e['start_date'] ?? '-'} → ${e['end_date'] ?? '-'}'),
                  trailing: (e['is_active'] == true)
                      ? const Chip(
                          label: Text('Aktif'),
                          visualDensity: VisualDensity.compact)
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextButton(
                              onPressed: () async {
                                final int id = (e['id'] as num).toInt();
                                await runMutation(c, () => repo.activate(id));
                              },
                              child: const Text('Aktifkan'),
                            ),
                            IconButton(
                              tooltip: 'Ubah nama',
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () async {
                                final Map<String, String>? v =
                                    await showFormDialog(
                                  c,
                                  title: 'Ubah Tahun Ajaran',
                                  fields: <FormFieldDef>[
                                    FormFieldDef(
                                        key: 'name',
                                        label: 'Nama',
                                        initial: e['name']?.toString()),
                                  ],
                                );
                                if (v == null || !c.mounted) return;
                                await runMutation(
                                  c,
                                  () => repo.updateYear(
                                      (e['id'] as num).toInt(),
                                      <String, String>{'name': v['name']!}),
                                );
                              },
                            ),
                          ],
                        ),
                ),
              ),
            ),
            ModuleListPage(
              title: 'Hari Libur',
              loader: repo.holidays,
              emptyText: 'Belum ada hari libur.',
              onCreate: () async {
                final Map<String, String>? v = await showFormDialog(
                  context,
                  title: 'Hari Libur Baru',
                  fields: const <FormFieldDef>[
                    FormFieldDef(key: 'title', label: 'Nama'),
                    FormFieldDef(key: 'date', label: 'Tanggal (YYYY-MM-DD)'),
                    FormFieldDef(
                        key: 'type',
                        label: 'Tipe',
                        options: <String>['national', 'school', 'regional']),
                  ],
                );
                if (v == null || !context.mounted) return;
                await runMutation(
                  context,
                  () => repo.storeHoliday(
                    title: v['title']!,
                    date: v['date']!,
                    type: v['type'],
                  ),
                );
              },
              itemBuilder: (BuildContext c, Map<String, dynamic> e) => Card(
                child: ListTile(
                  leading: const Icon(Icons.beach_access_outlined),
                  title: Text(e['title']?.toString() ?? '-'),
                  subtitle: Text('${e['date'] ?? '-'} • ${e['type'] ?? '-'}'),
                  trailing: IconButton(
                    tooltip: 'Hapus',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final bool? ok = await showDialog<bool>(
                        context: c,
                        builder: (BuildContext d) => AlertDialog(
                          title: const Text('Hapus hari libur?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(d).pop(false),
                              child: const Text('Batal'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(d).pop(true),
                              child: const Text('Hapus'),
                            ),
                          ],
                        ),
                      );
                      if (ok != true || !c.mounted) return;
                      await runMutation(
                        c,
                        () => repo.deleteHoliday((e['id'] as num).toInt()),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
