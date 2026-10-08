import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/donations_repository.dart';

/// Donasi: admin kelola campaign, semua peran lihat daftar.
/// Backend: `/admin/donations/*`.
class DonationsPage extends StatelessWidget {
  const DonationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DonationsRepository repo = DonationsRepository();
    final auth = context.watch<AuthBloc>().state;
    final String role = auth.user?.role ?? 'student';
    final bool canManage = role == 'admin' ||
        role == 'school_admin' ||
        role == 'super_admin';
    final String subdomain = auth.school?.subdomain ?? '';
    return ModuleListPage(
      title: 'Donasi',
      loader: () => canManage || subdomain.isEmpty
          ? repo.campaigns()
          : repo.publicCampaigns(subdomain),
      emptyText: 'Belum ada campaign donasi.',
      onCreate: canManage
          ? () async {
              final Map<String, String>? v = await showFormDialog(
                context,
                title: 'Campaign Baru',
                fields: const <FormFieldDef>[
                  FormFieldDef(key: 'title', label: 'Judul'),
                  FormFieldDef(key: 'description', label: 'Deskripsi'),
                  FormFieldDef(key: 'target_amount', label: 'Target (Rp)', isNumber: true),
                  FormFieldDef(key: 'start_date', label: 'Mulai (YYYY-MM-DD)'),
                  FormFieldDef(key: 'end_date', label: 'Selesai (YYYY-MM-DD)'),
                  FormFieldDef(
                      key: 'category',
                      label: 'Kategori',
                      options: <String>[
                        'scholarship',
                        'building',
                        'equipment',
                        'emergency',
                        'general'
                      ]),
                ],
              );
              if (v == null || !context.mounted) return;
              await runMutation(
                context,
                () => repo.storeCampaign(
                  title: v['title']!,
                  description: v['description']!,
                  targetAmount: int.parse(v['target_amount']!),
                  startDate: v['start_date']!,
                  endDate: v['end_date']!,
                  category: v['category'],
                ),
              );
            }
          : null,
      itemBuilder: (BuildContext c, Map<String, dynamic> e) {
        final int target = (e['target_amount'] as num?)?.toInt() ?? 0;
        final int raised = (e['raised_amount'] as num?)?.toInt() ?? 0;
        final double pct =
            target <= 0 ? 0 : (raised / target).clamp(0.0, 1.0).toDouble();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(e['title']?.toString() ?? '-',
                    style: Theme.of(c)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                LinearProgressIndicator(value: pct),
                const SizedBox(height: 4),
                Text(
                    '${CurrencyFormatter.compact(raised)} dari ${CurrencyFormatter.compact(target)}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
