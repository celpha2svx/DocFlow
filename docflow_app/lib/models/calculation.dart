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
}
