import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/market_data_api.dart';
import '../../../core/providers.dart';
import '../../asset_detail/domain/asset_detail.dart';
import '../domain/asset_metrics.dart';
import '../domain/asset_overview.dart';
import '../domain/instrument.dart';
import '../domain/weekly_candle.dart';

/// A series younger than this is not downloaded again (spec, section 4).
/// Prices are weekly, so refreshing more often would only waste credits.
const seriesMaxAge = Duration(hours: 6);

/// If the overlapping candle moved by more than this, the stored history
/// is no longer comparable (split or price adjustment): reload everything.
const overlapTolerancePercent = 1.0;

/// Progress of [CatalogRepository.refreshAll], sent after each step.
class RefreshProgress {
  const RefreshProgress({
    required this.done,
    required this.total,
    this.updated,
  });

  /// Series already handled (downloaded or skipped after an error).
  final int done;

  /// Series to download in this refresh.
  final int total;

  /// The row that just changed, re-read from the database.
  final AssetOverview? updated;
}

/// The single place that decides between the local cache and the API.
///
/// Screens never call the API: they read the database through this class
/// and ask it to refresh.
class CatalogRepository {
  CatalogRepository({
    // Callers write `database:` and `api:`, Dart fills the private fields.
    required this._database,
    required this._api,
    Future<String> Function()? loadCatalogJson,
    DateTime Function()? now,
  }) : _loadCatalogJson =
           loadCatalogJson ??
           (() => rootBundle.loadString('assets/catalog.json')),
       _now = now ?? DateTime.now;

  final AppDatabase _database;
  final MarketDataApi _api;
  final Future<String> Function() _loadCatalogJson;
  final DateTime Function() _now;

  /// Copies assets/catalog.json into the instruments table.
  ///
  /// Done at every launch (30 rows, instant) rather than only the first
  /// time, so a catalogue edited in a new app version is picked up.
  Future<void> seedCatalog() async {
    final list = jsonDecode(await _loadCatalogJson()) as List<dynamic>;
    final rows = <InstrumentsCompanion>[];
    for (var i = 0; i < list.length; i++) {
      final instrument = Instrument.fromJson(list[i] as Map<String, dynamic>);
      rows.add(
        InstrumentsCompanion.insert(
          symbol: instrument.symbol,
          name: instrument.name,
          type: instrument.type.name,
          currency: instrument.currency,
          exchange: Value(instrument.exchange),
          peaEligible: instrument.peaEligible,
          description: instrument.description,
          position: i,
        ),
      );
    }
    await _database.instrumentsDao.upsertAll(rows);
  }

  /// Every asset as stored locally, in catalogue order. No network.
  Future<List<AssetOverview>> loadOverviews() async {
    final instruments = await _database.instrumentsDao.allInstruments();
    final favorites = await _database.favoritesDao.favoriteSymbols();
    final meta = await _database.cacheMetaDao.allMeta();
    return [
      for (final row in instruments)
        await _buildOverview(
          row,
          favorites.contains(row.symbol),
          meta[row.symbol],
        ),
    ];
  }

  Future<AssetOverview?> loadOverview(String symbol) async {
    final row = await _database.instrumentsDao.instrument(symbol);
    if (row == null) return null;
    final favorites = await _database.favoritesDao.favoriteSymbols();
    final meta = await _database.cacheMetaDao.metaFor(symbol);
    return _buildOverview(row, favorites.contains(symbol), meta);
  }

  /// One asset with its whole stored history, for the detail screen.
  /// No network. Null when the symbol is not in the catalogue.
  Future<AssetDetail?> loadDetail(String symbol) async {
    final row = await _database.instrumentsDao.instrument(symbol);
    if (row == null) return null;
    final meta = await _database.cacheMetaDao.metaFor(symbol);
    final candles = await _database.candlesDao.allCandles(symbol);
    return AssetDetail(
      instrument: _toInstrument(row),
      candles: candles.map(_toCandle).toList(),
      logoUrl: _logoOrNull(meta),
      lastFetchedAt: meta?.lastFetchedAt,
    );
  }

