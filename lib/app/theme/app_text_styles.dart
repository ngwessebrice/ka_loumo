import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // ============================
  // 🔥 HEADERS
  // ============================

  static const TextStyle heading1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.textLight, // white
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
  );

  static const TextStyle goldHeading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.gold, // GOLD Title
  );

  // ============================
  // 🔥 BODY TEXT
  // ============================

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.textLight,
  );

  static const TextStyle bodyGrey = TextStyle(
    fontSize: 15,
    color: AppColors.textGrey, // subtle grey text
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
  );

  // ============================
  // 🔥 SMALL TEXT
  // ============================

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    color: AppColors.textGrey,
  );

  static const TextStyle captionGold = TextStyle(
    fontSize: 13,
    color: AppColors.gold,
    fontWeight: FontWeight.w600,
  );
}
