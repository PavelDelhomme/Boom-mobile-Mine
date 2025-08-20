import 'package:flutter/material.dart';

class BoomTextField extends StatelessWidget {
  final String label;
  final String? value;
  final bool readOnly;
  final bool multiline;
  final ValueChanged<String>? onChanged;

  const BoomTextField({
    super.key,
    required this.label,
    this.value,
    this.readOnly = false,
    this.multiline = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: readOnly,
      initialValue: value,
      maxLines: multiline ? null : 1,
      minLines: multiline ? 3 : 1,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: readOnly,
        fillColor: readOnly ? Colors.grey.shade100 : null,
      ),
      onChanged: onChanged,
    );
  }
}
