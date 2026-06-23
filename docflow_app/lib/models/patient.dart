class Patient {
  final String id;
  final String doctorPhone;
  final String fullName;
  final String? hospitalNumber;
  final int? age;
  final String? sex;
  final double? weightKg;
  final String? diagnosis;
  final DateTime createdAt;
  final DateTime updatedAt;

  Patient({
    required this.id,
    required this.doctorPhone,
    required this.fullName,
    this.hospitalNumber,
    this.age,
    this.sex,
    this.weightKg,
    this.diagnosis,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert Patient to JSON for Firebase/API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorPhone': doctorPhone,
      'fullName': fullName,
      'hospitalNumber': hospitalNumber,
      'age': age,
      'sex': sex,
      'weightKg': weightKg,
      'diagnosis': diagnosis,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create Patient from JSON
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      doctorPhone: json['doctorPhone'] as String,
      fullName: json['fullName'] as String,
      hospitalNumber: json['hospitalNumber'] as String?,
      age: json['age'] as int?,
      sex: json['sex'] as String?,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      diagnosis: json['diagnosis'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert Patient to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctor_phone': doctorPhone,
      'full_name': fullName,
      'hospital_number': hospitalNumber,
      'age': age,
      'sex': sex,
      'weight_kg': weightKg,
      'diagnosis': diagnosis,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create Patient from SQLite Map
  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] as String,
      doctorPhone: map['doctor_phone'] as String,
      fullName: map['full_name'] as String,
      hospitalNumber: map['hospital_number'] as String?,
      age: map['age'] as int?,
      sex: map['sex'] as String?,
      weightKg: (map['weight_kg'] as num?)?.toDouble(),
      diagnosis: map['diagnosis'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Create a copy with optional fields replaced
  Patient copyWith({
    String? id,
    String? doctorPhone,
    String? fullName,
    String? hospitalNumber,
    int? age,
    String? sex,
    double? weightKg,
    String? diagnosis,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      doctorPhone: doctorPhone ?? this.doctorPhone,
      fullName: fullName ?? this.fullName,
      hospitalNumber: hospitalNumber ?? this.hospitalNumber,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      weightKg: weightKg ?? this.weightKg,
      diagnosis: diagnosis ?? this.diagnosis,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
