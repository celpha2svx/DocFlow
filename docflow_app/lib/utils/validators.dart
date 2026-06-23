bool isValidName(String value) {
  return value.trim().length >= 2;
}

bool isValidPhoneNumber(String value) {
  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
  return digits.length >= 10;
}

bool isValidPin(String value) {
  return RegExp(r'^\d{4}\u0000?\u0000?\u0000?\u0000?$').hasMatch(value);
}

bool isPositiveNumber(num value) {
  return value > 0;
}

bool isWithinRange(num value, num min, num max) {
  return value >= min && value <= max;
}
