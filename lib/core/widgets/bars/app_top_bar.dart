import 'package:boom_mobile/core/widgets/icon/app_icon.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../constants/app_constants.dart';
import '../buttons/switch_button.dart';

class AppTopBar extends StatelessWidget {
  final bool showLocationBadge;
  final VoidCallback onLocationTap;
  final VoidCallback? onLogoTab;
  final bool showSwitchButton;
  final Widget? middleWidget;
  final Widget? rightWidget;

  const AppTopBar({
    super.key,
    required this.showLocationBadge,
    required this.onLocationTap,
    this.onLogoTab,
    this.showSwitchButton = false,
    this.middleWidget,
    this.rightWidget,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double horizontalPadding = screenWidth * 0.05;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          GestureDetector(
            onTap: onLogoTab,
            child: AppIcon(assetPath: kBoomLogo, size: kIconSize),
          ),
          // Centre : badge ou widget custom
          Expanded(
            child: Center(
              child: middleWidget ??
                  (showLocationBadge
                      ? _buildLocationBadge()
                      : (showSwitchButton
                          ? SwitchButton(onTap: onLocationTap)
                          : const SizedBox.shrink())),
            ),
          ),
          // Avatar ou widget custom
          rightWidget ?? AppIcon(assetPath: kAvatar, size: kIconSize),
        ],
      ),
    );
  }

  Widget _buildLocationBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: ShapeDecoration(
        color: AppColors.primaryGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        shadows: const [BoxShadow(color: Color(0xFFC5FFE6), blurRadius: 4, offset: Offset(0, 4))],
      ),
      child: const Text(
        'Rennes Métropoles AppTop',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
