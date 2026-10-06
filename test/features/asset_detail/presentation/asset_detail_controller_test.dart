import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/core/database/app_database.dart';
import 'package:lucide/core/network/api_exception.dart';
import 'package:lucide/features/asset_detail/domain/chart_period.dart';
import 'package:lucide/features/asset_detail/presentation/asset_detail_controller.dart';
import 'package:lucide/features/asset_detail/presentation/asset_detail_state.dart';
import 'package:lucide/features/catalog/data/catalog_repository.dart';

import '../../../helpers.dart';

const catalogJson = [
  {'symbol': 'AAPL', 'name': 'Apple', 'type': 'stock', 'currency': 'USD'},
];

void main() {
  late AppDatabase db;
  late FakeApi api;
  late DateTime now;
  late CatalogRepository repository;
  late ProviderContainer container;

  final provider = assetDetailControllerProvider('AAPL');

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    api = FakeApi()..series['AAPL'] = weeklySeries([100, 110, 120]);
    now = DateTime.utc(2026, 10, 6, 12);
    repository = CatalogRepository(
      database: db,
      api: api,
      loadCatalogJson: () async => jsonEncode(catalogJson),
      now: () => now,
    );
    await repository.seedCatalog();
    container = ProviderContainer(
      overrides: [catalogRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// Opens the screen's provider and waits until its refresh is over.
  Future<AsyncValue<AssetDetailState>> open() async {
    // A listener keeps the autoDispose provider alive, like the screen.
    container.listen(provider, (_, _) {});
    for (var i = 0; i < 200; i++) {
      final state = container.read(provider);
      final settled = switch (state) {
        AsyncData(:final value) => !value.isRefreshing,
        AsyncError() => true,
        _ => false,
      };
      // The refresh starts in a microtask after build(): look twice.
      if (settled && i > 2) return state;
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    fail('The detail never settled');
  }

  test('never downloaded: the series is fetched, then shown', () async {
    final state = (await open()).requireValue;

    expect(api.seriesCalls, hasLength(1));
    expect(state.detail.candles, hasLength(3));
    expect(state.detail.lastPrice, 120);
    expect(state.detail.lastFetchedAt, now);
    expect(state.refreshError, isNull);
    expect(state.period, ChartPeriod.oneYear);
  });

  test('fresh cache: shown without any network call', () async {
    await repository.refreshSeries('AAPL');
    api.seriesCalls.clear();
    now = now.add(const Duration(hours: 1));

    final state = (await open()).requireValue;

    expect(api.seriesCalls, isEmpty);
    expect(state.detail.candles, hasLength(3));
  });

  test('old cache: only the missing weeks are requested', () async {
    await repository.refreshSeries('AAPL');
    api.seriesCalls.clear();
    api.series['AAPL'] = weeklySeries([100, 110, 120, 130]);
    now = now.add(const Duration(hours: 7));

    final state = (await open()).requireValue;

    expect(api.seriesCalls.single.$2, isNotNull);
    expect(state.detail.candles, hasLength(4));
    expect(state.detail.lastPrice, 130);
  });

  test('error with cache: data kept, error exposed', () async {
    await repository.refreshSeries('AAPL');
    now = now.add(const Duration(hours: 7));
    api.errors['AAPL'] = const ApiException(ApiErrorKind.network);

    final state = (await open()).requireValue;

    expect(state.detail.candles, hasLength(3));
    expect(state.refreshError?.kind, ApiErrorKind.network);
    expect(state.isRefreshing, isFalse);
  });

  test('error without data: AsyncError', () async {
    api.errors['AAPL'] = const ApiException(ApiErrorKind.network);

    final state = await open();

    expect(state, isA<AsyncError<AssetDetailState>>());
    expect((state.error as ApiException).kind, ApiErrorKind.network);
  });

  test('unknown symbol: not found, without calling the API', () async {
    final unknown = assetDetailControllerProvider('NOPE');
    container.listen(unknown, (_, _) {});
    await expectLater(
      container.read(unknown.future),
      throwsA(
        isA<ApiException>().having(
          (e) => e.kind,
          'kind',
          ApiErrorKind.notFound,
        ),
      ),
    );
    expect(api.seriesCalls, isEmpty);
  });

  test('changing the period makes no network call', () async {
    await open();
    api.seriesCalls.clear();

    container.read(provider.notifier).setPeriod(ChartPeriod.oneMonth);

    final state = container.read(provider).requireValue;
    expect(state.period, ChartPeriod.oneMonth);
    expect(api.seriesCalls, isEmpty);
  });

  test('forced refresh downloads again even when fresh', () async {
    await open();
    api.seriesCalls.clear();

    await container.read(provider.notifier).refresh(force: true);

    expect(api.seriesCalls, hasLength(1));
    expect(container.read(provider).requireValue.isRefreshing, isFalse);
  });

  test('state derives the indicators of the selected period', () async {
    final state = (await open()).requireValue;

    expect(state.periodCandles, hasLength(3));
    expect(state.stats.changePercent, closeTo(20, 1e-9));
    expect(state.chartPoints, [0, 0.5, 1]);
    expect(state.changeByPeriod[ChartPeriod.fiveYears], closeTo(20, 1e-9));
  });
}
