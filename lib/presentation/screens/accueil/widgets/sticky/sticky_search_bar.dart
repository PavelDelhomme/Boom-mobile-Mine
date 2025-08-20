import 'package:flutter/material.dart';

import 'package:boom_mobile/core/constants/app_constants.dart';
import 'package:boom_mobile/core/widgets/search/search_bar.dart' as custom;

class StickySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAddPressed;
  final ValueChanged<String>? onChanged;
  final String placeholder;

  const StickySearchBar({
    super.key,
    required this.controller,
    required this.onAddPressed,
    this.onChanged,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: kStickyExtraSpace),
      child: custom.ReusableSearchBar(
        controller: controller,
        onChanged: onChanged,
        onTrailingPressed: onAddPressed,
        showTrailing: true,
        placeholder: placeholder,
      ),
    );
  }
}
