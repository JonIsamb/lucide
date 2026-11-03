import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../catalog/domain/instrument.dart';
import '../../catalog/domain/weekly_candle.dart';
import '../domain/saved_simulation.dart';
import '../domain/simulation_result.dart';
import 'rates_api.dart';

/// Rates older than this many days are downloaded again.
const fxMaxAgeDays = 3;

/// The single place that decides between the local data and the network
/// for the simulator. The screens never call the API.
///
/// Order of data: the bundled seed fills an empty table on first use, the
/// network completes it afterwards. Computing never waits for the network.
class SimulatorRepository {
  SimulatorRepository({
    required this._database,
    required this._catalog,
    required this._api,
    Future<String> Function(String path)? loadAsset,
    DateTime Function()? now,
  }) : _loadAsset = loadAsset ?? rootBundle.loadString,
       _now = now ?? DateTime.now;

  final AppDatabase _database;
  final CatalogRepository _catalog;
  final RatesApi _api;
  final Future<String> Function(String path) _loadAsset;
  final DateTime Function() _now;

  static const fxSeedAsset = 'assets/seed/fx_eur_usd.json';
  static const inflationSeedAsset = 'assets/seed/inflation_fra.json';

  /// Fills the rate tables from the bundled files when they are empty, so
  /// the simulator works at the first launch, even offline.
  Future<void> seedIfEmpty() async {
    if (await _database.fxRatesDao.lastDay() == null) {
      final list = jsonDecode(await _loadAsset(fxSeedAsset)) as List<dynamic>;
      await _database.fxRatesDao.upsertAll([
        for (final entry in list)
          FxRatesCompanion.insert(
            day: (entry as List<dynamic>)[0] as String,
            eurUsd: (entry[1] as num).toDouble(),
          ),
      ]);
    }
    if ((await _database.inflationDao.allRates()).isEmpty) {
      final list =
          jsonDecode(await _loadAsset(inflationSeedAsset)) as List<dynamic>;
      await _database.inflationDao.upsertAll([
        for (final entry in list)
          InflationRatesCompanion.insert(
            year: Value((entry as List<dynamic>)[0] as int),
            rate: (entry[1] as num).toDouble(),
          ),
      ]);
    }
  }

  Future<List<Instrument>> loadInstruments() => _catalog.loadInstruments();

  /// Weekly candles of [symbol], oldest first. No network.
  Future<List<WeeklyCandle>> loadCandles(String symbol) async {
    return (await _catalog.loadDetail(symbol))?.candles ?? const [];
  }

  Future<List<FxRate>> loadFxRates() async {
    final rows = await _database.fxRatesDao.allRates();
    return [
      for (final row in rows)
        FxRate(DateTime.parse('${row.day}T00:00:00Z'), row.eurUsd),
    ];
  }

  Future<Map<int, double>> loadInflation() async {
    final rows = await _database.inflationDao.allRates();
    return {for (final row in rows) row.year: row.rate};
  }

  /// Asks the network for what is missing. Returns true when something new
  /// was stored. Throws an [ApiException] on failure: the caller keeps
  /// using the local data.
  Future<bool> refreshRates() async {
    var changed = false;
    final now = _now();

    final lastFx = await _database.fxRatesDao.lastDay();
    final lastFxDay = lastFx == null
        ? null
        : DateTime.parse('${lastFx}T00:00:00Z');
    if (lastFxDay == null || now.difference(lastFxDay).inDays > fxMaxAgeDays) {
      // One day of overlap is harmless: the primary key replaces it.
      final from = lastFxDay ?? DateTime.utc(now.year - 6);
      final fresh = await _api.fetchFxRates(from: from);
      if (fresh.isNotEmpty) {
        await _database.fxRatesDao.upsertAll([
          for (final r in fresh)
            FxRatesCompanion.insert(
              day: r.day.toIso8601String().substring(0, 10),
              eurUsd: r.eurUsd,
            ),
        ]);
        changed = true;
      }
    }

    final known = await loadInflation();
    final newestYear = known.keys.fold<int?>(
      null,
      (max, y) => max == null || y > max ? y : max,
    );
    // The World Bank publishes a year several months after it ends.
    if (newestYear == null || newestYear < now.year - 1) {
      final fresh = await _api.fetchInflation(
        fromYear: (newestYear ?? now.year - 10),
      );
      if (fresh.isNotEmpty) {
        await _database.inflationDao.upsertAll([
          for (final e in fresh.entries)
            InflationRatesCompanion.insert(year: Value(e.key), rate: e.value),
        ]);
        changed = true;
      }
    }
    return changed;
  }

  // --- Saved simulations (user data) ---------------------------------------

  Future<List<SavedSimulation>> loadSaved() async {
    final rows = await _database.simulationsDao.allSimulations();
    final saved = <SavedSimulation>[];
    for (final row in rows) {
      try {
        saved.add(
          SavedSimulation(
            id: row.id,
            createdAt: row.createdAt,
            result: SimulationResult.fromJson(
              jsonDecode(row.resultJson) as Map<String, dynamic>,
            ),
          ),
        );
      } on Object {
        // An unreadable row is hidden instead of breaking the whole list.
        continue;
      }
    }
    return saved;
  }

  /// Freezes [result] with its parameters.
  Future<SavedSimulation> save(SimulationResult result) async {
    final createdAt = _now();
    final id = await _database.simulationsDao.insertSimulation(
      SimulationsCompanion.insert(
        symbol: result.params.symbol,
        assetName: result.params.assetName,
        paramsJson: jsonEncode(result.params.toJson()),
        resultJson: jsonEncode(result.toJson()),
        createdAt: createdAt,
      ),
    );
    return SavedSimulation(id: id, createdAt: createdAt, result: result);
  }

  Future<void> delete(int id) => _database.simulationsDao.deleteSimulation(id);
}

final ratesApiProvider = Provider<RatesApi>((ref) => HttpRatesClient());

final simulatorRepositoryProvider = Provider<SimulatorRepository>(
  (ref) => SimulatorRepository(
    database: ref.watch(appDatabaseProvider),
    catalog: ref.watch(catalogRepositoryProvider),
    api: ref.watch(ratesApiProvider),
  ),
);
