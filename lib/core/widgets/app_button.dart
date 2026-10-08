import 'package:flutter/material.dart';

/// Production button with built-in double-tap guard.
///
/// Prevents duplicate POSTs when users tap fast (see red-team fix 8000520).
/// Use for all form submits, payments, attendance marking.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isDestructive = false,
    this.isSecondary = false,
    this.enabled = true,
  });

  final String label;
  final Future<void> Function()? onPressed;
  final IconData? icon;
  final bool isDestructive;
  final bool isSecondary;
  final bool enabled;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _busy = false;

  Future<void> _tap() async {
    if (_busy || !widget.enabled || widget.onPressed == null) return;
    setState(() => _busy = true);
    try {
      await widget.onPressed!();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget? child = _busy
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : (widget.icon != null ? Icon(widget.icon, size: 18) : null);
    final String label = _busy ? 'Mohon tunggu…' : widget.label;

    if (widget.isSecondary) {
      return OutlinedButton.icon(
        onPressed: (_busy || !widget.enabled) ? null : _tap,
        icon: child ?? const SizedBox.shrink(),
        label: Text(label),
      );
    }
    if (widget.isDestructive) {
      return FilledButton.icon(
        onPressed: (_busy || !widget.enabled) ? null : _tap,
        icon: child ?? const SizedBox.shrink(),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
    return FilledButton.icon(
      onPressed: (_busy || !widget.enabled) ? null : _tap,
      icon: child ?? const SizedBox.shrink(),
      label: Text(label),
    );
  }
}
