import '../../catalog/domain/asset_metrics.dart';
import '../../catalog/domain/weekly_candle.dart';

/// Candles of 5 years: the stored history is longer (about 10 years).
const weeksInFiveYears = 261;

/// The four periods of the detail chart.
///
/// Prices are weekly, so a period is a number of candles: the weeks of the
/// period plus the starting week (4 weeks need 5 points).
enum ChartPeriod {
  oneMonth('1 mois', 5),
  sixMonths('6 mois', 27),
  oneYear('1 an', weeksInOneYear),

  fiveYears('5 ans', weeksInFiveYears);

  const ChartPeriod(this.label, this.candleCount);

  /// Text on the period selector.
  final String label;
  final int? candleCount;
}

/// The candles of [period], oldest first. A history shorter than the
/// period is returned whole.
List<WeeklyCandle> candlesFor(List<WeeklyCandle> candles, ChartPeriod period) {
  final count = period.candleCount;
  if (count == null || candles.length <= count) return candles;
  return candles.sublist(candles.length - count);
}
