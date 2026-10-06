// French formatting of prices, percentages and dates.
// Every screen goes through these functions so "1 234,56 $" looks the
// same everywhere.

import 'package:intl/intl.dart';

/// Non-breaking space: keeps "22,3" and "%" on the same line.
const _nbsp = ' ';

/// Real minus sign (U+2212), more readable than the hyphen "-".
const minusSign = '−';

/// "1 234,56 $", "54 210 €", "0,6234 €".
///
/// Big values lose their cents (they add noise), and values below 1 keep
/// 4 decimals so a cheap crypto does not show "0,00 €".
String formatPrice(double value, String currencyCode) {
  final abs = value.abs();
  final decimals = abs >= 10000
      ? 0
      : abs < 1
      ? 4
      : 2;
  final number = _replaceMinus(_decimalFormat(decimals).format(value));
  return '$number$_nbsp${currencySymbol(currencyCode)}';
}

/// "+22,3 %", "−45,6 %", "0,0 %". The sign is always explicit, because a
/// beginner reads "22,3 %" as a gain even if it is not.
String formatPercent(double value, {int decimals = 1}) {
  final number = _decimalFormat(decimals).format(value.abs());
  // Round before choosing the sign, so -0.04 shows "0,0 %" and not "−0,0 %".
  final rounded = double.parse(value.toStringAsFixed(decimals));
  final sign = rounded > 0
      ? '+'
      : rounded < 0
      ? minusSign
      : '';
  return '$sign$number$_nbsp%';
}

/// "5 octobre à 22:00". The year is added only when it is not the current
/// one: "5 octobre 2025 à 22:00".
String formatDateTime(DateTime value, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final local = value.toLocal();
  final pattern = local.year == current.year
      ? "d MMMM 'à' HH:mm"
      : "d MMMM y 'à' HH:mm";
  return DateFormat(pattern, 'fr_FR').format(local);
}

String currencySymbol(String currencyCode) => switch (currencyCode) {
  'USD' => r'$',
  'EUR' => '€',
  _ => currencyCode,
};

NumberFormat _decimalFormat(int decimals) =>
    NumberFormat.decimalPatternDigits(locale: 'fr_FR', decimalDigits: decimals);

String _replaceMinus(String text) => text.replaceAll('-', minusSign);
