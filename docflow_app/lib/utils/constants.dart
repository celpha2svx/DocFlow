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
  Category(
    name: 'Neurology',
    icon: '🧠',
    calculators: [
      CalculatorMeta(
        id: 'gcs',
        name: 'Glasgow Coma Scale (GCS)',
        category: 'Neurology',
        searchTags: ['gcs', 'coma', 'consciousness', 'neuro', 'head injury'],
      ),
      CalculatorMeta(
        id: 'nihss',
        name: 'NIH Stroke Scale (NIHSS)',
        category: 'Neurology',
        searchTags: ['nihss', 'stroke', 'neuro', 'cva'],
      ),
      CalculatorMeta(
        id: 'abcd2',
        name: 'ABCD² Score (TIA Risk)',
        category: 'Neurology',
        searchTags: ['abcd2', 'tia', 'stroke risk', 'transient ischaemic attack'],
      ),
      CalculatorMeta(
        id: 'rts',
        name: 'Revised Trauma Score (RTS)',
        category: 'Neurology',
        searchTags: ['rts', 'trauma', 'triage', 'injury severity'],
      ),
      CalculatorMeta(
        id: 'ramsay',
        name: 'Ramsay Sedation Scale',
        category: 'Neurology',
        searchTags: ['ramsay', 'sedation', 'icu', 'ventilated'],
      ),
    ],
  ),
  Category(
    name: 'Respiratory',
    icon: '🫁',
    calculators: [
      CalculatorMeta(
        id: 'curb65',
        name: 'CURB-65 (Pneumonia Severity)',
        category: 'Respiratory',
        searchTags: ['curb65', 'pneumonia', 'sepsis', 'respiratory'],
      ),
      CalculatorMeta(
        id: 'wells_pe',
        name: 'Wells Score for PE',
        category: 'Respiratory',
        searchTags: ['wells', 'pe', 'pulmonary embolism', 'dvt'],
      ),
      CalculatorMeta(
        id: 'perc',
        name: 'PERC Rule (PE Rule-Out)',
        category: 'Respiratory',
        searchTags: ['perc', 'pe', 'pulmonary embolism', 'rule out'],
      ),
      CalculatorMeta(
        id: 'aa_gradient',
        name: 'A-a Gradient',
        category: 'Respiratory',
        searchTags: ['aa gradient', 'alveolar', 'hypoxaemia', 'respiratory'],
      ),
      CalculatorMeta(
        id: 'pf_ratio',
        name: 'PaO₂/FiO₂ Ratio (ARDS)',
        category: 'Respiratory',
        searchTags: ['pf ratio', 'ards', 'berlin definition', 'hypoxaemia'],
      ),
    ],
  ),
  Category(
    name: 'Sepsis & ICU',
    icon: '🆘',
    calculators: [
      CalculatorMeta(
        id: 'qsofa',
        name: 'qSOFA Score',
        category: 'Sepsis & ICU',
        searchTags: ['qsofa', 'sepsis', 'icu', 'screening', 'infection'],
      ),
      CalculatorMeta(
        id: 'sofa',
        name: 'SOFA Score (Sequential Organ Failure Assessment)',
        category: 'Sepsis & ICU',
        searchTags: ['sofa', 'sepsis', 'organ failure', 'icu', 'mortality'],
      ),
      CalculatorMeta(
        id: 'sirs',
        name: 'SIRS Criteria',
        category: 'Sepsis & ICU',
        searchTags: ['sirs', 'sepsis', 'systemic', 'inflammation'],
      ),
      CalculatorMeta(
        id: 'shock_index',
        name: 'Shock Index',
        category: 'Sepsis & ICU',
        searchTags: ['shock index', 'haemodynamic', 'resuscitation'],
      ),
      CalculatorMeta(
        id: 'apache2',
        name: 'APACHE II Score',
        category: 'Sepsis & ICU',
        searchTags: ['apache', 'icu', 'mortality', 'severity'],
      ),
    ],
  ),
  Category(
    name: 'Obstetrics & Gynaecology',
    icon: '🤰',
    calculators: [
      CalculatorMeta(
        id: 'edd',
        name: 'Estimated Due Date (Naegele)',
        category: 'Obstetrics & Gynaecology',
        searchTags: ['edd', 'naegele', 'due date', 'pregnancy', 'gestation'],
      ),
      CalculatorMeta(
        id: 'bishop',
        name: 'Bishop Score',
        category: 'Obstetrics & Gynaecology',
        searchTags: ['bishop', 'cervical ripening', 'induction', 'labour'],
      ),
      CalculatorMeta(
        id: 'preeclampsia_risk',
        name: 'Preeclampsia Risk Factors',
        category: 'Obstetrics & Gynaecology',
        searchTags: ['preeclampsia', 'pregnancy', 'hypertension', 'risk'],
      ),
      CalculatorMeta(
        id: 'apgar',
        name: 'APGAR Score',
        category: 'Obstetrics & Gynaecology',
        searchTags: ['apgar', 'neonatal', 'newborn', 'resuscitation'],
      ),
      CalculatorMeta(
        id: 'pph',
        name: 'PPH Blood Loss Estimator',
        category: 'Obstetrics & Gynaecology',
        searchTags: ['pph', 'postpartum haemorrhage', 'blood loss', 'obstetrics'],
      ),
    ],
  ),
  Category(
    name: 'Gastroenterology',
    icon: '🫃',
    calculators: [
      CalculatorMeta(
        id: 'child_pugh',
        name: 'Child-Pugh Score',
        category: 'Gastroenterology',
        searchTags: ['child pugh', 'cirrhosis', 'liver', 'prognosis'],
      ),
      CalculatorMeta(
        id: 'meld',
        name: 'MELD Score',
        category: 'Gastroenterology',
        searchTags: ['meld', 'liver transplant', 'end stage liver', 'prognosis'],
      ),
      CalculatorMeta(
        id: 'ranson',
        name: "Ranson's Criteria (Pancreatitis)",
        category: 'Gastroenterology',
        searchTags: ['ranson', 'pancreatitis', 'severity', 'gallstone'],
      ),
      CalculatorMeta(
        id: 'glasgow_blatchford',
        name: 'Glasgow-Blatchford Score (Upper GI Bleed)',
        category: 'Gastroenterology',
        searchTags: ['blatchford', 'gi bleed', 'upper gi', 'endoscopy'],
      ),
      CalculatorMeta(
        id: 'rockall',
        name: 'Rockall Score (GI Bleed)',
        category: 'Gastroenterology',
        searchTags: ['rockall', 'gi bleed', 'rebleeding', 'endoscopy'],
      ),
    ],
  ),
  Category(
    name: 'Haematology & Oncology',
    icon: '🩸',
    calculators: [
      CalculatorMeta(
        id: 'anc',
        name: 'Absolute Neutrophil Count (ANC)',
        category: 'Haematology & Oncology',
        searchTags: ['anc', 'neutropenia', 'chemotherapy', 'infection risk'],
      ),
      CalculatorMeta(
        id: 'cha2ds2vasc',
        name: 'CHA₂DS₂-VASc Score',
        category: 'Haematology & Oncology',
        searchTags: ['cha2ds2vasc', 'afib', 'stroke risk', 'anticoagulation'],
      ),
      CalculatorMeta(
        id: 'hasbled',
        name: 'HAS-BLED Score',
        category: 'Haematology & Oncology',
        searchTags: ['hasbled', 'bleeding risk', 'anticoagulation', 'afib'],
      ),
      CalculatorMeta(
        id: 'corrected_calcium',
        name: 'Corrected Calcium',
        category: 'Haematology & Oncology',
        searchTags: ['calcium', 'albumin', 'corrected', 'hypoalbuminaemia'],
      ),
      CalculatorMeta(
        id: 'transfusion_volume',
        name: 'Transfusion Volume Calculator',
        category: 'Haematology & Oncology',
        searchTags: ['transfusion', 'prbc', 'blood', 'haemoglobin'],
      ),
    ],
  ),
  Category(
    name: 'Endocrinology & Metabolic',
    icon: '🦋',
    calculators: [
      CalculatorMeta(
        id: 'hba1c',
        name: 'HbA1c ↔ eAG Converter',
        category: 'Endocrinology & Metabolic',
        searchTags: ['hba1c', 'eag', 'diabetes', 'glucose', 'a1c'],
      ),
      CalculatorMeta(
        id: 'osmolality',
        name: 'Serum Osmolality',
        category: 'Endocrinology & Metabolic',
        searchTags: ['osmolality', 'osmolar gap', 'hyponatraemia', 'toxin'],
      ),
      CalculatorMeta(
        id: 'corrected_sodium',
        name: 'Corrected Sodium (Hyperglycaemia)',
        category: 'Endocrinology & Metabolic',
        searchTags: ['corrected sodium', 'dka', 'hhs', 'hyperglycaemia'],
      ),
      CalculatorMeta(
        id: 'bicarb_deficit',
        name: 'Bicarbonate Deficit',
        category: 'Endocrinology & Metabolic',
        searchTags: ['bicarb', 'deficit', 'acidosis', 'metabolic'],
      ),
      CalculatorMeta(
        id: 'burch_wartofsky',
        name: 'Burch-Wartofsky Score (Thyroid Storm)',
        category: 'Endocrinology & Metabolic',
        searchTags: ['burch wartofsky', 'thyroid storm', 'thyrotoxicosis', 'endocrine'],
      ),
    ],
  ),
];
