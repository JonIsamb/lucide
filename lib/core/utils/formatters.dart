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
/// 4 decimals so a cheap crypto does not show "0,00 €". With [compact]
/// (narrow places like list rows), cents are dropped from 1 000 on:
/// "2 180 €".
String formatPrice(double value, String currencyCode, {bool compact = false}) {
  final abs = value.abs();
  final int decimals;
  if (abs >= (compact ? 1000 : 10000)) {
    decimals = 0;
  } else if (abs < 1) {
    decimals = 4;
  } else {
    decimals = 2;
  }
  final number = _replaceMinus(_decimalFormat(decimals).format(value));
  return '$number$_nbsp${currencySymbol(currencyCode)}';
}

/// "+22,3 %", "−45,6 %", "0,0 %". The sign is always explicit, because a
/// beginner reads "22,3 %" as a gain even if it is not.
///
/// With [signed] false the "+" is dropped, for sizes that have no
/// direction (volatility): "13,2 %".
String formatPercent(double value, {int decimals = 1, bool signed = true}) {
  final number = _decimalFormat(decimals).format(value.abs());
  // Round before choosing the sign, so -0.04 shows "0,0 %" and not "−0,0 %".
  final rounded = double.parse(value.toStringAsFixed(decimals));
  final sign = rounded > 0
      ? (signed ? '+' : '')
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

/// "mars 2019", with the month in full.
String formatLongMonthYear(DateTime value) =>
    DateFormat('MMMM y', 'fr_FR').format(value);

/// "de mars à octobre 2019", or "de novembre 2019 à juin 2020" when the
/// period crosses a new year.
String formatMonthRange(DateTime start, DateTime end) {
  final from = start.year == end.year
      ? DateFormat('MMMM', 'fr_FR').format(start)
      : formatLongMonthYear(start);
  final preposition = _startsWithVowel(from) ? "d'" : 'de ';
  return '$preposition$from à ${formatLongMonthYear(end)}';
}

/// "10,3": a plain number with a French decimal comma.
String formatDecimal(double value, {int decimals = 1}) =>
    _replaceMinus(_decimalFormat(decimals).format(value));

/// "avril", "août" and "octobre" take "d'" instead of "de".
bool _startsWithVowel(String word) => 'aeiouyéèêà'.contains(word[0]);

/// "oct. 2025", for the ends of a chart. Candle dates are plain days in
/// UTC, so they are not converted to the phone's time zone.
String formatMonthYear(DateTime day) =>
    DateFormat('MMM y', 'fr_FR').format(day);

/// "5 oct. 2025", for the date of one candle.
String formatDay(DateTime day) => DateFormat('d MMM y', 'fr_FR').format(day);

/// "41,6 M", "1,2 k": big counts such as traded volumes.
String formatCompactNumber(double value) =>
    NumberFormat.compact(locale: 'fr_FR').format(value);

String currencySymbol(String currencyCode) => switch (currencyCode) {
  'USD' => r'$',
  'EUR' => '€',
  _ => currencyCode,
};

NumberFormat _decimalFormat(int decimals) =>
    NumberFormat.decimalPatternDigits(locale: 'fr_FR', decimalDigits: decimals);

String _replaceMinus(String text) => text.replaceAll('-', minusSign);
