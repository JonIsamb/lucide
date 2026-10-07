import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/features/asset_detail/domain/period_stats.dart';
import 'package:lucide/features/catalog/domain/weekly_candle.dart';

import '../../../helpers.dart';

void main() {
  group('simpleReturns', () {
    test('empty and single close give no return', () {
      expect(simpleReturns([]), isEmpty);
      expect(simpleReturns([100]), isEmpty);
    });

    test('change from each close to the next', () {
      final returns = simpleReturns([100, 110, 99])!;
      expect(returns[0], closeTo(0.10, 1e-9));
      expect(returns[1], closeTo(-0.10, 1e-9));
    });

    test('a close of 0 makes returns impossible', () {
      expect(simpleReturns([100, 0, 50]), isNull);
    });
  });

  group('annualizedVolatility', () {
    test('needs at least 3 closes', () {
      expect(annualizedVolatility([]), isNull);
      expect(annualizedVolatility([100]), isNull);
      expect(annualizedVolatility([100, 110]), isNull);
    });

    test('constant series does not move', () {
      expect(annualizedVolatility([50, 50, 50, 50]), 0);
    });

    test('a close of 0 gives no value', () {
      expect(annualizedVolatility([100, 0, 50, 60]), isNull);
    });

    test('sample standard deviation times the square root of 52', () {
      // Returns +10 % and -10 %: mean 0, deviation sqrt(0.02) = 0.14142.
      // 0.14142 x sqrt(52) = 1.0198, that is 101.98 %.
      expect(annualizedVolatility([100, 110, 99]), closeTo(101.98, 0.01));
    });

    test('the number of periods per year can be changed', () {
      // Same returns, annualized over 1 period: 14.14 %.
      expect(
        annualizedVolatility([100, 110, 99], periodsPerYear: 1),
        closeTo(14.14, 0.01),
      );
    });
  });

  group('maxDrawdown', () {
    test('empty and single close', () {
      expect(maxDrawdown([]), isNull);
      expect(maxDrawdown([100]), isNull);
    });

    test('example of the subject: 28 % from 125 down to 90', () {
      final drawdown = maxDrawdown([100, 110, 125, 115, 90, 105])!;
      expect(drawdown.percent, closeTo(28, 1e-9));
      expect(drawdown.peakIndex, 2);
      expect(drawdown.troughIndex, 4);
    });

    test('constant or always rising series never falls', () {
      expect(maxDrawdown([50, 50, 50])!.percent, 0);
      expect(maxDrawdown([10, 20, 30])!.percent, 0);
    });

    test('the low must come after the peak', () {
      // 50 is the lowest close, but it comes before the peak of 200.
      final drawdown = maxDrawdown([50, 200, 150])!;
      expect(drawdown.percent, closeTo(25, 1e-9));
      expect(drawdown.peakIndex, 1);
      expect(drawdown.troughIndex, 2);
    });

    test('a price falling to 0 is a 100 % loss', () {
      expect(maxDrawdown([100, 0])!.percent, 100);
    });

    test('a peak of 0 is skipped instead of dividing by zero', () {
      final drawdown = maxDrawdown([0, 0, 10, 5])!;
      expect(drawdown.percent, closeTo(50, 1e-9));
      expect(drawdown.peakIndex, 2);
    });
  });

  group('VolatilityLevel', () {
    test('limits at 10, 20 and 40 %', () {
      expect(VolatilityLevel.fromPercent(9.9), VolatilityLevel.calm);
      expect(VolatilityLevel.fromPercent(10), VolatilityLevel.moderate);
      expect(VolatilityLevel.fromPercent(19.9), VolatilityLevel.moderate);
      expect(VolatilityLevel.fromPercent(20), VolatilityLevel.high);
      expect(VolatilityLevel.fromPercent(40), VolatilityLevel.veryHigh);
    });
  });

  group('PeriodStats.compute', () {
    test('empty series: nothing is known', () {
      final stats = PeriodStats.compute([]);
      expect(stats.changePercent, isNull);
      expect(stats.volatilityPercent, isNull);
      expect(stats.volatilityLevel, isNull);
      expect(stats.drawdown, isNull);
      expect(stats.high, isNull);
      expect(stats.bestWeek, isNull);
      expect(stats.weekCount, 0);
      expect(stats.averageVolume, isNull);
    });

    test('single candle: a price but no change', () {
      final stats = PeriodStats.compute(weeklySeries([100]));
      expect(stats.changePercent, isNull);
      expect(stats.valueOf100, isNull);
      expect(stats.high!.value, 100);
      expect(stats.low!.value, 100);
      expect(stats.rangePosition, isNull);
      expect(stats.fromHighPercent, 0);
      expect(stats.bestWeek, isNull);
    });

    test('constant series', () {
      final stats = PeriodStats.compute(weeklySeries([50, 50, 50]));
      expect(stats.changePercent, 0);
      expect(stats.valueOf100, 100);
      expect(stats.volatilityPercent, 0);
      expect(stats.drawdown!.percent, 0);
      expect(stats.rangePosition, isNull);
      expect(stats.risingWeeks, 0);
      expect(stats.weekCount, 2);
    });

    test('first close of 0: no change, no returns', () {
      final stats = PeriodStats.compute(weeklySeries([0, 10, 20]));
      expect(stats.changePercent, isNull);
      expect(stats.volatilityPercent, isNull);
      expect(stats.bestWeek, isNull);
      expect(stats.weekCount, 0);
    });

    test('example of the subject', () {
      final candles = weeklySeries([100, 110, 125, 115, 90, 105]);
      final stats = PeriodStats.compute(candles);

      expect(stats.changePercent, closeTo(5, 1e-9));
      expect(stats.valueOf100, closeTo(105, 1e-9));
      expect(stats.drawdown!.percent, closeTo(28, 1e-9));

      expect(stats.high!.value, 125);
      expect(stats.high!.date, candles[2].date);
      expect(stats.low!.value, 90);
      expect(stats.low!.date, candles[4].date);
      // 105 between 90 and 125.
      expect(stats.rangePosition, closeTo(15 / 35, 1e-9));
      expect(stats.fromHighPercent, closeTo(-16, 1e-9));

      // Best: 90 to 105. Worst: 115 to 90. Dated by the week that ends them.
      expect(stats.bestWeek!.value, closeTo(16.6667, 1e-3));
      expect(stats.bestWeek!.date, candles[5].date);
      expect(stats.worstWeek!.value, closeTo(-21.7391, 1e-3));
      expect(stats.worstWeek!.date, candles[4].date);

      expect(stats.risingWeeks, 3);
      expect(stats.weekCount, 5);
    });

    test('high and low use the extremes inside the weeks', () {
      final day = DateTime.utc(2026, 1, 5);
      final stats = PeriodStats.compute([
        WeeklyCandle(date: day, open: 10, high: 14, low: 9, close: 12),
        WeeklyCandle(
          date: day.add(const Duration(days: 7)),
          open: 12,
          high: 13,
          low: 6,
          close: 11,
        ),
      ]);
      expect(stats.high!.value, 14);
      expect(stats.low!.value, 6);
      expect(stats.rangePosition, closeTo(5 / 8, 1e-9));
    });

    test('average volume ignores the weeks without volume', () {
      final day = DateTime.utc(2026, 1, 5);
      WeeklyCandle withVolume(int week, double? volume) => WeeklyCandle(
        date: day.add(Duration(days: 7 * week)),
        open: 10,
        high: 10,
        low: 10,
        close: 10,
        volume: volume,
      );

      final stats = PeriodStats.compute([
        withVolume(0, 100),
        withVolume(1, null),
        withVolume(2, 300),
      ]);
      expect(stats.averageVolume, 200);
    });

    test('no volume at all (cryptos)', () {
      expect(
        PeriodStats.compute(weeklySeries([1, 2, 3])).averageVolume,
        isNull,
      );
    });
  });
}
