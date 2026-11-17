import 'dart:math' as math;

import '../../catalog/domain/weekly_candle.dart';

// Prediction: a price after the last known one. It is not a forecast, only
// the past average growth carried forward. Pure functions, no clock.

/// How far after the last known price a simulation may go, in years.
const maxProjectionYears = 10;

/// A weekly candle covers 7 days: a day is inside the history up to 6 days
/// after the first day of the last candle.
const _lastCandleCoverage = Duration(days: 6);

/// Last day covered by a price. [candles] are sorted, oldest first and not
/// empty.
DateTime lastKnownDay(List<WeeklyCandle> candles) =>
    candles.last.date.add(_lastCandleCoverage);

/// Last day a simulation may end on, known price or projected.
DateTime lastProjectableDay(List<WeeklyCandle> candles) {
  final known = lastKnownDay(candles);
  return DateTime.utc(known.year + maxProjectionYears, known.month, known.day);
}

/// Average yearly growth of the price over the whole stored history, as a
/// fraction (0.08 = +8 % a year): (last / first) ^ (365 / days) − 1.
///
/// Null when it cannot be computed: fewer than two candles, a price that is
/// not positive.
double? historicalAnnualGrowth(List<WeeklyCandle> candles) {
  if (candles.length < 2) return null;
  final first = candles.first;
  final last = candles.last;
  final days = last.date.difference(first.date).inDays;
  if (days <= 0 || first.close <= 0 || last.close <= 0) return null;
  return math.pow(last.close / first.close, 365 / days).toDouble() - 1;
}

/// Close expected on [day] after the last known price: the last close
/// grown at [annualGrowth] for the years since the last candle.
double projectedClose(
  List<WeeklyCandle> candles,
  DateTime day,
  double annualGrowth,
) {
  final last = candles.last;
  final years = day.difference(last.date).inDays / 365;
  return last.close * math.pow(1 + annualGrowth, years);
}
