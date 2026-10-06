import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/core/database/app_database.dart';

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
}
