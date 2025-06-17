import '../config/theme_config.dart';
import 'package:flutter/material.dart';

class AppTheme {
  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: ThemeConfig.primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ThemeConfig.primaryColor,
        secondary: ThemeConfig.accentColor,
        error: ThemeConfig.errorColor,
        surface: ThemeConfig.surfaceColor,
        onSurface: ThemeConfig.textColorPrimary,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        color: ThemeConfig.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeConfig.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConfig.buttonBorderRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ThemeConfig.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: ThemeConfig.inputDecorationTheme,
      cardTheme: CardTheme(
        elevation: ThemeConfig.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.defaultBorderRadius),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
  
  // Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: ThemeConfig.primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ThemeConfig.primaryColor,
        secondary: ThemeConfig.accentColor,
        error: ThemeConfig.errorColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        color: Colors.grey[900],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      inputDecorationTheme: ThemeConfig.inputDecorationTheme.copyWith(
        fillColor: Colors.grey[800],
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}