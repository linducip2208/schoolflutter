import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../data/canteen_repository.dart';

class CanteenMenuPage extends StatefulWidget {
  final int studentId;
  const CanteenMenuPage({super.key, required this.studentId});

  @override
  State<CanteenMenuPage> createState() => _CanteenMenuPageState();
}

class _CanteenMenuPageState extends State<CanteenMenuPage> {
  final CanteenRepository _repo = CanteenRepository();
  late Future<Map<String, dynamic>> _menuFuture;
  Future<Map<String, dynamic>>? _walletFuture;
  final Map<int, int> _cart = <int, int>{};
  final Map<int, Map<String, dynamic>> _menuById =
      <int, Map<String, dynamic>>{};

  @override
  void initState() {
    super.initState();
    _menuFuture = _loadMenu();
    _walletFuture = _loadWallet();
  }

  Future<Map<String, dynamic>> _loadMenu() async {
    final Map<String, dynamic> body = await _repo.menu();
    final List<dynamic> items = body['items'] as List<dynamic>? ?? <dynamic>[];
    for (final dynamic m in items) {
      if (m is Map<String, dynamic>) {
        final dynamic id = m['id'];
        if (id is int) _menuById[id] = m;
      }
    }
    return body;
  }

  Future<Map<String, dynamic>> _loadWallet() => _repo.wallet(widget.studentId);

  void _reload() => setState(() {
        _menuFuture = _loadMenu();
        _walletFuture = _loadWallet();
      });

  int get _cartTotal {
    int total = 0;
    _cart.forEach((int id, int qty) {
      final Map<String, dynamic>? m = _menuById[id];
      if (m != null) total += (m['price'] as int? ?? 0) * qty;
    });
    return total;
  }

  Future<void> _placeOrder() async {
    if (_cart.isEmpty) return;
    try {
      final List<Map<String, dynamic>> items = _cart.entries
          .map((MapEntry<int, int> e) => <String, dynamic>{
                'menu_item_id': e.key,
                'qty': e.value,
              })
          .toList();

      await _repo.order(studentId: widget.studentId, items: items);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Order berhasil!')));
      setState(() {
        _cart.clear();
        _walletFuture = _loadWallet();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🍱 Kantin'),
        actions: [
          FutureBuilder<Map<String, dynamic>>(
            future: _walletFuture,
            builder: (_, AsyncSnapshot<Map<String, dynamic>> snap) {
              final int balance = (snap.data?['balance'] as int?) ?? 0;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: Chip(
                    avatar: const Icon(Icons.account_balance_wallet, size: 14),
                    label: Text(CurrencyFormatter.idr(balance)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _menuFuture,
        builder: (BuildContext c, AsyncSnapshot<Map<String, dynamic>> snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const AppLoading();
          }
          if (snap.hasError) {
            return AppError(message: '${snap.error}', onRetry: _reload);
          }
          final List<dynamic> items =
              snap.data?['items'] as List<dynamic>? ?? <dynamic>[];
          if (items.isEmpty)
            return const AppEmpty(title: 'Menu kosong hari ini');

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, int i) {
              final Map<String, dynamic> m = items[i] as Map<String, dynamic>;
              final int id = m['id'] as int;
              final int qty = _cart[id] ?? 0;
              return ListTile(
                title: Text(m['name']?.toString() ?? '-'),
                subtitle: Text(
                    CurrencyFormatter.idr((m['price'] as num?)?.toInt() ?? 0)),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: qty > 0
                        ? () => setState(() => _cart[id] = qty - 1)
                        : null,
                  ),
                  Text('$qty',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => setState(() => _cart[id] = qty + 1),
                  ),
                ]),
              );
            },
          );
        },
      ),
      bottomNavigationBar: _cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton(
                  onPressed: _placeOrder,
                  child:
                      Text('Checkout — ${CurrencyFormatter.idr(_cartTotal)}'),
                ),
              ),
            ),
    );
  }
}
