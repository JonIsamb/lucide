// Draws the rounds of a game out of real weekly prices. Pure Dart: the
// random generator is given by the caller, so a test with a fixed seed
// always gets the same game.

import 'dart:math';

import '../../catalog/domain/instrument.dart';
import '../../catalog/domain/weekly_candle.dart';
import 'earnings_hint.dart';
import 'game_round.dart';
import 'game_verdict.dart';

const visibleWeeks = 26;
const hiddenWeeks = 4;

/// A round needs this many weeks in a row.
const windowWeeks = visibleWeeks + hiddenWeeks;

/// Two candles further apart than this are not two weeks in a row: at
/// least one week is missing between them. 7 days is the normal gap; a
/// week starting on a bank holiday can push it to 8 or 9.
const maxWeekGap = Duration(days: 10);

/// The stored weekly prices of one asset, oldest first, and its known
/// earnings announcements (empty for ETFs, cryptos and missing data).
class GameSeries {
  const GameSeries({
    required this.asset,
    required this.candles,
    this.announcements = const [],
  });

  final Instrument asset;
  final List<WeeklyCandle> candles;
  final List<EarningsAnnouncement> announcements;
}

/// Index of the first candle of every window of [windowWeeks] weeks in a
/// row, all with a price above zero. Empty when the series is too short.
List<int> windowStarts(List<WeeklyCandle> candles) {
  final starts = <int>[];
  // First candle of the current run of usable weeks in a row.
  var runStart = 0;
  for (var i = 0; i < candles.length; i++) {
    if (candles[i].close <= 0) {
      runStart = i + 1;
      continue;
    }
    if (i > runStart &&
        candles[i].date.difference(candles[i - 1].date) > maxWeekGap) {
      runStart = i;
    }
    if (i - runStart + 1 >= windowWeeks) starts.add(i - windowWeeks + 1);
  }
  return starts;
}

/// Draws [count] rounds among every possible window of every series.
///
/// Two rounds never share a week of the same asset: the reveal of one
/// would give away the answer of the other.
///
/// Returns an empty list when the prices in store cannot give [count]
/// rounds: a shorter game could not be compared with a coin.
List<GameRound> drawRounds(
  List<GameSeries> series,
  Random random, {
  int count = roundsPerGame,
}) {
  final candidates = [
    for (var s = 0; s < series.length; s++)
      for (final start in windowStarts(series[s].candles))
        (series: s, start: start),
  ];

  final rounds = <GameRound>[];
  while (rounds.length < count && candidates.isNotEmpty) {
    final pick = candidates[random.nextInt(candidates.length)];
    rounds.add(_cutRound(series[pick.series], pick.start));
    candidates.removeWhere(
      (c) =>
          c.series == pick.series && (c.start - pick.start).abs() < windowWeeks,
    );
  }
  return rounds.length == count ? rounds : const [];
}

/// The window starting at [start], rebased so its first week equals 100.
GameRound _cutRound(GameSeries series, int start) {
  final window = series.candles.sublist(start, start + windowWeeks);
  final base = window.first.close;
  final prices = [for (final candle in window) candle.close / base * 100];
  return GameRound(
    asset: series.asset,
    history: prices.sublist(0, visibleWeeks),
    future: prices.sublist(visibleWeeks),
    start: window.first.date,
    end: window.last.date,
    hints: earningsHints(
      weekStarts: [for (final candle in window) candle.date],
      visibleWeeks: visibleWeeks,
      announcements: series.announcements,
    ),
  );
}
