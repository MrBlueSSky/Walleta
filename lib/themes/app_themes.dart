import 'package:flutter/material.dart';
import 'package:walleta/themes/app_colors.dart';

class AppThemes {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    indicatorColor: AppColors.textBlack,
    scaffoldBackgroundColor: AppColors.primaryLight,
    primaryColor: AppColors.primary,
    cardColor: AppColors.grayBackground,

    textTheme: const TextTheme(
      labelSmall: TextStyle(color: AppColors.textSecondaryLight),
      bodyLarge: TextStyle(color: AppColors.textBlack),
    ),
    iconTheme: const IconThemeData(color: AppColors.textBlack),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    indicatorColor: AppColors.textPrimary,
    scaffoldBackgroundColor: AppColors.primaryDark,
    primaryColor: AppColors.primary,
    cardColor: AppColors.cardBackground,
    textTheme: const TextTheme(
      labelSmall: TextStyle(color: AppColors.textSecondaryDark),
      bodyLarge: TextStyle(color: AppColors.textPrimary),
    ),
    iconTheme: const IconThemeData(color: AppColors.textPrimary),
  );
}
