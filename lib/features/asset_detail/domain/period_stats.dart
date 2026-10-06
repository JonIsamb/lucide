// Indicators of the detail screen. Pure Dart: values in, values out.
// Every function returns null rather than a misleading number when the
// series is too short or contains a price of 0.

import 'dart:math' as math;

// Prefixed: PeriodStats has a field named changePercent too.
import '../../catalog/domain/asset_metrics.dart' as metrics;
import '../../catalog/domain/weekly_candle.dart';

/// Prices are weekly: a year is 52 returns, for every kind of asset.
const weeksPerYear = 52;

/// A number and the week it was reached.
class DatedValue {
  const DatedValue(this.value, this.date);

  final double value;
  final DateTime date;
}

/// The biggest fall between a peak and the lowest point that follows.
class Drawdown {
  const Drawdown({
    required this.percent,
    required this.peakIndex,
    required this.troughIndex,
  });

  /// Size of the fall, positive: 28 means the price lost 28 %.
  final double percent;

  /// Positions of the peak and of the low in the series.
  final int peakIndex;
  final int troughIndex;
}

/// How strongly the price moves, in words a beginner understands.
///
/// The limits are an editorial choice (see docs/limitations.md), not a
/// financial standard.
enum VolatilityLevel {
  calm,
  moderate,
  high,
  veryHigh;

  static VolatilityLevel fromPercent(double volatility) {
    if (volatility < 10) return VolatilityLevel.calm;
    if (volatility < 20) return VolatilityLevel.moderate;
    if (volatility < 40) return VolatilityLevel.high;
    return VolatilityLevel.veryHigh;
  }
}

/// Change from each close to the next: 0.1 for +10 %.
///
/// Null when a close of 0 makes a return impossible to compute.
List<double>? simpleReturns(List<double> closes) {
  final returns = <double>[];
  for (var i = 1; i < closes.length; i++) {
    final previous = closes[i - 1];
    if (previous == 0) return null;
    returns.add(closes[i] / previous - 1);
  }
  return returns;
}

/// Annualized volatility in percent: standard deviation of the simple
/// returns, multiplied by the square root of [periodsPerYear].
///
/// Sample standard deviation (divided by n - 1), so at least 2 returns,
/// that is 3 closes, are needed.
double? annualizedVolatility(
  List<double> closes, {
  int periodsPerYear = weeksPerYear,
}) {
  final returns = simpleReturns(closes);
  if (returns == null || returns.length < 2) return null;

  final mean = returns.reduce((a, b) => a + b) / returns.length;
  var squares = 0.0;
  for (final r in returns) {
    squares += (r - mean) * (r - mean);
  }
  final deviation = math.sqrt(squares / (returns.length - 1));
  return deviation * math.sqrt(periodsPerYear) * 100;
}

/// The maximum drawdown of [closes] (oldest first).
///
/// Example of the subject: 100, 110, 125, 115, 90, 105 gives 28 %, from
/// the peak 125 to the low 90. A series that never falls gives 0 %.
/// Null with fewer than 2 closes.
Drawdown? maxDrawdown(List<double> closes) {
  if (closes.length < 2) return null;

  var peakIndex = 0;
  var worst = const Drawdown(percent: 0, peakIndex: 0, troughIndex: 0);
  for (var i = 1; i < closes.length; i++) {
    final peak = closes[peakIndex];
    if (closes[i] > peak) {
      peakIndex = i;
      continue;
    }
    // A peak of 0 cannot fall: skip it instead of dividing by zero.
    if (peak <= 0) continue;
    final fall = (peak - closes[i]) / peak * 100;
    if (fall > worst.percent) {
      worst = Drawdown(percent: fall, peakIndex: peakIndex, troughIndex: i);
    }
  }
  return worst;
}

/// Every indicator of one period, computed once from its candles.
class PeriodStats {
  const PeriodStats({
    this.changePercent,
    this.valueOf100,
    this.volatilityPercent,
    this.drawdown,
    this.high,
    this.low,
    this.rangePosition,
    this.fromHighPercent,
    this.bestWeek,
    this.worstWeek,
    this.risingWeeks = 0,
    this.weekCount = 0,
    this.averageVolume,
  });

  /// [candles] are those of the period, oldest first.
  factory PeriodStats.compute(List<WeeklyCandle> candles) {
    if (candles.isEmpty) return const PeriodStats();

    final closes = [for (final c in candles) c.close];
    final change = metrics.changePercent(candles);

    var high = candles.first;
    var low = candles.first;
    for (final candle in candles) {
      if (candle.high > high.high) high = candle;
      if (candle.low < low.low) low = candle;
    }
    final range = high.high - low.low;
    final last = closes.last;

    final returns = simpleReturns(closes) ?? const <double>[];
    DatedValue? best;
    DatedValue? worst;
    var rising = 0;
    for (var i = 0; i < returns.length; i++) {
      final percent = returns[i] * 100;
      // A return belongs to the week that ends it.
      final date = candles[i + 1].date;
      if (best == null || percent > best.value) {
        best = DatedValue(percent, date);
      }
      if (worst == null || percent < worst.value) {
        worst = DatedValue(percent, date);
      }
      if (percent > 0) rising++;
    }

    final volumes = [
      for (final c in candles)
        if (c.volume != null) c.volume!,
    ];

    return PeriodStats(
      changePercent: change,
      valueOf100: change == null ? null : 100 + change,
      volatilityPercent: annualizedVolatility(closes),
      drawdown: maxDrawdown(closes),
      high: DatedValue(high.high, high.date),
      low: DatedValue(low.low, low.date),
      rangePosition: range == 0
          ? null
          : ((last - low.low) / range).clamp(0.0, 1.0),
      fromHighPercent: high.high == 0
          ? null
          : (last - high.high) / high.high * 100,
      bestWeek: best,
      worstWeek: worst,
      risingWeeks: rising,
      weekCount: returns.length,
      averageVolume: volumes.isEmpty
          ? null
          : volumes.reduce((a, b) => a + b) / volumes.length,
    );
  }

  /// Change between the first and the last close, in percent.
  final double? changePercent;

  /// What 100 units of currency placed at the start are worth at the end,
  /// before fees and taxes.
  final double? valueOf100;

  /// See [annualizedVolatility].
  final double? volatilityPercent;

  /// See [maxDrawdown]. Its indices point into the candles of the period.
  final Drawdown? drawdown;

  /// Highest and lowest price reached during a week of the period.
  final DatedValue? high;
  final DatedValue? low;

  /// Where the last close stands between [low] (0) and [high] (1).
  /// Null when the price never moved.
  final double? rangePosition;

  /// Distance of the last close to [high], in percent (0 or negative).
  final double? fromHighPercent;

  /// Best and worst weekly change, in percent.
  final DatedValue? bestWeek;
  final DatedValue? worstWeek;

  /// Weeks that closed higher than the previous one, out of [weekCount].
  final int risingWeeks;
  final int weekCount;

  /// Mean weekly volume. Null when the provider sends none (cryptos).
  final double? averageVolume;

  VolatilityLevel? get volatilityLevel => volatilityPercent == null
      ? null
      : VolatilityLevel.fromPercent(volatilityPercent!);
}
