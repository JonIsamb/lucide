// Describes how a round's 30 weeks behaved, from the prices alone.
// Pure Dart. It never claims to know why: the reasons come from the
// events file (market_event.dart).

import '../../asset_detail/domain/period_stats.dart';
import '../../catalog/domain/instrument.dart';

/// How agitated the market was during the round.
enum MarketRegime { calm, lively, crisis }

/// Which way the price went from the first to the last week.
enum WindowTrend { up, down, flat }

/// Editorial limits (see docs/limitations.md), not financial standards,
/// except the two drawdowns: -10 % is the usual "correction" and -20 % the
/// usual "bear market" threshold.
const correctionDrawdown = 10.0;
const bearDrawdown = 20.0;
const livelyVolatility = 30.0;

/// A crypto routinely moves twice as much as a stock or an ETF: its limits
/// are doubled so that it is not "in crisis" every other month.
const cryptoScale = 2.0;

/// The trend is "flat" when the change stays within this many %.
const flatTrendLimit = 5.0;

/// What the numbers of a round say.
class WindowAnalysis {
  const WindowAnalysis({
    required this.regime,
    required this.trend,
    required this.weeks,
    required this.changePercent,
    required this.volatilityPercent,
    required this.drawdownPercent,
  });

  final MarketRegime regime;
  final WindowTrend trend;

  /// Number of weekly closes analyzed.
  final int weeks;

  /// Change from the first to the last close, in %.
  final double changePercent;

  /// Annualized volatility of the weekly returns, in %.
  final double volatilityPercent;

  /// Biggest fall from a peak to the next low, in % (positive).
  final double drawdownPercent;
}

/// Analyzes [closes] (oldest first, the whole round: visible then hidden
/// weeks). Null when the series is too short or has a price of 0.
WindowAnalysis? analyzeWindow(List<double> closes, InstrumentType type) {
  if (closes.length < 3 || closes.first <= 0) return null;
  final volatility = annualizedVolatility(closes);
  final drawdown = maxDrawdown(closes);
  if (volatility == null || drawdown == null) return null;

  final scale = type == InstrumentType.crypto ? cryptoScale : 1.0;
  final MarketRegime regime;
  if (drawdown.percent >= bearDrawdown * scale) {
    regime = MarketRegime.crisis;
  } else if (drawdown.percent >= correctionDrawdown * scale ||
      volatility >= livelyVolatility * scale) {
    regime = MarketRegime.lively;
  } else {
    regime = MarketRegime.calm;
  }

  final change = (closes.last / closes.first - 1) * 100;
  final trend = change >= flatTrendLimit
      ? WindowTrend.up
      : change <= -flatTrendLimit
      ? WindowTrend.down
      : WindowTrend.flat;

  return WindowAnalysis(
    regime: regime,
    trend: trend,
    weeks: closes.length,
    changePercent: change,
    volatilityPercent: volatility,
    drawdownPercent: drawdown.percent,
  );
}
