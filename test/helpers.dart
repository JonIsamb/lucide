import 'dart:async';

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/core/database/app_database.dart';
import 'package:lucide/core/network/api_exception.dart';
import 'package:lucide/core/network/market_data_api.dart';
import 'package:lucide/features/catalog/domain/asset_overview.dart';
import 'package:lucide/features/catalog/domain/instrument.dart';
import 'package:lucide/features/catalog/domain/weekly_candle.dart';
import 'package:lucide/features/game/data/game_repository.dart';
import 'package:lucide/features/game/domain/game_round.dart';
import 'package:lucide/features/game/domain/played_game.dart';
import 'package:lucide/features/simulator/domain/simulation_params.dart';
import 'package:lucide/features/simulator/domain/simulation_result.dart';
import 'package:lucide/features/game/domain/round_draw.dart';

/// An empty database in memory, for widget tests.
///
/// When its last listener leaves, a drift query stream normally closes on
/// a zero-length timer. In a widget test the screens are destroyed at the
/// end of the test with that timer still pending, which fails the test:
/// here streams close at once instead (option documented by drift).
AppDatabase memoryDatabase() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

/// Waits (a little) until a stream listener has received what [done]
/// expects. Drift sends query results asynchronously, after the write.
Future<void> waitUntil(bool Function() done) async {
  for (var i = 0; i < 200 && !done(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  expect(done(), isTrue, reason: 'the stream never sent the expected value');
}

/// A candle where only the date and the close matter.
WeeklyCandle candle(DateTime date, double close) => WeeklyCandle(
  date: date,
  open: close,
  high: close,
  low: close,
  close: close,
);

/// [closes.length] weekly candles starting on Monday 6 October 2025.
List<WeeklyCandle> weeklySeries(List<double> closes) => [
  for (var i = 0; i < closes.length; i++)
    candle(DateTime.utc(2025, 10, 6 + 7 * i), closes[i]),
];

Instrument instrument(
  String symbol, {
  String? name,
  InstrumentType type = InstrumentType.stock,
  String description = '',
}) => Instrument(
  symbol: symbol,
  name: name ?? symbol,
  type: type,
  currency: type == InstrumentType.crypto ? 'EUR' : 'USD',
  peaEligible: false,
  description: description,
);

/// Fake game repository: every game is made of the same prepared rounds,
/// and finished games are kept in memory, newest first.
class FakeGameRepository implements GameRepository {
  FakeGameRepository(this.rounds, {List<PlayedGame> played = const []})
    : played = [...played];

  final List<GameRound> rounds;
  int draws = 0;

  /// Finished games, newest first, like the database returns them.
  final List<PlayedGame> played;

  /// Makes [saveGame] fail, as a full or broken database would.
  bool failSaves = false;

  final _changes = StreamController<void>.broadcast();

  @override
  Future<List<GameRound>> drawGame() async {
    draws++;
    return rounds;
  }

  @override
  Future<List<GameSeries>> loadSeries() async => const [];

  @override
  Future<void> saveGame({required int score, required int roundCount}) async {
    if (failSaves) throw StateError('database unavailable');
    played.insert(
      0,
      PlayedGame(
        finishedAt: DateTime.utc(2026, 11, 10),
        score: score,
        roundCount: roundCount,
      ),
    );
    _changes.add(null);
  }

  /// Like a drift query: the current list, then a new one after each save.
  @override
  Stream<List<PlayedGame>> watchPlayedGames() async* {
    yield List.of(played);
    await for (final _ in _changes.stream) {
      yield List.of(played);
    }
  }
}

AssetOverview overview(
  String symbol, {
  String? name,
  InstrumentType type = InstrumentType.stock,
  double? change,
}) => AssetOverview(
  instrument: instrument(symbol, name: name, type: type),
  isFavorite: false,
  yearlyChange: change,
);

/// Fake API: serves prepared series and remembers every call.
class FakeApi implements MarketDataApi {
  final Map<String, List<WeeklyCandle>> series = {};
  final Map<String, String?> logos = {};
  final Map<String, ApiException> errors = {};

  /// (symbol, startDate) of each /time_series call.
  final List<(String, DateTime?)> seriesCalls = [];
  final List<String> logoCalls = [];

  @override
  Future<List<WeeklyCandle>> fetchWeeklySeries(
    String symbol, {
    String? exchange,
    DateTime? startDate,
  }) async {
    seriesCalls.add((symbol, startDate));
    if (errors[symbol] case final error?) throw error;
    final all = series[symbol] ?? const [];
    if (startDate == null) return all;
    return all.where((c) => !c.date.isBefore(startDate)).toList();
  }

  @override
  Future<String?> fetchLogoUrl(String symbol, {String? exchange}) async {
    logoCalls.add(symbol);
    if (errors[symbol] case final error?) throw error;
    return logos[symbol];
  }
}

/// A simulation result built step by step, so each bar of the cascade is
/// exactly the given fraction: real = gross + fx + fees + tax + inflation.
/// By default: the S&P 500 example of the mockup (+20 % announced, +3,7 %
/// real), 1 000 € from 15 March 2024 to 15 March 2026.
SimulationResult simulationResult({
  double gross = 0.20,
  double fx = -0.05,
  double fees = -0.015,
  double tax = -0.045,
  double inflation = -0.053,
  String assetName = 'S&P 500',
  double amount = 1000,
  DateTime? buyDay,
  DateTime? sellDay,
}) {
  final eur = gross + fx;
  final afterFees = eur + fees;
  final afterTax = afterFees + tax;
  return SimulationResult(
    params: SimulationParams(
      symbol: 'SPY',
      assetName: assetName,
      assetType: InstrumentType.etf,
      currency: 'USD',
      peaEligible: false,
      amount: amount,
      buyDay: buyDay ?? DateTime.utc(2024, 3, 15),
      sellDay: sellDay ?? DateTime.utc(2026, 3, 15),
      envelope: Envelope.securitiesAccount,
    ),
    buyPrice: 100,
    sellPrice: 100 * (1 + gross),
    buyFxRate: 1.1,
    sellFxRate: 1.1,
    grossPerformance: gross,
    eurPerformance: eur,
    afterFeesPerformance: afterFees,
    afterTaxPerformance: afterTax,
    realPerformance: afterTax + inflation,
    buyFee: 0,
    sellFee: 0,
    annualFees: 0,
    taxBase: 0,
    taxRate: 0.314,
    tax: -tax * amount,
    taxExemption: tax == 0 ? TaxExemption.loss : TaxExemption.none,
    cumulativeInflation: -inflation,
    inflationIsEstimate: false,
    holdingDays: 730,
  );
}
