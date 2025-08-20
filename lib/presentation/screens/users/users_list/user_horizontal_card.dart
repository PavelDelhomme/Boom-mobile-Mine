import 'package:boom_mobile/core/constants/app_constants.dart';
import 'package:boom_mobile/core/theme/app_colors.dart';
import 'package:boom_mobile/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class UserHorizontalCardItem extends StatelessWidget {
  final String title;
  final String status;
  final String date;
  final String? imageUrl;
  final VoidCallback onTap;

  const UserHorizontalCardItem({
    super.key,
    required this.title,
    required this.status,
    required this.date,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 199,
        margin: const EdgeInsets.only(left: 4, right: 12, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(99),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de fond avec badge
            Stack(
              clipBehavior: Clip.none, // Permission de déborder
              children: [
                // Image avec coins arrondis
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    height: 96,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(imageUrl ?? kDossierImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -9,
                  right: 9,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.darkGreen,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                    ),
                    child: Text(
                      date,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                top: 12.0,
                right: 16.0,
                bottom: 4.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Texte avec ellipsis si trop long
                  Text(
                    title,
                    style: AppTextStyles.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),

                  // Status avec badge
                  Row(
                    children: [
                      Text(
                        status,
                        style: const TextStyle(
                          color: AppColors.darkGreen,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}