import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const Color primaryColor = Color(0xFF1F4E79);
  static const Color secondaryColor = Color(0xFF2E75B6);
  static const Color accentColor = Color(0xFF00B4D8);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFC0392B);
  static const Color textColor = Color(0xFF1A1A2E);
  static const Color subtextColor = Color(0xFF6B7280);
  static const Color successColor = Color(0xFF16A34A);

  static final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: primaryColor,
    primary: primaryColor,
    secondary: secondaryColor,
    surface: surfaceColor,
    error: errorColor,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: textColor,
    onError: Colors.white,
  );

  static final ThemeData themeData = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      hintStyle: const TextStyle(color: subtextColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: secondaryColor),
      ),
    ),
    textTheme: Typography.material2021(platform: TargetPlatform.android).black.apply(
      bodyColor: textColor,
      displayColor: textColor,
    ),
  );
}

const Map<String, Map<String, dynamic>> paedDosePresets = {
  'Paracetamol': {
    'dose': 15.0,
    'maxSingleDose': 1000.0,
    'frequency': 4,
    'unit': 'mg/kg/dose',
  },
  'Amoxicillin': {
    'dose': 25.0,
    'maxSingleDose': 500.0,
    'frequency': 3,
    'unit': 'mg/kg/dose',
  },
  'Ibuprofen': {
    'dose': 10.0,
    'maxSingleDose': 400.0,
    'frequency': 3,
    'unit': 'mg/kg/dose',
  },
};

