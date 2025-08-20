import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';


class AppTopBar extends StatelessWidget {
  final bool showLocationBadge;
  final VoidCallback onLocationTap;

  const AppTopBar({
    super.key,
    required this.showLocationBadge,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double horizontalPadding = screenWidth * 0.05; // Calcule du padding en fontion de la largeur décran

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo Boom
          Image.asset('assets/images/logo_boom.png', width: kIconSize, height: kIconSize),

          // Badge de localisation conditionnel
          if (showLocationBadge)
            GestureDetector(
              onTap: onLocationTap,
              child: _buildLocationBadge(),
            )
          else
            const SizedBox(width: 0), // Espace réservé
          
          // // Icône utilisateur
          Image.asset('assets/images/person_02.png', width: kIconSize, height: kIconSize),
          // Container(
          //   width: kIconSize,
          //   height: kIconSize,
          //   decoration: BoxDecoration(
          //     shape: BoxShape.circle,
          //   ),
          //   child: Image.asset('assets/images/person_02.png', width: kIconSize, height: kIconSize),
          // ),
        ],
      ),
    );
  }

  
  Widget _buildLocationBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: ShapeDecoration(
        color: AppColors.primaryGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0xFFC5FFE6),
            blurRadius: 4,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          const Text(
            'Rennes Métropole',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 8),
          Image.asset('assets/images/switch_02.png', width: 14, height: 14),
        ],
      ),
    );
  }
}
