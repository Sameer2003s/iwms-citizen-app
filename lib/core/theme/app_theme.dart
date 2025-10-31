import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'package:iwms_citizen_app/core/constants.dart'; // Import your kPrimaryColor

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: kPrimaryColor,
      fontFamily: AppTextStyles.fontFamily,
      scaffoldBackgroundColor: AppColors.background,

      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimaryColor,
        primary: kPrimaryColor,
        secondary: AppColors.primaryBlue,
        background: AppColors.background,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
      ),

      textTheme: TextTheme(
        titleLarge: AppTextStyles.titleLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        labelLarge: AppTextStyles.labelLarge,
        headlineMedium: AppTextStyles.heading2,
        titleMedium: AppTextStyles.subTitle,
      ),

      appBarTheme: AppBarTheme(
        color: AppColors.primaryBlue,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: AppTextStyles.heading2.copyWith(color: Colors.white),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: AppColors.white,
          textStyle: AppTextStyles.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimaryColor, width: 2),
        ),
        labelStyle: AppTextStyles.subTitle, 
      ),
    );
  }
}