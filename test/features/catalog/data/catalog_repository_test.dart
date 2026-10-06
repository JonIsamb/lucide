import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/core/database/app_database.dart';
import 'package:lucide/core/network/api_exception.dart';
import 'package:lucide/features/catalog/data/catalog_repository.dart';

import '../../../helpers.dart';

const catalogJson = [
  {'symbol': 'AAPL', 'name': 'Apple', 'type': 'stock', 'currency': 'USD'},
  {'symbol': 'SPY', 'name': 'S&P 500', 'type': 'etf', 'currency': 'USD'},
  {'symbol': 'BTC/EUR', 'name': 'Bitcoin', 'type': 'crypto', 'currency': 'EUR'},
];

void main() {
  late AppDatabase db;
  late FakeApi api;
  late DateTime now;
  late CatalogRepository repository;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    api = FakeApi();
    now = DateTime.utc(2026, 10, 6, 12);
    repository = CatalogRepository(
      database: db,
      api: api,
      loadCatalogJson: () async => jsonEncode(catalogJson),
      now: () => now,
    );
    await repository.seedCatalog();
    for (final s in ['AAPL', 'SPY', 'BTC/EUR']) {
      api.series[s] = weeklySeries([100, 110, 120]);
    }
  });

  tearDown(() => db.close());

  Future<List<RefreshProgress>> refresh({bool force = false}) =>
      repository.refreshAll(force: force).toList();

  group('needsRefresh', () {
    final t = DateTime.utc(2026, 10, 6, 12);

    test('never fetched', () {
      expect(CatalogRepository.needsRefresh(null, t), isTrue);
    });

    test('fresh data is kept', () {
      final fetched = t.subtract(const Duration(hours: 5, minutes: 59));
      expect(CatalogRepository.needsRefresh(fetched, t), isFalse);
    });

    test('older than 6 hours', () {
      final fetched = t.subtract(const Duration(hours: 6, minutes: 1));
      expect(CatalogRepository.needsRefresh(fetched, t), isTrue);
    });

    test('forced by pull-to-refresh', () {
      expect(CatalogRepository.needsRefresh(t, t, force: true), isTrue);
    });
  });

  test('the seeded catalogue is readable offline, without prices', () async {
    final overviews = await repository.loadOverviews();
    expect(overviews.map((o) => o.symbol), ['AAPL', 'SPY', 'BTC/EUR']);
    expect(overviews.every((o) => !o.hasPrice), isTrue);
    expect(api.seriesCalls, isEmpty);
  });

  test(
    'first launch: full download, favorites first, series before logos',
    () async {
      await repository.setFavorite('BTC/EUR', true);
      api.logos['AAPL'] = 'https://logo/aapl.png';

      final progress = await refresh();

      expect(api.seriesCalls, [
        ('BTC/EUR', null),
        ('AAPL', null),
        ('SPY', null),
      ]);
      expect(api.logoCalls, ['AAPL', 'SPY', 'BTC/EUR']);
      expect(progress.first.done, 0);
      expect(progress[3].done, 3);
      expect(progress[3].total, 3);

      final aapl = (await repository.loadOverview('AAPL'))!;
      expect(aapl.lastPrice, 120);
      expect(aapl.yearlyChange, 20);
      expect(aapl.logoUrl, 'https://logo/aapl.png');
      expect(aapl.lastFetchedAt, now);
    },
  );

  test('a fresh cache makes no call at all', () async {
    await refresh();
    api.seriesCalls.clear();
    api.logoCalls.clear();

    now = now.add(const Duration(hours: 2));
    await refresh();

    expect(api.seriesCalls, isEmpty);
    expect(api.logoCalls, isEmpty, reason: 'logos are fetched only once');
  });

  test(
    'stale cache: only the missing weeks, from the last completed week',
    () async {
      await refresh();
      api.seriesCalls.clear();

      // One more week happened: the last one changed and a new one appeared.
      api.series['AAPL'] = weeklySeries([100, 110, 120.5, 130]);
      now = now.add(const Duration(days: 7));
      await refresh();

      // Overlap on the second most recent stored candle (week 2).
      expect(api.seriesCalls.where((c) => c.$1 == 'AAPL'), [
        ('AAPL', DateTime.utc(2025, 10, 13)),
      ]);
      final candles = await db.candlesDao.allCandles('AAPL');
      expect(candles.map((c) => c.close), [100, 110, 120.5, 130]);
    },
  );

  test('overlap differs by more than 1 %: split, full reload', () async {
    await refresh();
    api.seriesCalls.clear();

    // A 2-for-1 split: Twelve Data now sends every past price halved.
    api.series['AAPL'] = weeklySeries([50, 55, 60, 65]);
    now = now.add(const Duration(days: 7));
    await refresh();

    expect(api.seriesCalls.where((c) => c.$1 == 'AAPL'), [
      ('AAPL', DateTime.utc(2025, 10, 13)),
      ('AAPL', null),
    ]);
    final candles = await db.candlesDao.allCandles('AAPL');
    expect(candles.map((c) => c.close), [50, 55, 60, 65]);
  });

  test('a missing logo is remembered and never asked again', () async {
    await refresh();
    final meta = await db.cacheMetaDao.metaFor('SPY');
    expect(meta!.logoUrl, '');
    expect((await repository.loadOverview('SPY'))!.logoUrl, isNull);

    api.logoCalls.clear();
    await refresh(force: true);
    expect(api.logoCalls, isEmpty);
  });

  test('network error stops the refresh and keeps the cache', () async {
    await refresh();
    api.errors['AAPL'] = const ApiException(ApiErrorKind.network);

    await expectLater(refresh(force: true), throwsA(isA<ApiException>()));
    expect((await repository.loadOverview('AAPL'))!.lastPrice, 120);
    // The failed asset keeps its old fetch time.
    expect((await repository.loadOverview('AAPL'))!.lastFetchedAt, now);
  });

  test('one unknown symbol is skipped, the others still load', () async {
    api.errors['AAPL'] = const ApiException(ApiErrorKind.notFound);

    final progress = await refresh();

    expect(progress.last.done, 3);
    expect((await repository.loadOverview('AAPL'))!.hasPrice, isFalse);
    expect((await repository.loadOverview('SPY'))!.hasPrice, isTrue);
  });

  test('overlapMismatch', () {
    expect(overlapMismatch(100, 100.9), isFalse);
    expect(overlapMismatch(100, 101.1), isTrue);
    expect(overlapMismatch(100, 50), isTrue);
  });
}
