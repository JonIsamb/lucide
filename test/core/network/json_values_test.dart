import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/core/network/json_values.dart';

void main() {
  group('parseDouble', () {
    test('numbers and numbers in strings', () {
      expect(parseDouble(227.4), 227.4);
      expect(parseDouble(3), 3.0);
      expect(parseDouble('227.40'), 227.4);
      expect(parseDouble(' 1.5 '), 1.5);
    });

    test('missing or invalid values give null, never a crash', () {
      expect(parseDouble(null), isNull);
      expect(parseDouble(''), isNull);
      expect(parseDouble('abc'), isNull);
      expect(parseDouble(true), isNull);
      expect(parseDouble(const <String>[]), isNull);
    });

    test('NaN and infinity are refused', () {
      expect(parseDouble('NaN'), isNull);
      expect(parseDouble('Infinity'), isNull);
      expect(parseDouble(double.nan), isNull);
      expect(parseDouble(double.infinity), isNull);
    });
  });

  group('parseInt', () {
    test('integers, numbers and integers in strings', () {
      expect(parseInt(2024), 2024);
      expect(parseInt(429.0), 429);
      expect(parseInt('2024'), 2024);
    });

    test('invalid values give null', () {
      expect(parseInt(null), isNull);
      expect(parseInt('20.5'), isNull);
      expect(parseInt('x'), isNull);
      expect(parseInt(double.nan), isNull);
    });
  });

  group('parseDate', () {
    test('a day, with or without time, becomes midnight UTC', () {
      expect(parseDate('2026-10-05'), DateTime.utc(2026, 10, 5));
      expect(parseDate('2026-10-05 15:30:00'), DateTime.utc(2026, 10, 5));
      expect(parseDate('2026-10-05')!.isUtc, isTrue);
    });

    test('invalid values give null', () {
      expect(parseDate(null), isNull);
      expect(parseDate('2026-10'), isNull);
      expect(parseDate('not a date'), isNull);
      expect(parseDate(20261005), isNull);
    });
  });
}
