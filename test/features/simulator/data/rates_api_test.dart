import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/core/network/api_exception.dart';
import 'package:lucide/features/simulator/data/rates_api.dart';

void main() {
  group('parseFxRates', () {
    test('reads the days sorted, ignores invalid values', () {
      final rates = parseFxRates({
        'rates': {
          '2026-10-05': {'USD': 1.2},
          '2026-10-02': {'USD': '1.1'},
          '2026-10-03': {'USD': 'abc'},
          '2026-10-04': {'GBP': 0.8},
          '2026-10-06': {'USD': 0},
          'not a day': {'USD': 1.3},
        },
      });
      expect(rates.map((r) => r.eurUsd), [1.1, 1.2]);
      expect(rates.first.day, DateTime.utc(2026, 10, 2));
    });

    test('missing field is an error', () {
      expect(() => parseFxRates({}), throwsA(isA<ApiException>()));
      expect(() => parseFxRates(null), throwsA(isA<ApiException>()));
    });
  });

  group('parseInflation', () {
    test('keeps published years, skips null and invalid ones', () {
      final rates = parseInflation([
        {'page': 1},
        [
          {'date': '2025', 'value': 0.94},
          {'date': '2026', 'value': null},
          {'date': '2024', 'value': '2.0'},
          {'date': 'abc', 'value': 1.0},
          'junk',
        ],
      ]);
      expect(rates, {2025: 0.94, 2024: 2.0});
    });

    test('missing data list is an error', () {
      expect(() => parseInflation([{}]), throwsA(isA<ApiException>()));
      expect(() => parseInflation([{}, null]), throwsA(isA<ApiException>()));
    });
  });
}
