import 'package:flutter/material.dart';

/// Field definition for [showFormDialog].
class FormFieldDef {
  const FormFieldDef({
    required this.key,
    required this.label,
    this.isNumber = false,
    this.isDate = false,
    this.options,
    this.initial,
    this.hint,
    this.optional = false,
  });
  final String key;
  final String label;
  final bool isNumber;
  final bool isDate;
  final List<String>? options;
  final String? initial;
  final String? hint;
  final bool optional;
}

/// Generic validated form dialog. Returns string values keyed by field key,
/// or null when cancelled. Keeps every admin create-form to ~10 lines.
Future<Map<String, String>?> showFormDialog(
  BuildContext context, {
  required String title,
  required List<FormFieldDef> fields,
}) {
  final Map<String, TextEditingController> controllers = <String, TextEditingController>{
    for (final FormFieldDef f in fields)
      f.key: TextEditingController(text: f.initial ?? ''),
  };
  final Map<String, String> dropdowns = <String, String>{
    for (final FormFieldDef f in fields)
      if (f.options != null) f.key: f.initial ?? f.options!.first,
  };
  final GlobalKey<FormState> key = GlobalKey<FormState>();
  return showDialog<Map<String, String>>(
    context: context,
    builder: (BuildContext c) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final FormFieldDef f in fields)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: f.options != null
                      ? DropdownButtonFormField<String>(
                          initialValue: dropdowns[f.key],
                          decoration: InputDecoration(
                              labelText: f.label, hintText: f.hint),
                          items: <DropdownMenuItem<String>>[
                            for (final String o in f.options!)
                              DropdownMenuItem<String>(
                                  value: o, child: Text(o)),
                          ],
                          onChanged: (String? v) {
                            if (v != null) dropdowns[f.key] = v;
                          },
                        )
                      : TextFormField(
                          controller: controllers[f.key],
                          decoration: InputDecoration(
                              labelText: f.label, hintText: f.hint),
                          keyboardType: f.isNumber
                              ? TextInputType.number
                              : TextInputType.text,
                          validator: (String? v) {
                            if (f.optional) return null;
                            return (v == null || v.trim().isEmpty)
                                ? 'Wajib diisi'
                                : null;
                          },
                          ),
                      ),
              ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(c).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            if (!(key.currentState?.validate() ?? false)) return;
            Navigator.of(c).pop(<String, String>{
              for (final FormFieldDef f in fields)
                f.key: f.options != null
                    ? dropdowns[f.key]!
                    : controllers[f.key]!.text.trim(),
            });
          },
          child: const Text('Simpan'),
        ),
      ],
    ),
  );
}
