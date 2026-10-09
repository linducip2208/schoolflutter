import 'package:flutter/material.dart';

import 'app_error.dart';
import 'app_loading.dart';

/// Shared list scaffold for admin/operational modules.
/// Guarantees loading / empty / error / retry states on every screen.
///
/// Two modes:
/// - [loader]: single fetch (small/reference lists).
/// - [pagedLoader] + [pageSize]: infinite scroll for large lists
///   (backend paginates 20-50). Stops when a page returns fewer rows.
class ModuleListPage extends StatefulWidget {
  const ModuleListPage({
    super.key,
    required this.title,
    required this.itemBuilder,
    this.loader,
    this.emptyText = 'Belum ada data.',
    this.actions,
    this.onCreate,
    this.createTooltip = 'Tambah',
    this.pagedLoader,
    this.pageSize = 20,
  }) : assert(loader != null || pagedLoader != null,
            'Provide loader and/or pagedLoader');

  final String title;
  final Future<List<Map<String, dynamic>>> Function()? loader;
  final Widget Function(BuildContext, Map<String, dynamic>) itemBuilder;
  final String emptyText;
  final List<Widget>? actions;
  final Future<void> Function()? onCreate;
  final String createTooltip;
  final Future<List<Map<String, dynamic>>> Function({required int page})?
      pagedLoader;
  final int pageSize;

  @override
  State<ModuleListPage> createState() => _ModuleListPageState();
}

class _ModuleListPageState extends State<ModuleListPage> {
  late Future<List<Map<String, dynamic>>> _future;
  final ScrollController _scroll = ScrollController();
  List<Map<String, dynamic>> _paged = const <Map<String, dynamic>>[];
  int _page = 1;
  bool _loadingMore = false;
  bool _hasMore = true;
  bool _pagedFailed = false;
  String? _pagedError;

  bool get _pagedMode => widget.pagedLoader != null;

  @override
  void initState() {
    super.initState();
    _future = _firstPage();
    if (_pagedMode) {
      _scroll.addListener(_onScroll);
    }
  }

  Future<List<Map<String, dynamic>>> _firstPage() {
    if (widget.loader != null) return widget.loader!();
    return widget.pagedLoader!(page: 1);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = _firstPage();
      if (_pagedMode) {
        _paged = const <Map<String, dynamic>>[];
        _page = 1;
        _hasMore = true;
        _pagedFailed = false;
        _pagedError = null;
      }
    });
  }

  void _onScroll() {
    if (!_hasMore || _loadingMore) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 240) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      final List<Map<String, dynamic>> rows =
          await widget.pagedLoader!(page: _page + 1);
      if (!mounted) return;
      setState(() {
        _loadingMore = false;
        if (rows.length < widget.pageSize) _hasMore = false;
        _page += 1;
        _paged = <Map<String, dynamic>>[..._paged, ...rows];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingMore = false;
        _pagedFailed = true;
        _pagedError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: widget.actions),
      floatingActionButton: widget.onCreate == null
          ? null
          : FloatingActionButton(
              tooltip: widget.createTooltip,
              onPressed: () async {
                await widget.onCreate!();
                if (mounted) _reload();
              },
              child: const Icon(Icons.add),
            ),
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder:
              (BuildContext c, AsyncSnapshot<List<Map<String, dynamic>>> snap) {
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
            List<Map<String, dynamic>> items =
                snap.data ?? const <Map<String, dynamic>>[];
            if (_pagedMode) {
              if (_paged.isEmpty) {
                _paged = items;
                if (items.length < widget.pageSize) _hasMore = false;
                _page = 1;
              } else {
                // Fresh reload replaced the first page already via _reload.
                items = _paged;
              }
              if (items.isEmpty) {
                return ListView(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(child: Text(widget.emptyText)),
                    ),
                  ],
                );
              }
              return ListView.separated(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                itemCount: items.length + ((_hasMore || _loadingMore) ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (BuildContext c, int i) {
                  if (i >= items.length) {
                    if (_pagedFailed) {
                      return Center(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _pagedFailed = false;
                              _pagedError = null;
                            });
                            _loadMore();
                          },
                          child: Text(
                              'Gagal memuat lanjutan${_pagedError != null ? ': $_pagedError' : ''}. Coba lagi.'),
                        ),
                      );
                    }
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  }
                  return widget.itemBuilder(c, items[i]);
                },
              );
            }
            if (items.isEmpty) {
              return ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(child: Text(widget.emptyText)),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (BuildContext c, int i) =>
                  widget.itemBuilder(c, items[i]),
            );
          },
        ),
      ),
    );
  }
}

/// Shows a snackbar for success/failure of a mutation, returns true on ok.
Future<bool> runMutation(
    BuildContext context, Future<void> Function() fn) async {
  try {
    await fn();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil.')),
      );
    }
    return true;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
    return false;
  }
}
