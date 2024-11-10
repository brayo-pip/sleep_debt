import 'package:flutter/material.dart';

class AppColors {
  // Base colors
  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);
  static const gray = Color(0xFF757575);
  static const lightGray = Color(0xFFE0E0E0);
  static const darkGray = Color(0xFF424242);

  // Primary colors (more subtle)
  static const primary = Color(0xFF6B7FD7);
  static const warning = Color(0xFFFF6B6B);

  // Sleep debt severity colors
  static const debtFree = Color(0xFF2E7D32);      // Dark green
  static const minimalDebt = Color(0xFFFDD835);   // Yellow
  static const moderateDebt = Color(0xFFFDD835);  // Yellow
  static const highDebt = Color(0xFFEF5350);      // Light red
  static const severeDebt = Color(0xFFB71C1C);

  static var energy;

  static var surface;    // Dark red

  static Color getDebtColor(double debtHours) {
    if (debtHours <= 5) return debtFree;
    if (debtHours < 8) return minimalDebt;
    if (debtHours < 15) return moderateDebt;
    if (debtHours > 15) return highDebt;
    return severeDebt;
  }
}

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.white,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      surface: AppColors.white,
      background: AppColors.white,
      error: AppColors.warning,
    ),
    cardTheme: CardTheme(
      color: AppColors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.gray,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.black,
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        color: AppColors.black,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      headlineSmall: TextStyle(
        color: AppColors.black,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: AppColors.black,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: AppColors.gray,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: AppColors.black,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: AppColors.gray,
        fontSize: 14,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.black,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      surface: AppColors.black,
      background: AppColors.black,
      error: AppColors.warning,
    ),
    cardTheme: CardTheme(
      color: AppColors.black,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.black,
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
      return AppColors.debtFree;
    } else if (hours >= 6 && hours < 7) {
      return AppColors.minimalDebt;
    } else if (hours >= 5 && hours < 6) {
      return AppColors.moderateDebt;
    } else {
      return AppColors.highDebt;
    }
  }
}
