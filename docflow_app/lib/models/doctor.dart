class Doctor {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String? specialty;
  final String pinHash;
  final DateTime createdAt;

  Doctor({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.specialty,
    required this.pinHash,
    required this.createdAt,
  });

  /// Convert Doctor to JSON for Firebase/API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'specialty': specialty,
      'pinHash': pinHash,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create Doctor from JSON
  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      specialty: json['specialty'] as String?,
      pinHash: json['pinHash'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert Doctor to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'specialty': specialty,
      'pin_hash': pinHash,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create Doctor from SQLite Map
  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id'] as String,
      fullName: map['full_name'] as String,
      phoneNumber: map['phone_number'] as String,
      specialty: map['specialty'] as String?,
      pinHash: map['pin_hash'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Create a copy with optional fields replaced
  Doctor copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? specialty,
    String? pinHash,
    DateTime? createdAt,
  }) {
    return Doctor(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      specialty: specialty ?? this.specialty,
      pinHash: pinHash ?? this.pinHash,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
