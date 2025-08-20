import 'package:boom_mobile/core/theme/app_colors.dart';
import 'package:boom_mobile/core/theme/app_text_styles.dart';
import 'package:boom_mobile/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

class DossiersVerticalListItem extends StatelessWidget {
  final String name;
  final String type;
  final VoidCallback onTap;
  final VoidCallback onOptionsTap;

  const DossiersVerticalListItem({
    Key? key,
    required this.name,
    required this.type,
    required this.onTap,
    required this.onOptionsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: ShapeDecoration(
          //color: Color.fromARGB(9, 223, 248, 229),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(9, 223, 248, 229),
                    // color: AppColors.ligthGreenSearchBar.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(17.6),
                  ),
                  child: SizedBox(
                    width: kIconSize,
                    height: kIconSize,
                    child: Icon(Icons.folder_open, color: AppColors.primaryGreen, size: kIconSize),
                  )
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(name, style: AppTextStyles.cardTitle),
                    Text(type, style: AppTextStyles.cardSubtitle),
                  ],
                ),
              ],
            ),
            // Menu 3 point verticaux
            PopupMenuButton<String>(
              //color: AppColors.ligthGreenSearchBar,
              color: AppColors.backgroundColorThreePointsListDossier,
              // color: AppColors.ligthGreenSearchBar.withOpacity(0.2),//Color(0xFFC5FFE6).withOpacity(0.7), // Couleur de fond pareil que la search bar
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              key: UniqueKey(),
              onSelected: (value) {
                if (value == 'modifier') {
                  onOptionsTap();
                } else if (value == 'supprimer') {
                  onOptionsTap();
                }
              },

              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'modifier',
                  child: Row(
                    children: [
                      //Icon(Icons.edit, color: AppColors.primaryGreen, size: 18),
                      //const SizedBox(width: 8),
                      Text('Modifier'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'supprimer',
                  child: Row(
                    children: [
                      //Icon(Icons.delete, color: Colors.red, size: 18),
                      //const SizedBox(width: 8),
                      Text('Supprimer'),
                    ],
                  ),
                ),
              ],
              icon: Icon(Icons.more_vert, color: AppColors.primaryGreen),
              //offset: const Offset(0, 30),
            ),
          ],
        ),
      ),
    );
  }
}