// Pure business calculations: no Flutter, no database, no network.
// They only take values and return values, so they are easy to unit-test.

import 'weekly_candle.dart';

/// Number of weekly candles that make "1 year": 52 weeks plus the starting
/// week, so the change covers a full year.
const weeksInOneYear = 53;

/// Beyond this many business days without fresh data, the update date is
/// shown in the alert color (spec, section 1).
const staleAfterBusinessDays = 3;

/// The last [weeksInOneYear] candles, oldest first.
List<WeeklyCandle> lastYear(List<WeeklyCandle> candles) {
  if (candles.length <= weeksInOneYear) return candles;
  return candles.sublist(candles.length - weeksInOneYear);
}

/// Percentage change between the first and the last close (oldest first).
///
/// Returns null when it cannot be computed honestly: fewer than 2 candles,
/// or a first close of 0 (division by zero).
double? yearlyChangePercent(List<WeeklyCandle> candles) {
  if (candles.length < 2) return null;
  final first = candles.first.close;
  if (first == 0) return null;
  final last = candles.last.close;
  return (last - first) / first * 100;
}

/// The closes scaled between 0 (lowest) and 1 (highest), for the sparkline.
///
/// A flat series gives 0.5 everywhere, so it is drawn as a centred line
/// instead of dividing by zero.
List<double> sparklinePoints(List<WeeklyCandle> candles) {
  if (candles.isEmpty) return const [];
  final closes = candles.map((c) => c.close).toList();
  var min = closes.first;
  var max = closes.first;
  for (final close in closes) {
    if (close < min) min = close;
    if (close > max) max = close;
  }
  final range = max - min;
  if (range == 0) return List.filled(closes.length, 0.5);
  return [for (final close in closes) (close - min) / range];
}

/// True when the data is older than [staleAfterBusinessDays] business days.
///
/// Weekends do not count because markets are closed: data from Friday
/// evening is still fresh on Monday.
bool isStale(DateTime lastUpdate, DateTime now) {
  var day = _dateOnly(lastUpdate);
  final today = _dateOnly(now);
  var businessDays = 0;
  while (day.isBefore(today)) {
    day = DateTime(day.year, day.month, day.day + 1);
    if (day.weekday != DateTime.saturday && day.weekday != DateTime.sunday) {
      businessDays++;
    }
  }
  return businessDays > staleAfterBusinessDays;
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