  Future<void> setFavorite(String symbol, bool isFavorite) {
    return _database.favoritesDao.setFavorite(symbol, isFavorite);
  }

  /// The cache decision: download only if never fetched, older than
  /// [seriesMaxAge], or when the user forces it (pull-to-refresh).
  static bool needsRefresh(
    DateTime? lastFetchedAt,
    DateTime now, {
    bool force = false,
  }) {
    if (force || lastFetchedAt == null) return true;
    return now.difference(lastFetchedAt) > seriesMaxAge;
  }

  /// Downloads what is missing, step by step, and reports after each one.
  ///
  /// Order: favorites first, then catalogue order; every series before any
  /// logo, because prices matter more than pictures.
  ///
  /// A network, key or quota error stops everything (the next calls would
  /// fail the same way) and is thrown to the caller. A single unknown
  /// symbol is skipped so it does not block the 29 others.
  Stream<RefreshProgress> refreshAll({bool force = false}) async* {
    final symbols = await _symbolsToRefresh(force);
    var done = 0;
    yield RefreshProgress(done: done, total: symbols.length);

    for (final symbol in symbols) {
      try {
        await refreshSeries(symbol);
      } on ApiException catch (e) {
        if (_stopsEverything(e)) rethrow;
      }
      done++;
      yield RefreshProgress(
        done: done,
        total: symbols.length,
        updated: await loadOverview(symbol),
      );
    }

    for (final symbol in await _symbolsWithoutLogoInfo()) {
      try {
        await refreshLogo(symbol);
      } on ApiException catch (e) {
        if (_stopsEverything(e)) rethrow;
        continue;
      }
      yield RefreshProgress(
        done: done,
        total: symbols.length,
        updated: await loadOverview(symbol),
      );
    }
  }

  /// Downloads the series of [symbol], only the missing weeks if possible.
  ///
  /// We overlap on the last *completed* week (the second most recent
  /// candle): the most recent one is the current week, whose close moves
  /// every day and would look like a split.
  Future<void> refreshSeries(String symbol) async {
    final exchange = (await _database.instrumentsDao.instrument(symbol))
        ?.exchange;
    final lastTwo = await _database.candlesDao.lastCandles(symbol, 2);

    if (lastTwo.length < 2) {
      await _downloadFullSeries(symbol, exchange);
    } else {
      final anchor = lastTwo.first;
      final fresh = await _api.fetchWeeklySeries(
        symbol,
        exchange: exchange,
        startDate: anchor.date,
      );
      final overlap = fresh.where((c) => c.date == anchor.date).firstOrNull;
      if (overlap == null || overlapMismatch(anchor.close, overlap.close)) {
        // Split, adjustment, or gap too long: the stored history is wrong.
        await _downloadFullSeries(symbol, exchange);
      } else {
        await _database.candlesDao.upsertCandles(_toRows(symbol, fresh));
      }
    }
    await _database.cacheMetaDao.markFetched(symbol, _now());
  }

  /// Applies the cache decision ([needsRefresh]) to one asset, for the
  /// detail screen. Returns true when the series was downloaded.
  Future<bool> refreshSeriesIfNeeded(
    String symbol, {
    bool force = false,
  }) async {
    final meta = await _database.cacheMetaDao.metaFor(symbol);
    if (!needsRefresh(meta?.lastFetchedAt, _now(), force: force)) return false;
    await refreshSeries(symbol);
    return true;
  }

  /// Asks Twelve Data for the logo once. "No logo" is remembered too.
  Future<void> refreshLogo(String symbol) async {
    final exchange = (await _database.instrumentsDao.instrument(symbol))
        ?.exchange;
    try {
      final url = await _api.fetchLogoUrl(symbol, exchange: exchange);
      await _database.cacheMetaDao.saveLogo(symbol, url);
    } on ApiException catch (e) {
      if (e.kind != ApiErrorKind.notFound) rethrow;
      await _database.cacheMetaDao.saveLogo(symbol, null);
    }
  }

