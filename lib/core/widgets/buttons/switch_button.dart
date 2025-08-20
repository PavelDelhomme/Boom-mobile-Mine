import 'package:boom_mobile/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:boom_mobile/core/theme/app_colors.dart';

import '../icon/icon_service.dart';

class SwitchButton extends StatelessWidget {
  final VoidCallback onTap;
  final double size;
  final String assetPath;
  final bool flattened;

  const SwitchButton({
    super.key,
    required this.onTap,
    this.size = 32,
    this.assetPath = kSwitch,
    this.flattened = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: flattened ? size * 1.1 : size,
        height: flattened ? size * 0.8 : size,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          shape: BoxShape.circle,
          boxShadow: flattened
              ? []
              : [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child :Center(
          child: Image.asset(
            IconService.getAsset('Switch'),
            width: size * 0.4,
            height: size * 0.4,
          ),
        ),
      ),
    );
  }
}