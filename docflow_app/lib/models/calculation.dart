import 'dart:convert';

class Calculation {
  final String id;
  final String patientId;
  final String doctorPhone;
  final String calculatorType;
  final String category;
  final Map<String, dynamic> inputValues;
  final double resultValue;
  final String resultUnit;
  final String resultLabel;
  final String transparency;
  final DateTime createdAt;

  Calculation({
    required this.id,
    required this.patientId,
    required this.doctorPhone,
    required this.calculatorType,
    required this.category,
    required this.inputValues,
    required this.resultValue,
    required this.resultUnit,
    required this.resultLabel,
    required this.transparency,
    required this.createdAt,
  });

  /// Convert Calculation to JSON for Firebase/API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorPhone': doctorPhone,
      'calculatorType': calculatorType,
      'category': category,
      'inputValues': inputValues,
      'resultValue': resultValue,
      'resultUnit': resultUnit,
      'resultLabel': resultLabel,
      'transparency': transparency,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create Calculation from JSON
  factory Calculation.fromJson(Map<String, dynamic> json) {
    return Calculation(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      doctorPhone: json['doctorPhone'] as String,
      calculatorType: json['calculatorType'] as String,
      category: json['category'] as String,
      inputValues: Map<String, dynamic>.from(json['inputValues'] as Map),
      resultValue: (json['resultValue'] as num).toDouble(),
      resultUnit: json['resultUnit'] as String,
      resultLabel: json['resultLabel'] as String,
      transparency: json['transparency'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert Calculation to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_phone': doctorPhone,
      'calculator_type': calculatorType,
      'category': category,
      'input_values': jsonEncode(inputValues),
      'result_value': resultValue,
      'result_unit': resultUnit,
      'result_label': resultLabel,
      'transparency': transparency,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create Calculation from SQLite Map
  factory Calculation.fromMap(Map<String, dynamic> map) {
    return Calculation(
      id: map['id'] as String,
      patientId: map['patient_id'] as String,
      doctorPhone: map['doctor_phone'] as String,
      calculatorType: map['calculator_type'] as String,
      category: map['category'] as String,
      inputValues: _jsonToMap(map['input_values']),
      resultValue: (map['result_value'] as num).toDouble(),
      resultUnit: map['result_unit'] as String,
      resultLabel: map['result_label'] as String,
      transparency: map['transparency'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Helper: Convert stored JSON back to Map.
  static Map<String, dynamic> _jsonToMap(dynamic jsonValue) {
    if (jsonValue == null) {
      return <String, dynamic>{};
    }

    if (jsonValue is Map<String, dynamic>) {
      return jsonValue;
    }

    if (jsonValue is String && jsonValue.isNotEmpty) {
      final decoded = jsonDecode(jsonValue);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return Map<String, dynamic>.from(decoded as Map);
    }

    if (jsonValue is Map) {
      return Map<String, dynamic>.from(jsonValue);
    }

    return <String, dynamic>{};
  }

  /// Create a copy with optional fields replaced
  Calculation copyWith({
    String? id,
    String? patientId,
    String? doctorPhone,
    String? calculatorType,
    String? category,
    Map<String, dynamic>? inputValues,
    double? resultValue,
    String? resultUnit,
    String? resultLabel,
    String? transparency,
    DateTime? createdAt,
  }) {
    return Calculation(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorPhone: doctorPhone ?? this.doctorPhone,
      calculatorType: calculatorType ?? this.calculatorType,
      category: category ?? this.category,
      inputValues: inputValues ?? this.inputValues,
      resultValue: resultValue ?? this.resultValue,
      resultUnit: resultUnit ?? this.resultUnit,
      resultLabel: resultLabel ?? this.resultLabel,
      transparency: transparency ?? this.transparency,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
