import '../generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class LocalizationConfig {
  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'),  // English
    Locale('zh', 'TW'),  // Traditional Chinese (Taiwan)
  ];
  
  // Localization delegates for Material app
  static const List<LocalizationsDelegate<dynamic>> localizationDelegates = [
    S.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
  
  // Helper method to get device locale
  static Locale? getDeviceLocale(BuildContext context) {
    final deviceLocale = Localizations.localeOf(context);
    if (isSupported(deviceLocale)) {
      return deviceLocale;
    }
    return supportedLocales.first;
  }
  
  // Check if a locale is supported
  static bool isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        if (supportedLocale.countryCode == null || 
            supportedLocale.countryCode == locale.countryCode) {
          return true;
        }
      }
    }
    return false;
  }
  
  // Get the supported locale closest to the provided locale
  static Locale getClosestSupportedLocale(Locale locale) {
    // First check for exact match
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode &&
          supportedLocale.countryCode == locale.countryCode) {
        return supportedLocale;
      }
    }
    
    // Then check for language match
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return supportedLocale;
      }
    }
    
    // Default to first supported locale
    return supportedLocales.first;
  }
}