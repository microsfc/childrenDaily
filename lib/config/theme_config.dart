import 'package:flutter/material.dart';

class ThemeConfig {
  // Primary color palette
  static const Color primaryColor = Color(0xFF00BFA6);  // Your app's primary color
  static const Color primaryColorLight = Color(0xFF5DF2D6);
  static const Color primaryColorDark = Color(0xFF008E76);
  
  // Accent/secondary color palette
  static const Color accentColor = Colors.blue;
  static const Color accentColorLight = Color(0xFF6EC6FF);
  static const Color accentColorDark = Color(0xFF0069C0);
  
  // Background colors
  static const Color backgroundColor = Colors.white;
  static const Color backgroundColorDark = Color(0xFF121212);
  
  // Text colors
  static const Color textColorPrimary = Color(0xFF212121);
  static const Color textColorSecondary = Color(0xFF757575);
  static const Color textColorDisabled = Color(0xFFBDBDBD);
  
  // Error colors
  static const Color errorColor = Color(0xFFB00020);
  static const Color errorColorLight = Color(0xFFEF5350);
  
  // Success, warning, info colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color infoColor = Color(0xFF2196F3);
  
  // Card and surface colors
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;
  
  // Divider and border colors
  static const Color dividerColor = Color(0xFFBDBDBD);
  static const Color borderColor = Color(0xFFE0E0E0);
  
  // Login screen specific colors
  static const Color loginBackgroundColor = Colors.deepPurple;
  static const Color loginAccentColor = Color(0xFF00BFA6);
  
  // Elevation and radius constants
  static const double cardElevation = 2.0;
  static const double buttonElevation = 4.0;
  static const double defaultBorderRadius = 8.0;
  static const double buttonBorderRadius = 24.0;
  static const double inputBorderRadius = 8.0;
  
  // Text styles
  static const TextStyle headlineStyle = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: textColorPrimary,
  );
  
  static const TextStyle titleStyle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
    color: textColorPrimary,
  );
  
  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: textColorSecondary,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: textColorPrimary,
  );
  
  static const TextStyle captionStyle = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: textColorSecondary,
  );
  
  // Button text styles
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
  
  // Input decoration theme
  static InputDecorationTheme get inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBorderRadius),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBorderRadius),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBorderRadius),
        borderSide: BorderSide(color: primaryColor, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBorderRadius),
        borderSide: BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBorderRadius),
        borderSide: BorderSide(color: errorColor, width: 2.0),
      ),
      labelStyle: subtitleStyle,
      errorStyle: captionStyle.copyWith(color: errorColor),
    );
  }
}