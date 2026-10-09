import 'package:flutter/material.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/medical_repository.dart';

/// UKS: log kunjungan + vaksinasi.
/// Backend: `/medical/visits`, `/medical/students/{id}/vaccinations`.
class MedicalManagePage extends StatelessWidget {
  const MedicalManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final MedicalRepository repo = MedicalRepository();
    return ModuleListPage(
      title: 'UKS / Klinik',
      loader: repo.allVisits,
      pagedLoader: ({required int page}) => repo.allVisits(page: page),
      pageSize: 50,
      emptyText: 'Belum ada kunjungan.',
      onCreate: () async {
        final Map<String, String>? v = await showFormDialog(
          context,
          title: 'Kunjungan Baru',
          fields: const <FormFieldDef>[
            FormFieldDef(key: 'student_id', label: 'ID Siswa', isNumber: true),
            FormFieldDef(key: 'symptoms', label: 'Keluhan'),
            FormFieldDef(key: 'diagnosis', label: 'Diagnosis'),
          ],
        );
        if (v == null || !context.mounted) return;
        await runMutation(
          context,
          () => repo.storeVisit(
            studentId: int.parse(v['student_id']!),
            symptoms: v['symptoms']!,
            diagnosis: v['diagnosis'],
          ),
        );
      },
      itemBuilder: (BuildContext c, Map<String, dynamic> e) => Card(
        child: ListTile(
          leading: const Icon(Icons.medical_services_outlined),
          title: Text(e['symptoms']?.toString() ?? '-',
              maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text(
              'Siswa ${e['student_id'] ?? '-'} • ${e['visited_at'] ?? e['created_at'] ?? '-'}'),
          trailing: IconButton(
            tooltip: 'Catat vaksinasi',
            icon: const Icon(Icons.vaccines_outlined),
            onPressed: () async {
              final Map<String, String>? v = await showFormDialog(
                c,
                title: 'Vaksinasi',
                fields: const <FormFieldDef>[
                  FormFieldDef(key: 'vaccine_name', label: 'Nama vaksin'),
                  FormFieldDef(
                      key: 'vaccinated_at', label: 'Tanggal (YYYY-MM-DD)'),
                ],
              );
              if (v == null || !c.mounted) return;
              await runMutation(
                c,
                () => repo.storeVaccination(
                  studentId: (e['student_id'] as num).toInt(),
                  vaccineName: v['vaccine_name']!,
                  vaccinatedAt: v['vaccinated_at']!,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
