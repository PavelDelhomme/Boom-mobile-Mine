import 'package:flutter/material.dart';
import 'package:boom_mobile/core/theme/app_colors.dart';
import 'package:boom_mobile/core/widgets/icon/icon_service.dart';

class BoomCopyButton extends StatelessWidget {
  final VoidCallback onTap;
  final double size;
  final bool flattened;

  const BoomCopyButton({
    super.key,
    required this.onTap,
    this.size = 32,
    this.flattened = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: flattened ? size * 1.9 : size,
        height: flattened ? size * 0.9 : size,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: flattened ? BorderRadius.circular(24) : null,
          shape: flattened ? BoxShape.rectangle : BoxShape.circle,
        ),
        child: Center(
          child: Image.asset(
            IconService.getAsset('Copy'),
            width: size * 2.1,
            height: size * 1.8,
          ),
        ),
      ),
    );
  }
}
