import 'dart:async';

import 'package:flutter/material.dart';

/// Reusable debounced search field.
///
/// - 400ms debounce
/// - onChanged fires only after pause
/// - cancellable via dispose
class AppSearch extends StatefulWidget {
  const AppSearch({
    super.key,
    required this.hint,
    required this.onSearch,
    this.initialValue = '',
  });

  final String hint;
  final ValueChanged<String> onSearch;
  final String initialValue;

  @override
  State<AppSearch> createState() => _AppSearchState();
}

class _AppSearchState extends State<AppSearch> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.initialValue);
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.onSearch(v.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      onChanged: _onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search_outlined),
        suffixIcon: _ctrl.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear_outlined),
                onPressed: () {
                  _ctrl.clear();
                  widget.onSearch('');
                  setState(() {});
                },
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
