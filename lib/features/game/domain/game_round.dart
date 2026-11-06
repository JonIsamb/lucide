import '../../catalog/domain/instrument.dart';
import 'earnings_announcement.dart';
import 'market_event.dart';

/// The player's bet on the 4 hidden weeks.
enum Guess { higher, lower }

/// One round of the game: 26 visible weeks, then 4 hidden weeks, cut out
/// of the real weekly prices of [asset].
///
/// Prices are rebased so the first visible week equals 100: the player
/// cannot recognise the asset from its price level.
class GameRound {
  GameRound({
    required this.asset,
    required this.history,
    required this.future,
    required this.start,
    required this.end,
    DateTime? visibleEnd,
    this.earnings = const [],
    this.events = const [],
    this.contextEvents = const [],
  }) : visibleEnd =
           visibleEnd ?? start.add(Duration(days: 7 * (history.length - 1)));

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

  /// First day of the last visible week. Everything dated before the
  /// following week is known to the player when he bets.
  final DateTime visibleEnd;

  /// First day of the hidden weeks: nothing dated from then on may be
  /// shown before the answer.
  DateTime get hiddenStart => visibleEnd.add(const Duration(days: 7));

  /// Every earnings announcement of the 30 weeks, hidden ones included.
  final List<EarningsAnnouncement> earnings;

  /// The announcements the player may see before he bets: those of the
  /// visible weeks.
  List<EarningsAnnouncement> get visibleEarnings => [
    for (final announcement in earnings)
      if (announcement.day.isBefore(hiddenStart)) announcement,
  ];

  /// The real events that overlap the 30 weeks and concern this kind of
  /// asset. Shown after the answer, on request.
  final List<MarketEvent> events;

  /// The real events that began during the visible weeks (at most
  /// [maxEventsPerRound]). Shown before the answer, cut at [hiddenStart].
  final List<MarketEvent> contextEvents;
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
