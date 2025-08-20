import 'package:boom_mobile/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../buttons/switch_button.dart';

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
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollUpdateNotification) {
          if (scrollNotification.metrics.pixels > 0) {
            return true;
          }
        }
        return false;
      },
      child: Center(
        child: _buildSwitchBanner(label, onSwitchTap),
      ),
    );
  }

  Widget _buildSwitchBanner(String label, VoidCallback onSwitchTap) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppColors.primaryGreen,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kVerticalPadding),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.clip,
            ),
          ),
          SwitchButton(
            onTap: onSwitchTap,
            size: 36,
            flattened: true,
          ),
        ],
      ),
    );
  }
}