import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../constants/app_constants.dart';

class AppTabBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kTabBarHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: kElementSpacing),
        itemCount: 6,
        separatorBuilder: (_, __) => SizedBox(width: 28),
        itemBuilder: (context, index) => _buildTab(
          ['Dossiers', 'Utilisateurs', "Couches", "Couche 2", "Couche 3", "Couche 4"][index],
          index
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isActive = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: kHorizontalPadding, vertical: kTabContentPaddingVertical),
        decoration: BoxDecoration(
          color: isActive
            ? AppColors.backgroundColorThreePointsListDossier // un linear avec un Stops 0% 17F238 100% - 100% 19EE47 100% comment le faire ici ?
            : null,
          borderRadius: BorderRadius.circular(33),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? AppColors.primaryGreen : Color(0xFFB7B7B7),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
