import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SwitchButton extends StatelessWidget {
  final VoidCallback onTap;
  final double size;
  final String assetPath;
  final bool flattened;

  const SwitchButton({
    Key? key,
    required this.onTap,
    this.size = 32,
    this.assetPath = 'assets/images/switch_02.png',
    this.flattened = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: flattened ? size * 1.1 : 24,
        height: flattened ? size * 0.8 : 24,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          // Si flattened forme pill avec coin arrondi sinon cercle complet
          borderRadius: flattened ? BorderRadius.circular(24) : null,
          shape: flattened ? BoxShape.rectangle : BoxShape.circle,
        ),
        child: Center(
          child: Image.asset(
            assetPath,
            width: flattened ? size * 0.4 : 24,
            height: flattened ? size * 0.4 : 24,
          ),
        ),
      ),
    );
  }
}