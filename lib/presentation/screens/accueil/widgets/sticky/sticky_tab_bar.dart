import 'package:flutter/material.dart';
import 'package:boom_mobile/core/widgets/bars/app_tab_bar.dart';

class StickyTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const StickyTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppTabBar(
      currentIndex: currentIndex,
      onTap: onTap,
    );
  }
}
