import 'package:flutter/material.dart';

class BoomTextAreaField extends StatelessWidget {
  final String label;
  final String? value;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final int minLines;
  final int? maxLines;


  const BoomTextAreaField({
    super.key,
    required this.label,
    this.value,
    this.readOnly = false,
    this.onChanged,
    this.minLines = 3,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: readOnly,
      initialValue: value,
      minLines: minLines,
      maxLines: maxLines, // null = auto expand
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: readOnly,
        fillColor: readOnly ? Colors.grey.shade100 : null,
        alignLabelWithHint: true, // important pour les multiline
      ),
      onChanged: onChanged,
    );
  }
}