import '../../catalog/domain/instrument.dart';
import 'earnings_hint.dart';

/// The player's bet on the 4 hidden weeks.
enum Guess { higher, lower }

/// One round of the game: 26 visible weeks, then 4 hidden weeks, cut out
/// of the real weekly prices of [asset].
///
/// Prices are rebased so the first visible week equals 100: the player
/// cannot recognise the asset from its price level.
class GameRound {
  const GameRound({
    required this.asset,
    required this.history,
    required this.future,
    required this.start,
    required this.end,
    this.hints = const [],
  });

  /// The real asset behind the curve. Shown only once the round is
  /// revealed: its name, its type and its description give the context.
  final Instrument asset;

  /// The 26 visible weekly closes (base 100), oldest first.
  final List<double> history;

  /// The 4 hidden weekly closes, on the same base as [history].
  final List<double> future;

  /// First visible week.
  final DateTime start;

  /// Last hidden week.
  final DateTime end;

  /// What the hint mode can say: the earnings announcements published
  /// during the visible weeks, oldest first. Empty when none is known.
  final List<EarningsHint> hints;
}

/// Numbers shown under the final score. They will come from the saved
/// games once the game is persisted.
class GameStats {
  const GameStats({
    required this.gamesPlayed,
    required this.bestScore,
    required this.averageScore,
  });

  final int gamesPlayed;
  final int bestScore;
  final double averageScore;
}
