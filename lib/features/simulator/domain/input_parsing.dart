/// Reads a number typed by the user: "1 200,50", "1200.5", "12 %".
/// Returns null for an empty or unreadable text (never throws).
double? parseDecimalInput(String text) {
  final cleaned = text
      .replaceAll(RegExp(r'[\s  %€$]'), '')
      .replaceAll(',', '.');
  if (cleaned.isEmpty) return null;
  final value = double.tryParse(cleaned);
  return value != null && value.isFinite ? value : null;
}
