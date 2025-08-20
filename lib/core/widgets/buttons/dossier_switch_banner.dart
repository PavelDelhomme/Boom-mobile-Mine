import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class DossierSwitchBanner extends StatelessWidget {
  final String label;
  final VoidCallback onSwitchTap;

  const DossierSwitchBanner({
    super.key,
    required this.label,
    required this.onSwitchTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(                           // ← toute la pilule cliquable
      borderRadius: BorderRadius.circular(24),
      onTap: onSwitchTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down,
                size: 18, color: Colors.white), // visuel de “switch”
          ],
        ),
      ),
    );
  }
}