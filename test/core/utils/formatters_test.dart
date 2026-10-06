import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lucide/core/utils/formatters.dart';

/// Makes expected strings readable: intl uses narrow no-break spaces as
/// thousands separators, we write them as plain spaces in the tests.
String plain(String text) => text.replaceAll(' ', ' ').replaceAll(' ', ' ');

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  test('prices', () {
    expect(plain(formatPrice(1234.56, 'USD')), r'1 234,56 $');
    expect(plain(formatPrice(54210.4, 'EUR')), '54 210 €');
    expect(plain(formatPrice(227.4, 'USD')), r'227,40 $');
    expect(plain(formatPrice(0.62346, 'EUR')), '0,6235 €');
    expect(plain(formatPrice(-12.5, 'USD')), '−12,50 \$');
  });

  test('percentages have an explicit sign and a real minus', () {
    expect(plain(formatPercent(3.42)), '+3,4 %');
    expect(plain(formatPercent(-45.6)), '−45,6 %');
    expect(plain(formatPercent(0)), '0,0 %');
    expect(plain(formatPercent(-0.04)), '0,0 %');
  });

  test('dates', () {
    final now = DateTime(2026, 10, 6);
    expect(
      formatDateTime(DateTime(2026, 10, 5, 22), now: now),
      '5 octobre à 22:00',
    );
    expect(
      formatDateTime(DateTime(2025, 12, 1, 9, 5), now: now),
      '1 décembre 2025 à 09:05',
    );
  });
}
