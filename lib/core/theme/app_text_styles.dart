import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Styles d'en-tête
  static const welcomeTitle = TextStyle(
    color: Colors.white,
    fontSize: 32,
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w500,
  );

  static const welcomeSubtitle = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w400,
  );
  
  static const sectionTitle = TextStyle(
    color: AppColors.textDark,
    fontSize: 24,
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.bold,
  );

  static const bottomSheetTitle = TextStyle(
    color: AppColors.primaryGreen,
    fontSize: 24,
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.bold,
  );

  static const bottomSheetSubtitle = TextStyle(
    color: AppColors.textDark,
    fontSize: 14,
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.normal,
  );
  
  // Styles de navigation
  static const tabActive = TextStyle(
    color: AppColors.primaryGreen,
    fontSize: 14,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
  );
  
  static const tabInactive = TextStyle(
    color: AppColors.textLightGrey,
    fontSize: 14,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
  );
  
  // Styles de cartes
  static const cardTitle = TextStyle(
    color: AppColors.textDark,
    fontSize: 14,
    fontFamily: 'Figtree',
    fontWeight: FontWeight.w500,
  );
  
  static const cardSubtitle = TextStyle(
    color: AppColors.textGrey,
    fontSize: 12,
    fontFamily: 'Figtree',
    fontWeight: FontWeight.w400,
  );
  
  // Style de badge
  static const badge = TextStyle(
    color: AppColors.primaryGreen,
    fontSize: 9,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
  );
}