import 'package:boom_mobile/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAddPressed;
  final ValueChanged<String>? onChanged;

  const SearchBar({
    Key? key,
    required this.controller,
    required this.onAddPressed,
    this.onChanged,
  }) : super(key: key);

  // Layout Builder
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcul en fonction des contrainte parents et valeur fixe de 96
        final availableWidth = constraints.maxWidth - 96;
        return  Container(
            width: double.infinity,
            height: kSearchBarHeight,
            padding: const EdgeInsets.only(left: kElementSpacing),
            child: Stack(
              children: [
                Container(
                  // Si availableWidth est négatif, on prend 0 au minimum.
                  width: availableWidth > 0 ? availableWidth : 0,
                  height: kSearchBarHeight,
                  padding: const EdgeInsets.symmetric(horizontal: kElementSpacing),
                  decoration: ShapeDecoration(
                    color: AppColors.ligthGreenSearchBar.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: const Color(0x33A8F0C3),
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Color(0xFF9F9F9F), size: kIconSize),
                      SizedBox(width: kElementSpacing),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          onChanged: onChanged,
                          decoration: InputDecoration(
                            hintText: 'Rechercher un dossier',
                            hintStyle: TextStyle(
                              color: const Color(0xFF9F9F9F),
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: kVerticalPadding, // Alignement à droite
                  top: 0,
                  child: GestureDetector(
                    onTap: onAddPressed,
                    child: Container(
                      width: kSearchBarHeight,
                      height: kSearchBarHeight,
                      child: Image.asset("assets/images/add-folder_02.png"), // Taille 512w
                    ),
                  ),
                ),
              ],
            ),
          );
      }
    );
  }
}
