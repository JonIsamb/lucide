import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/core/database/app_database.dart';

import '../../helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  WeeklyCandlesCompanion row(DateTime date, double close) =>
      WeeklyCandlesCompanion.insert(
        symbol: 'AAPL',
        date: date,
        open: close,
        high: close,
        low: close,
        close: close,
        volume: const Value(null),
      );

  test('candle dates come back as the same UTC day', () async {
    await db.candlesDao.upsertCandles([row(DateTime.utc(2026, 10, 5), 1)]);
    final candles = await db.candlesDao.allCandles('AAPL');
    expect(candles.single.date, DateTime.utc(2026, 10, 5));
    expect(candles.single.date.isUtc, isTrue);
  });

  test('upsert replaces the candle of the same week', () async {
    await db.candlesDao.upsertCandles([
      row(DateTime.utc(2026, 9, 28), 1),
      row(DateTime.utc(2026, 10, 5), 2),
    ]);
    await db.candlesDao.upsertCandles([row(DateTime.utc(2026, 10, 5), 3)]);

    final last = await db.candlesDao.lastCandles('AAPL', 1);
    expect(last.single.close, 3);
    expect((await db.candlesDao.allCandles('AAPL')).length, 2);
  });

  test('fetch time and logo are saved independently', () async {
    final at = DateTime.utc(2026, 10, 5, 20);
    await db.cacheMetaDao.saveLogo('AAPL', 'https://logo');
    await db.cacheMetaDao.markFetched('AAPL', at);
    await db.cacheMetaDao.saveLogo('BTC/EUR', null);

    final meta = await db.cacheMetaDao.allMeta();
    expect(meta['AAPL']!.logoUrl, 'https://logo');
    expect(meta['AAPL']!.lastFetchedAt, at);
    expect(meta['BTC/EUR']!.logoUrl, '', reason: 'empty means "no logo"');
    expect(meta['BTC/EUR']!.lastFetchedAt, isNull);
  });

  test('favorites can be added and removed', () async {
    await db.favoritesDao.setFavorite('AAPL', true);
    await db.favoritesDao.setFavorite('SPY', true);
    await db.favoritesDao.setFavorite('AAPL', false);
    expect(await db.favoritesDao.favoriteSymbols(), {'SPY'});
  });

  test('finished games come newest first, and again after a new one', () async {
    final scores = <List<int>>[];
    final subscription = db.gameSessionsDao.watchSessions().listen(
      (rows) => scores.add([for (final row in rows) row.score]),
    );
    addTearDown(subscription.cancel);

    Future<void> insert(int score, DateTime at) =>
        db.gameSessionsDao.insertSession(
          GameSessionsCompanion.insert(
            finishedAt: at,
            score: score,
            roundCount: 10,
          ),
        );

    await waitUntil(() => scores.isNotEmpty);
    await insert(4, DateTime.utc(2026, 11, 9));
    await waitUntil(() => scores.length >= 2);
    await insert(7, DateTime.utc(2026, 11, 10));
    await waitUntil(() => scores.length >= 3);

    expect(scores, [
      <int>[],
      [4],
      [7, 4],
    ]);
  });

  test('upgrading from version 2 adds the games, keeps simulations', () async {
    final dir = await Directory.systemTemp.createTemp('lucide_migration');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/lucide.sqlite');

    // A phone still on version 2: one saved simulation, no games table.
    final old = AppDatabase(NativeDatabase(file));
    await old.simulationsDao.insertSimulation(
      SimulationsCompanion.insert(
        symbol: 'SPY',
        assetName: 'S&P 500',
        paramsJson: '{}',
        resultJson: '{}',
        createdAt: DateTime.utc(2026, 11, 1),
      ),
    );
    await old.customStatement('DROP TABLE game_sessions');
    await old.customStatement('PRAGMA user_version = 2');
    await old.close();

    final upgraded = AppDatabase(NativeDatabase(file));
    addTearDown(upgraded.close);
    expect(
      (await upgraded.simulationsDao.allSimulations()).single.assetName,
      'S&P 500',
    );
    await upgraded.gameSessionsDao.insertSession(
      GameSessionsCompanion.insert(
        finishedAt: DateTime.utc(2026, 11, 10),
        score: 6,
        roundCount: 10,
      ),
    );
    expect(
      (await upgraded.gameSessionsDao.watchSessions().first).single.score,
      6,
    );
  });
}
