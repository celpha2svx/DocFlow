String formatDecimal(double value, {int fractionDigits = 1}) {
  return value.toStringAsFixed(fractionDigits);
}

String formatKg(double value) {
  return '${value.toStringAsFixed(1)} kg';
}

String formatLPerMin(double value) {
  return '${value.toStringAsFixed(2)} L/min';
}

String formatPercentage(double value) {
  return '${value.toStringAsFixed(1)}%';
}