  // --- Private helpers -----------------------------------------------------

  Future<void> _downloadFullSeries(String symbol, String? exchange) async {
    final candles = await _api.fetchWeeklySeries(symbol, exchange: exchange);
    // An empty answer must not erase a history we already have.
    if (candles.isEmpty) return;
    await _database.candlesDao.replaceSeries(symbol, _toRows(symbol, candles));
  }

  Future<List<String>> _symbolsToRefresh(bool force) async {
    final instruments = await _database.instrumentsDao.allInstruments();
    final favorites = await _database.favoritesDao.favoriteSymbols();
    final meta = await _database.cacheMetaDao.allMeta();
    final now = _now();

    final symbols = [
      for (final row in instruments)
        if (needsRefresh(meta[row.symbol]?.lastFetchedAt, now, force: force))
          row.symbol,
    ];
    // Stable sort: favorites move to the front, catalogue order is kept.
    return [
      ...symbols.where(favorites.contains),
      ...symbols.where((s) => !favorites.contains(s)),
    ];
  }

  Future<List<String>> _symbolsWithoutLogoInfo() async {
    final instruments = await _database.instrumentsDao.allInstruments();
    final meta = await _database.cacheMetaDao.allMeta();
    return [
      for (final row in instruments)
        if (meta[row.symbol]?.logoUrl == null) row.symbol,
    ];
  }

  static bool _stopsEverything(ApiException e) =>
      e.kind == ApiErrorKind.network ||
      e.kind == ApiErrorKind.invalidKey ||
      e.kind == ApiErrorKind.rateLimit;

  Future<AssetOverview> _buildOverview(
    InstrumentRow row,
    bool isFavorite,
    CacheMetaRow? meta,
  ) async {
    final candles = await _database.candlesDao.lastCandles(
      row.symbol,
      weeksInOneYear,
    );
    return AssetOverview.fromCandles(
      instrument: _toInstrument(row),
      isFavorite: isFavorite,
      candles: candles.map(_toCandle).toList(),
      logoUrl: _logoOrNull(meta),
      lastFetchedAt: meta?.lastFetchedAt,
    );
  }

  static Instrument _toInstrument(InstrumentRow row) => Instrument(
    symbol: row.symbol,
    name: row.name,
    type: InstrumentType.fromName(row.type),
    currency: row.currency,
    peaEligible: row.peaEligible,
    description: row.description,
    exchange: row.exchange,
  );

  static WeeklyCandle _toCandle(CandleRow row) => WeeklyCandle(
    date: row.date,
    open: row.open,
    high: row.high,
    low: row.low,
    close: row.close,
    volume: row.volume,
  );

  /// The empty-string marker means "no logo" for the UI too.
  static String? _logoOrNull(CacheMetaRow? meta) {
    final url = meta?.logoUrl;
    return (url == null || url.isEmpty) ? null : url;
  }

  static List<WeeklyCandlesCompanion> _toRows(
    String symbol,
    List<WeeklyCandle> candles,
  ) => [
    for (final c in candles)
      WeeklyCandlesCompanion.insert(
        symbol: symbol,
        date: c.date,
        open: c.open,
        high: c.high,
        low: c.low,
        close: c.close,
        volume: Value(c.volume),
      ),
  ];
}

/// True when the same week's close differs by more than
/// [overlapTolerancePercent] between the cache and the API.
bool overlapMismatch(double storedClose, double freshClose) {
  if (storedClose == 0) return freshClose != 0;
  final diffPercent = (freshClose - storedClose).abs() / storedClose * 100;
  return diffPercent > overlapTolerancePercent;
}

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepository(
    database: ref.watch(appDatabaseProvider),
    api: ref.watch(twelveDataClientProvider),
  ),
);
