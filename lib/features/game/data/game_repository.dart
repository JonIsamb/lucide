import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catalog/data/catalog_repository.dart';
import '../../catalog/domain/weekly_candle.dart';
import '../domain/earnings_hint.dart';
import '../domain/game_round.dart';
import '../domain/round_draw.dart';
import 'earnings_dto.dart';

/// Gives the game its rounds, cut out of the weekly prices already stored
/// on the phone, with the earnings announcements shipped in the app
/// (assets/earnings.json). It never calls the API: the game works offline.
class GameRepository {
  GameRepository({
    required this._catalog,
    Random? random,
    Future<String> Function()? loadEarningsJson,
  }) : _random = random ?? Random(),
       _loadEarningsJson =
           loadEarningsJson ??
           (() => rootBundle.loadString('assets/earnings.json'));

  final CatalogRepository _catalog;
  final Future<String> Function() _loadEarningsJson;

  /// Tests pass `Random(seed)` to always get the same game.
  final Random _random;

  /// The rounds of a new game. Empty when too few prices are stored.
  Future<List<GameRound>> drawGame() async {
    return drawRounds(await loadSeries(), _random);
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

  /// The most recent candle is the current week: its close still moves
  /// every day, so it cannot be the answer of a round.
  static List<WeeklyCandle> _completedWeeks(List<WeeklyCandle> candles) =>
      candles.isEmpty ? candles : candles.sublist(0, candles.length - 1);
}

final gameRepositoryProvider = Provider<GameRepository>(
  (ref) => GameRepository(catalog: ref.watch(catalogRepositoryProvider)),
);
