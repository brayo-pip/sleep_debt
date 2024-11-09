import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF1A1B41); // Dark purple background
  static const surface = Color(0xFF2C2E5B); // Medium purple surface
  static const primary = Color(0xFF6A5ACD); // Primary purple
  static const energy = Color(0xFF9370DB); // Light purple energy
  static const accent = Color(0xFF8A2BE2); // Bright purple accent
  static const warning = Color(0xFFFF6B6B); // Warning red (unchanged)
  static const gray = Color(0xFFB0B0C3); // Light gray for secondary text

  // Sleep quality colors
  static const optimalSleep = primary;
  static const goodSleep = accent;
  static const poorSleep = energy;
  static const badSleep = warning;

  static const greenLight = Color(0xFF10ED37);
  static const redLight = Color.fromARGB(255, 236, 8, 27);
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
