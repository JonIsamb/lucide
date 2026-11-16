import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../catalog/domain/weekly_candle.dart';
import '../domain/earnings_announcement.dart';
import '../domain/game_round.dart';
import '../domain/market_event.dart';
import '../domain/played_game.dart';
import '../domain/round_draw.dart';
import 'earnings_dto.dart';
import 'market_events_dto.dart';

/// Gives the game its rounds, cut out of the weekly prices already stored
/// on the phone, with the earnings announcements shipped in the app
/// (assets/earnings.json). It never calls the API: the game works offline.
///
/// It also keeps the player's finished games (user data, in their own
/// table and DAO).
class GameRepository {
  GameRepository({
    required this._catalog,
    required this._database,
    Random? random,
    Future<String> Function()? loadEarningsJson,
    Future<String> Function()? loadEventsJson,
    DateTime Function()? now,
  }) : _random = random ?? Random(),
       _now = now ?? DateTime.now,
       _loadEarningsJson =
           loadEarningsJson ??
           (() => rootBundle.loadString('assets/earnings.json')),
       _loadEventsJson =
           loadEventsJson ??
           (() => rootBundle.loadString('assets/market_events.json'));

  final CatalogRepository _catalog;
  final AppDatabase _database;
  final DateTime Function() _now;
  final Future<String> Function() _loadEarningsJson;
  final Future<String> Function() _loadEventsJson;

  /// Tests pass `Random(seed)` to always get the same game.
  final Random _random;

  /// The rounds of a new game. Empty when too few prices are stored.
  Future<List<GameRound>> drawGame() async {
    return drawRounds(await loadSeries(), _random, events: await _loadEvents());
  }

  /// The completed weeks of every asset, as stored locally. No network.
  Future<List<GameSeries>> loadSeries() async {
    final details = await _catalog.loadAllDetails();
    final announcements = await _loadAnnouncements();
    return [
      for (final detail in details)
        GameSeries(
          asset: detail.instrument,
          candles: _completedWeeks(detail.candles),
          announcements: announcements[detail.instrument.symbol] ?? const [],
        ),
    ];
  }

  /// Announcements by symbol. A missing or unreadable file only removes
  /// the hints: the game itself must still work.
  Future<Map<String, List<EarningsAnnouncement>>> _loadAnnouncements() async {
    try {
      return parseEarnings(await _loadEarningsJson());
    } on Exception {
      return const {};
    }
  }

  /// The real events of assets/market_events.json. A missing or unreadable
  /// file only removes the explanations: the game itself must still work.
  Future<List<MarketEvent>> _loadEvents() async {
    try {
      return parseMarketEvents(await _loadEventsJson());
    } on Object {
      return const [];
    }
  }

  // --- Finished games (user data) ------------------------------------------

  /// Saves a game that just ended, dated now.
  Future<void> saveGame({required int score, required int roundCount}) {
    return _database.gameSessionsDao.insertSession(
      GameSessionsCompanion.insert(
        finishedAt: _now(),
        score: score,
        roundCount: roundCount,
      ),
    );
  }

  /// Every finished game, newest first. Sends the list again after each
  /// saved game, so the screens that show it stay up to date by themselves.
  Stream<List<PlayedGame>> watchPlayedGames() {
    return _database.gameSessionsDao.watchSessions().map(
      (rows) => [
        for (final row in rows)
          PlayedGame(
            finishedAt: row.finishedAt,
            score: row.score,
            roundCount: row.roundCount,
          ),
      ],
    );
  }

  /// The most recent candle is the current week: its close still moves
  /// every day, so it cannot be the answer of a round.
  static List<WeeklyCandle> _completedWeeks(List<WeeklyCandle> candles) =>
      candles.isEmpty ? candles : candles.sublist(0, candles.length - 1);
}

final gameRepositoryProvider = Provider<GameRepository>(
  (ref) => GameRepository(
    catalog: ref.watch(catalogRepositoryProvider),
    database: ref.watch(appDatabaseProvider),
  ),
);
