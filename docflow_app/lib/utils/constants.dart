import 'package:flutter/material.dart';

import '../models/category.dart';

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

final List<Category> categories = [
  Category(
    name: 'Body Metrics',
    icon: '🧍',
    calculators: [
      CalculatorMeta(
        id: 'bmi',
        name: 'Body Mass Index (BMI)',
        category: 'Body Metrics',
        searchTags: ['bmi', 'weight', 'obesity', 'body mass'],
      ),
      CalculatorMeta(
        id: 'bsa',
        name: 'Body Surface Area (BSA)',
        category: 'Body Metrics',
        searchTags: ['bsa', 'surface area', 'oncology', 'chemo'],
      ),
      CalculatorMeta(
        id: 'ibw',
        name: 'Ideal Body Weight (IBW)',
        category: 'Body Metrics',
        searchTags: ['ibw', 'ideal weight', 'ventilator', 'tidal volume'],
      ),
    ],
  ),
  Category(
    name: 'Fluids & Drips',
    icon: '💧',
    calculators: [
      CalculatorMeta(
        id: 'iv_drip_rate',
        name: 'IV Drip Rate',
        category: 'Fluids & Drips',
        searchTags: ['drip', 'iv', 'infusion', 'drops', 'gtt'],
      ),
      CalculatorMeta(
        id: 'maintenance_fluid',
        name: 'Maintenance Fluids (4-2-1)',
        category: 'Fluids & Drips',
        searchTags: ['maintenance', 'fluid', 'holliday', 'segar', '421'],
      ),
      CalculatorMeta(
        id: 'parkland',
        name: 'Parkland Formula (Burns)',
        category: 'Fluids & Drips',
        searchTags: ['parkland', 'burns', 'tbsa', 'fluid resuscitation'],
      ),
    ],
  ),
  Category(
    name: 'Renal',
    icon: '🫘',
    calculators: [
      CalculatorMeta(
        id: 'egfr',
        name: 'eGFR (Cockcroft-Gault)',
        category: 'Renal',
        searchTags: ['egfr', 'gfr', 'kidney', 'creatinine', 'renal function', 'ckd'],
      ),
      CalculatorMeta(
        id: 'anion_gap',
        name: 'Anion Gap',
        category: 'Renal',
        searchTags: ['anion gap', 'dka', 'acidosis', 'metabolic'],
      ),
      CalculatorMeta(
        id: 'fena',
        name: 'Fractional Excretion of Sodium (FeNa)',
        category: 'Renal',
        searchTags: ['fena', 'sodium', 'aki', 'prerenal', 'atn'],
      ),
    ],
  ),
  Category(
    name: 'Cardiac',
    icon: '❤️',
    calculators: [
      CalculatorMeta(
        id: 'map',
        name: 'Mean Arterial Pressure (MAP)',
        category: 'Cardiac',
        searchTags: ['map', 'blood pressure', 'perfusion', 'icu'],
      ),
      CalculatorMeta(
        id: 'qtc',
        name: 'Corrected QT Interval (QTc)',
        category: 'Cardiac',
        searchTags: ['qtc', 'qt', 'ecg', 'arrhythmia', 'torsades'],
      ),
      CalculatorMeta(
        id: 'cardiac_output',
        name: 'Cardiac Output',
        category: 'Cardiac',
        searchTags: ['cardiac output', 'co', 'stroke volume', 'heart rate'],
      ),
    ],
  ),
  Category(
    name: 'Paediatrics',
    icon: '👶',
    calculators: [
      CalculatorMeta(
        id: 'paed_weight',
        name: 'Weight Estimation by Age',
        category: 'Paediatrics',
        searchTags: ['weight', 'paediatric', 'child', 'nelson', 'apls', 'emergency'],
      ),
      CalculatorMeta(
        id: 'schwartz',
        name: 'Paediatric eGFR (Schwartz)',
        category: 'Paediatrics',
        searchTags: ['schwartz', 'paediatric gfr', 'child kidney', 'creatinine'],
      ),
      CalculatorMeta(
        id: 'paed_dose',
        name: 'Paediatric Drug Dosing',
        category: 'Paediatrics',
        searchTags: ['dose', 'paracetamol', 'amoxicillin', 'drug', 'mg/kg'],
      ),
    ],
  ),
];
