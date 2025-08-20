import 'package:flutter/material.dart';
import 'package:boom_mobile/core/constants/app_constants.dart';
import 'package:boom_mobile/core/theme/app_colors.dart';
import 'package:boom_mobile/core/theme/app_text_styles.dart';


class TopBottomSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onClose;

  const TopBottomSheet({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: kBoutonSize),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          // Titre et sous titre regroupé dans une colonne
          Padding(
            padding: const EdgeInsets.only(left: kHorizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bottomSheetTitle,
                ),
                const SizedBox(height: 4.0),
                Text(
                  subtitle,
                  style: AppTextStyles.bottomSheetSubtitle,
                ),
              ],
            ),
          ),

          // Button de fermeture
          Padding(
              padding: const EdgeInsets.only(right: kHorizontalPadding),
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.primaryGreen),
                onPressed: onClose,
              )
          )
        ],
      ),
    );
  }
}