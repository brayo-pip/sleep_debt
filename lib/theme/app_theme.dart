import 'package:flutter/material.dart';

class AppColors {
  // Rise Sleep Tracker colors
  static const background = Color(0xFF151B3D);
  static const surface = Color(0xFF1C2447);
  static const primary = Color(0xFF4A7AFF);    // Sleep blue
  static const energy = Color(0xFF4AECF4);     // Energy cyan
  static const accent = Color(0xFF7C85FF);     // Purple accent
  static const warning = Color(0xFFFF6B6B);    // Warning red
  static const gray = Color(0xFF8F9BB3);       // Secondary text
  
  // Sleep quality colors
  static const optimalSleep = primary;
  static const goodSleep = accent;
  static const poorSleep = energy;
  static const badSleep = warning;
}

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.energy,
      surface: AppColors.surface,
      background: AppColors.background,
      error: AppColors.warning,
    ),
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.gray,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      headlineSmall: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: AppColors.gray,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: AppColors.gray,
        fontSize: 14,
      ),
    ),
  );

  static Color getSleepQualityColor(Duration sleepDuration) {
    final hours = sleepDuration.inMinutes / 60;
    if (hours >= 7 && hours <= 9) {
      return AppColors.optimalSleep;
    } else if (hours >= 6 && hours < 7) {
      return AppColors.goodSleep;
    } else if (hours >= 5 && hours < 6) {
      return AppColors.poorSleep;
    } else {
      return AppColors.badSleep;
    }
  }
}
