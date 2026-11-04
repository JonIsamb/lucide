import 'dart:math' as math;

// Inflation: what a nominal gain is worth in purchasing power.

/// Real return from the nominal one, by the Fisher relation:
/// (1 + nominal) / (1 + inflation) − 1. All values are fractions (0.2 = 20 %).
///
/// With no inflation the real return is the nominal one. With negative
/// inflation (prices fall) it is higher than the nominal one.
double fisherRealReturn(double nominal, double cumulativeInflation) {
  return (1 + nominal) / (1 + cumulativeInflation) - 1;
}

/// Inflation over the holding period, built from yearly rates.
class InflationEstimate {
  const InflationEstimate({required this.cumulative, required this.isEstimate});

  /// Fraction: 0.05 means prices rose by 5 % over the period.
  final double cumulative;

  /// True when at least one year had no published rate and the last known
  /// one was used instead.
  final bool isEstimate;
}

/// Compounds the yearly rates ([ratesPercent], year → %) over [from, to].
///
/// A partial year counts for its share of the days, compounded:
/// (1 + rate) ^ share. A year with no rate takes the most recent earlier
/// year that has one (or the oldest known rate if there is none earlier),
/// and the result is marked as an estimate.
///
/// Returns null when there is no rate at all, or when [to] is not after
/// [from]. Dates are plain days in UTC.
InflationEstimate? cumulativeInflation(
  Map<int, double> ratesPercent,
  DateTime from,
  DateTime to,
) {
  if (ratesPercent.isEmpty || !to.isAfter(from)) return null;

  final knownYears = ratesPercent.keys.toList()..sort();
  var factor = 1.0;
  var isEstimate = false;

  for (var year = from.year; year <= to.year; year++) {
    final yearStart = DateTime.utc(year);
    final nextYearStart = DateTime.utc(year + 1);
    final start = from.isAfter(yearStart) ? from : yearStart;
    final end = to.isBefore(nextYearStart) ? to : nextYearStart;
    final days = end.difference(start).inDays;
    if (days <= 0) continue;
    final share = days / nextYearStart.difference(yearStart).inDays;

    double rate;
    if (ratesPercent.containsKey(year)) {
      rate = ratesPercent[year]!;
    } else {
      isEstimate = true;
      final earlier = knownYears.where((y) => y < year);
      rate = ratesPercent[earlier.isEmpty ? knownYears.first : earlier.last]!;
    }
    factor *= math.pow(1 + rate / 100, share);
  }
  return InflationEstimate(cumulative: factor - 1, isEstimate: isEstimate);
}
