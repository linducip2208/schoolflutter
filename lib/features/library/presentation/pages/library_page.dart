import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/library_repository.dart';
import 'barcode_scanner_page.dart';

/// Perpustakaan: katalog + pinjam/kembali + tambah (petugas).
/// Backend: `/library/*` (issue/return/store: `library.manage`).
class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final LibraryRepository _repo = LibraryRepository();
  final TextEditingController _q = TextEditingController();
  late Future<List<Map<String, dynamic>>> _future = _repo.books();

  void _reload() => setState(() => _future = _repo.books(query: _q.text));

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    final String? code = await Navigator.of(context).push(
      MaterialPageRoute<String>(builder: (_) => const BarcodeScannerPage()),
    );
    if (code == null) return;
    setState(() => _q.text = code);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final String role = context.watch<AuthBloc>().state.user?.role ?? 'student';
    final bool canManage = role == 'admin' ||
        role == 'school_admin' ||
        role == 'super_admin' ||
        role == 'librarian';
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Perpustakaan'),
          bottom: const TabBar(
            tabs: <Widget>[Tab(text: 'Katalog'), Tab(text: 'Pinjaman')],
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.qr_code_scanner_outlined),
              onPressed: _scan,
              tooltip: 'Pindai barcode',
            ),
          ],
        ),
        floatingActionButton: canManage
            ? FloatingActionButton.extended(
                icon: const Icon(Icons.add),
                label: const Text('Buku'),
                onPressed: () async {
                  List<Map<String, dynamic>> cats =
                      const <Map<String, dynamic>>[];
                  try {
                    cats = await _repo.categories();
                  } catch (_) {}
                  if (!context.mounted) return;
                  final Map<String, String>? v = await showFormDialog(
                    context,
                    title: 'Buku Baru',
                    fields: <FormFieldDef>[
                      FormFieldDef(
                          key: 'book_category_id',
                          label:
                              'ID Kategori${cats.isEmpty ? ' (lihat daftar kategori via API)' : ': ${cats.map((Map<String, dynamic> e) => '${e['id']}=${e['name']}').join(', ')}'}',
                          isNumber: true),
                      const FormFieldDef(key: 'title', label: 'Judul'),
                      const FormFieldDef(key: 'author', label: 'Penulis'),
                      const FormFieldDef(
                          key: 'total_quantity',
                          label: 'Jumlah',
                          isNumber: true,
                          initial: '1'),
                    ],
                  );
                  if (v == null || !context.mounted) return;
                  final bool ok = await runMutation(
                    context,
                    () => _repo.storeBook(
                      categoryId: int.parse(v['book_category_id']!),
                      title: v['title']!,
                      author: v['author'],
                      quantity: int.tryParse(v['total_quantity']!),
                    ),
                  );
                  if (ok) _reload();
                },
              )
            : null,
        body: TabBarView(
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _q,
                    decoration: const InputDecoration(
                      hintText: 'Cari judul atau kode buku...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _reload(),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _future,
                    builder: (BuildContext c,
                        AsyncSnapshot<List<Map<String, dynamic>>> snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const AppLoading();
                      }
                      if (snap.hasError) {
                        return AppError(
                            message: '${snap.error}', onRetry: _reload);
                      }
                      final List<Map<String, dynamic>> list =
                          snap.data ?? <Map<String, dynamic>>[];
                      if (list.isEmpty) {
                        return const AppEmpty(
                            title: 'Tidak ada buku ditemukan');
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (BuildContext c, int i) {
                          final Map<String, dynamic> b = list[i];
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.menu_book_outlined),
                              title: Text(b['title'] as String? ?? '-'),
                              subtitle: Text(
                                  '${b['author'] ?? '-'} • ${b['code'] ?? ''}'),
                              trailing: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                      'Stok: ${b['available_qty'] ?? b['available_quantity'] ?? 0}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                  if (canManage)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              _issueBook(context, b),
                                          child: const Text('Pinjamkan'),
                                        ),
                                        PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert,
                                              size: 18),
                                          onSelected: (String v) => _bookAction(
                                              context, b, v, _reload),
                                          itemBuilder: (_) =>
                                              const <PopupMenuItem<String>>[
                                            PopupMenuItem<String>(
                                                value: 'edit',
                                                child: Text('Ubah')),
                                            PopupMenuItem<String>(
                                                value: 'hapus',
                                                child: Text('Hapus')),
                                          ],
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            ModuleListPage(
              title: 'Pinjaman',
              loader: _repo.issues,
              emptyText: 'Tidak ada pinjaman aktif.',
              actions: canManage
                  ? <Widget>[
                      IconButton(
                        tooltip: 'Tandai overdue',
                        icon: const Icon(Icons.schedule_outlined),
                        onPressed: () async {
                          int n = 0;
                          final bool ok = await runMutation(
                            context,
                            () async {
                              n = await _repo.markOverdue();
                            },
                          );
                          if (ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('$n pinjaman ditandai overdue.')),
                            );
                          }
                        },
                      ),
                    ]
                  : null,
              itemBuilder: (BuildContext c, Map<String, dynamic> e) {
                final int id = (e['id'] as num).toInt();
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.bookmark_outline),
                    title: Text(
                        'Buku ${e['book_id'] ?? '-'} → User ${e['user_id'] ?? e['issued_to'] ?? '-'}'),
                    subtitle: Text(
                        'Status ${e['status'] ?? '-'} • Jatuh tempo ${e['due_at'] ?? e['due_date'] ?? '-'}'),
                    trailing: canManage
                        ? IconButton(
                            tooltip: 'Kembalikan',
                            icon: const Icon(Icons.keyboard_return_outlined),
                            onPressed: () async {
                              await runMutation(c, () => _repo.returnBook(id));
                            },
                          )
                        : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _issueBook(
      BuildContext context, Map<String, dynamic> book) async {
    final Map<String, String>? v = await showFormDialog(
      context,
      title: 'Pinjamkan Buku',
      fields: const <FormFieldDef>[
        FormFieldDef(key: 'user_id', label: 'ID User peminjam', isNumber: true),
      ],
    );
    if (v == null || !context.mounted) return;
    await runMutation(
      context,
      () => _repo.issue(
        bookId: (book['id'] as num).toInt(),
        userId: int.parse(v['user_id']!),
      ),
    );
  }

  Future<void> _bookAction(BuildContext context, Map<String, dynamic> book,
      String action, VoidCallback onChanged) async {
    final int id = (book['id'] as num).toInt();
    if (action == 'hapus') {
      final bool? ok = await showDialog<bool>(
        context: context,
        builder: (BuildContext d) => AlertDialog(
          title: const Text('Hapus buku?'),
          content: Text('${book['title'] ?? ''}'),
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
      if (ok != true || !context.mounted) return;
      final bool done = await runMutation(context, () => _repo.deleteBook(id));
      if (done && context.mounted) onChanged();
      return;
    }
    final Map<String, String>? v = await showFormDialog(
      context,
      title: 'Ubah Buku',
      fields: <FormFieldDef>[
        FormFieldDef(
            key: 'title', label: 'Judul', initial: book['title']?.toString()),
        FormFieldDef(
            key: 'total_quantity',
            label: 'Jumlah',
            isNumber: true,
            initial: (book['total_quantity'] as num?)?.toString() ?? ''),
      ],
    );
    if (v == null || !context.mounted) return;
    final bool done = await runMutation(
      context,
      () => _repo.updateBook(id, <String, dynamic>{
        'title': v['title']!,
        if (v['total_quantity']!.isNotEmpty)
          'total_quantity': int.parse(v['total_quantity']!),
      }),
    );
    if (done && context.mounted) onChanged();
  }
}
