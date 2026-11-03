import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/features/simulator/domain/fisher.dart';

void main() {
  group('fisherRealReturn', () {
    test('no inflation: real equals nominal', () {
      expect(fisherRealReturn(0.2, 0), closeTo(0.2, 1e-12));
    });

    test('positive inflation lowers the return', () {
      expect(fisherRealReturn(0.2, 0.1), closeTo(1.2 / 1.1 - 1, 1e-12));
    });

    test('negative inflation raises the return', () {
      expect(fisherRealReturn(0.2, -0.05), closeTo(1.2 / 0.95 - 1, 1e-12));
      expect(fisherRealReturn(0.2, -0.05), greaterThan(0.2));
    });

    test('a gain equal to inflation is worth nothing', () {
      expect(fisherRealReturn(0.1, 0.1), closeTo(0, 1e-12));
    });
  });

  group('cumulativeInflation', () {
    test('one full year gives that year\'s rate', () {
      final r = cumulativeInflation(
        {2021: 2.0},
        DateTime.utc(2021),
        DateTime.utc(2022),
      )!;
      expect(r.cumulative, closeTo(0.02, 1e-9));
      expect(r.isEstimate, isFalse);
    });

    test('years compound', () {
      final r = cumulativeInflation(
        {2021: 2.0, 2022: 5.0},
        DateTime.utc(2021),
        DateTime.utc(2023),
      )!;
      expect(r.cumulative, closeTo(1.02 * 1.05 - 1, 1e-9));
    });

    test('a partial year is prorated, compounded', () {
      // 2021 has 365 days: 73 days is exactly one fifth.
      final r = cumulativeInflation(
        {2021: 10.0},
        DateTime.utc(2021),
        DateTime.utc(2021, 3, 15),
      )!;
      expect(r.cumulative, closeTo(pow(1.1, 73 / 365) - 1, 1e-9));
    });

    test('a missing year takes the last known rate and is an estimate', () {
      final r = cumulativeInflation(
        {2024: 2.0},
        DateTime.utc(2026),
        DateTime.utc(2027),
      )!;
      expect(r.cumulative, closeTo(0.02, 1e-9));
      expect(r.isEstimate, isTrue);
    });

    test('a year before all data takes the oldest rate', () {
      final r = cumulativeInflation(
        {2015: 3.0},
        DateTime.utc(2013),
        DateTime.utc(2014),
      )!;
      expect(r.cumulative, closeTo(0.03, 1e-9));
    });

    test('no data or empty period: null', () {
      expect(
        cumulativeInflation({}, DateTime.utc(2021), DateTime.utc(2022)),
        isNull,
      );
      expect(
        cumulativeInflation({2021: 1}, DateTime.utc(2022), DateTime.utc(2021)),
        isNull,
      );
    });
  });
}
