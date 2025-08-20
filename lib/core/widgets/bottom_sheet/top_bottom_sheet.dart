import 'package:flutter/material.dart';
import 'package:boom_mobile/core/constants/app_constants.dart';
import 'package:boom_mobile/core/theme/app_colors.dart';
import 'package:boom_mobile/core/theme/app_text_styles.dart';

class TopBottomSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onClose;

  const TopBottomSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: kBoutonSize),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: kHorizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bottomSheetTitle,
                    maxLines: 2, // Limite à 2 lignes
                    overflow: TextOverflow.ellipsis, // Ajoute "..." si trop long
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bottomSheetSubtitle,
                    maxLines: 2, // Limite à 2 lignes
                    overflow: TextOverflow.ellipsis, // Ajoute "..." si trop long
                  ),
                ],
              ),
            ),
          ),
          // Bouton de fermeture avec largeur fixe
          Padding(
            padding: const EdgeInsets.only(right: kHorizontalPadding),
            child: IconButton(
              icon: const Icon(Icons.close, color: AppColors.primaryGreen),
              onPressed: onClose,
            ),
          )
        ],
      ),
    );
  }
}
