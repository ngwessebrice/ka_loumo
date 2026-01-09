import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  /// 🌙 DARK THEME
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.gold,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0.3,
      iconTheme: IconThemeData(color: AppColors.gold),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),

    cardColor: AppColors.card,

    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.textLight),
    ),

    colorScheme: const ColorScheme.dark(
      primary: AppColors.gold,
      secondary: AppColors.gold,
    ),
  );

  /// ☀️ LIGHT THEME (we will style this later)
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: AppColors.gold,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0.3,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),

    cardColor: AppColors.lightCard,

    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black87),
    ),

    colorScheme: const ColorScheme.light(
      primary: AppColors.gold,
      secondary: AppColors.gold,
    ),
  );
}
