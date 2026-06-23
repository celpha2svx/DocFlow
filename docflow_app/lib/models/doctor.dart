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
}
