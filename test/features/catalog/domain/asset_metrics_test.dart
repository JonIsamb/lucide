import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/features/catalog/domain/asset_metrics.dart';

import '../../../helpers.dart';

void main() {
  group('changePercent', () {
    test('the catalogue alias gives the same result', () {
      final candles = weeklySeries([100, 90, 125]);
      expect(changePercent(candles), 25);
      expect(yearlyChangePercent(candles), changePercent(candles));
    });

    test('normal case: first to last close', () {
      expect(yearlyChangePercent(weeklySeries([100, 90, 125])), 25);
    });

    test('negative change', () {
      expect(yearlyChangePercent(weeklySeries([200, 150])), -25);
    });

    test('empty list gives null', () {
      expect(yearlyChangePercent([]), isNull);
    });

    test('single candle gives null', () {
      expect(yearlyChangePercent(weeklySeries([100])), isNull);
    });

    test('first close equal to 0 gives null', () {
      expect(yearlyChangePercent(weeklySeries([0, 10])), isNull);
    });
  });

  group('sparklinePoints', () {
    test('scales closes between 0 and 1', () {
      expect(sparklinePoints(weeklySeries([10, 20, 15])), [0, 1, 0.5]);
    });

    test('flat series is centred', () {
      expect(sparklinePoints(weeklySeries([5, 5])), [0.5, 0.5]);
    });

    test('empty list gives no point', () {
      expect(sparklinePoints([]), isEmpty);
    });
  });

  test('lastYear keeps only the last 53 candles', () {
    final series = weeklySeries(List.generate(60, (i) => i + 1.0));
    final year = lastYear(series);
    expect(year.length, weeksInOneYear);
    expect(year.first.close, 8);
    expect(year.last.close, 60);
  });

  group('isStale', () {
    // Friday 2 October 2026 at 22:00.
    final friday = DateTime(2026, 10, 2, 22);

    test('same day is fresh', () {
      expect(isStale(friday, DateTime(2026, 10, 2, 23)), isFalse);
    });

    test('the weekend does not count', () {
      // Sat + Sun + Mon = only 1 business day.
      expect(isStale(friday, DateTime(2026, 10, 5, 9)), isFalse);
    });

    test('3 business days later is still fresh', () {
      expect(isStale(friday, DateTime(2026, 10, 7, 18)), isFalse);
    });

    test('4 business days later is stale', () {
      expect(isStale(friday, DateTime(2026, 10, 8, 8)), isTrue);
    });

    test('weekday to weekday without weekend', () {
      final monday = DateTime(2026, 10, 5, 10);
      expect(isStale(monday, DateTime(2026, 10, 8)), isFalse);
      expect(isStale(monday, DateTime(2026, 10, 9)), isTrue);
    });

    test('a date in the future is not stale', () {
      expect(isStale(friday, DateTime(2026, 9, 1)), isFalse);
    });
  });
}
