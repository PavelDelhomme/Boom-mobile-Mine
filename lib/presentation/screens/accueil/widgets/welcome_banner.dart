import 'package:boom_mobile/core/theme/app_colors.dart';
import 'package:boom_mobile/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class WelcomeBanner extends StatelessWidget {
  final String userName;
  final String userRole;
  final String imageUrl;

  const WelcomeBanner({
    super.key,
    required this.userName,
    required this.userRole,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 112,
        decoration: ShapeDecoration(
          color: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 114,
              top: 19,
              child: Text(
                'Bienvenue',
                style: AppTextStyles.welcomeSubtitle,
              ),
            ),
            Positioned(
              left: 113,
              top: 36,
              child: Text(
                userName,
                style: AppTextStyles.welcomeTitle,
              ),
            ),
            Positioned(
              left: 114,
              top: 75,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  userRole,
                  style: AppTextStyles.badge,
                ),
              ),
            ),
            Positioned(
              left: 35,
              top: 27,
              child: Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(imageUrl),
              ),
            ),
          ],
        ),
      ),
    );
  }
}