import 'package:boom_mobile/core/constants/app_constants.dart';
import 'package:boom_mobile/core/widgets/icon/app_icon.dart';
import 'package:boom_mobile/core/widgets/switch/dossier_switch_banner.dart';
import 'package:flutter/material.dart';
import 'package:boom_mobile/core/widgets/bars/app_top_bar.dart';

class StickyTopBar extends StatelessWidget {
  final VoidCallback onLocationTap;
  final ValueNotifier<bool> showBadgeNotifier;
  final ValueNotifier<bool> isTabBarStickyNotifier;

  const StickyTopBar({
    super.key,
    required this.onLocationTap,
    required this.showBadgeNotifier,
    required this.isTabBarStickyNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: showBadgeNotifier,
      builder: (_, showBadge, __) {
            return AppTopBar(
              showLocationBadge: showBadge,
              showSwitchButton: false,
              onLocationTap: onLocationTap,
              middleWidget: showBadge
                  ? null
                  : DossierSwitchBanner(
                label: 'Rennes Métropole',
                onSwitchTap: onLocationTap,
              ),
              rightWidget: AppIcon(assetPath: kAvatar, size: kIconSize),
            );
          },
    );
  }
}