import 'package:flutter/material.dart';

import 'app_error.dart';
import 'app_loading.dart';

/// Shared list scaffold for admin/operational modules.
/// Guarantees loading / empty / error / retry states on every screen.
class ModuleListPage extends StatefulWidget {
  const ModuleListPage({
    super.key,
    required this.title,
    required this.loader,
    required this.itemBuilder,
    this.emptyText = 'Belum ada data.',
    this.actions,
    this.onCreate,
    this.createTooltip = 'Tambah',
  });

  final String title;
  final Future<List<Map<String, dynamic>>> Function() loader;
  final Widget Function(BuildContext, Map<String, dynamic>) itemBuilder;
  final String emptyText;
  final List<Widget>? actions;
  final Future<void> Function()? onCreate;
  final String createTooltip;

  @override
  State<ModuleListPage> createState() => _ModuleListPageState();
}

class _ModuleListPageState extends State<ModuleListPage> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.loader();
  }

  void _reload() {
    setState(() {
      _future = widget.loader();
    });
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
