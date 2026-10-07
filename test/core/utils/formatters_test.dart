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
    expect(plain(formatPrice(2180.45, 'EUR', compact: true)), '2 180 €');
    expect(plain(formatPrice(227.4, 'USD', compact: true)), r'227,40 $');
  });

  test('percentages have an explicit sign and a real minus', () {
    expect(plain(formatPercent(3.42)), '+3,4 %');
    expect(plain(formatPercent(-45.6)), '−45,6 %');
    expect(plain(formatPercent(0)), '0,0 %');
    expect(plain(formatPercent(-0.04)), '0,0 %');
  });

  test('percentages without direction drop the plus sign', () {
    expect(plain(formatPercent(13.24, signed: false)), '13,2 %');
    expect(plain(formatPercent(58.4, decimals: 0, signed: false)), '58 %');
  });

  test('candle dates and big counts', () {
    final day = DateTime.utc(2025, 10, 6);
    expect(formatMonthYear(day), 'oct. 2025');
    expect(formatDay(day), '6 oct. 2025');
    expect(plain(formatCompactNumber(41637218)), '41,6 M');
    expect(plain(formatCompactNumber(950)), '950');
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

  test('month ranges', () {
    expect(formatLongMonthYear(DateTime(2019, 3, 4)), 'mars 2019');
    expect(
      formatMonthRange(DateTime(2019, 3, 4), DateTime(2019, 10, 21)),
      'de mars à octobre 2019',
    );
    expect(
      formatMonthRange(DateTime(2019, 11, 4), DateTime(2020, 6, 1)),
      'de novembre 2019 à juin 2020',
    );
    expect(
      formatMonthRange(DateTime(2021, 4, 5), DateTime(2021, 10, 25)),
      "d'avril à octobre 2021",
    );
  });

  test('plain decimals', () {
    expect(formatDecimal(10.34), '10,3');
    expect(formatDecimal(-2), '−2,0');
  });
}
