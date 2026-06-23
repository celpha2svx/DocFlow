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
}
