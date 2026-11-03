import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/core/database/app_database.dart';
import 'package:lucide/core/network/api_exception.dart';
import 'package:lucide/features/catalog/data/catalog_repository.dart';
import 'package:lucide/features/simulator/data/rates_api.dart';
import 'package:lucide/features/simulator/data/simulator_repository.dart';
import 'package:lucide/features/simulator/domain/run_simulation.dart';
import 'package:lucide/features/simulator/domain/simulation_params.dart';
import 'package:lucide/features/simulator/domain/simulation_result.dart';

import '../../../helpers.dart';

class FakeRatesApi implements RatesApi {
  List<FxRate> fx = [];
  Map<int, double> inflation = {};
  ApiException? error;
  final fxCalls = <DateTime>[];
  int inflationCalls = 0;

  @override
  Future<List<FxRate>> fetchFxRates({required DateTime from}) async {
    fxCalls.add(from);
    if (error case final e?) throw e;
    return fx;
  }

  @override
  Future<Map<int, double>> fetchInflation({required int fromYear}) async {
    inflationCalls++;
    if (error case final e?) throw e;
    return inflation;
  }
}

void main() {
  late AppDatabase db;
  late FakeRatesApi api;
  late DateTime now;
  late SimulatorRepository repository;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    api = FakeRatesApi();
    now = DateTime.utc(2026, 11, 3);
    final assets = {
      SimulatorRepository.fxSeedAsset: jsonEncode([
        ['2026-11-02', 1.12],
        ['2026-10-30', 1.15],
      ]),
      SimulatorRepository.inflationSeedAsset: jsonEncode([
        [2024, 2.0],
        [2025, 0.9],
      ]),
    };
    repository = SimulatorRepository(
      database: db,
      catalog: CatalogRepository(database: db, api: FakeApi()),
      api: api,
      loadAsset: (path) async => assets[path]!,
      now: () => now,
    );
  });

  tearDown(() => db.close());

  test('the seed fills empty tables, sorted by day', () async {
    await repository.seedIfEmpty();
    final fx = await repository.loadFxRates();
    expect(fx.map((r) => r.eurUsd), [1.15, 1.12]);
    expect(fx.first.day, DateTime.utc(2026, 10, 30));
    expect(await repository.loadInflation(), {2024: 2.0, 2025: 0.9});
  });

  test('the seed does not overwrite data already there', () async {
    await repository.seedIfEmpty();
    await db.fxRatesDao.upsertAll([
      FxRatesCompanion.insert(day: '2026-11-02', eurUsd: 9),
    ]);
    await repository.seedIfEmpty();
    expect((await repository.loadFxRates()).last.eurUsd, 9);
  });

  group('refreshRates', () {
    test('up to date data: no request', () async {
      await repository.seedIfEmpty();
      expect(await repository.refreshRates(), isFalse);
      expect(api.fxCalls, isEmpty);
      expect(api.inflationCalls, 0);
    });

    test('old rates: asks from the last stored day', () async {
      await repository.seedIfEmpty();
      now = DateTime.utc(2026, 11, 20);
      api.fx = [FxRate(DateTime.utc(2026, 11, 19), 1.2)];
      expect(await repository.refreshRates(), isTrue);
      expect(api.fxCalls.single, DateTime.utc(2026, 11, 2));
      expect((await repository.loadFxRates()).last.eurUsd, 1.2);
    });

    test('a network error leaves the stored data untouched', () async {
      await repository.seedIfEmpty();
      now = DateTime.utc(2026, 11, 20);
      api.error = const ApiException(ApiErrorKind.network);
      await expectLater(
        repository.refreshRates(),
        throwsA(isA<ApiException>()),
      );
      expect(await repository.loadFxRates(), hasLength(2));
    });

    test('missing recent inflation year is requested', () async {
      await repository.seedIfEmpty();
      now = DateTime.utc(2027, 3, 1);
      api.fx = [FxRate(DateTime.utc(2027, 2, 27), 1.1)];
      api.inflation = {2026: 1.5};
      await repository.refreshRates();
      expect((await repository.loadInflation())[2026], 1.5);
    });
  });

  group('saved simulations', () {
    SimulationResult result(double amount) {
      final outcome = runSimulation(
        params: SimulationParams(
          symbol: 'AAPL',
          assetName: 'Apple',
          assetType: instrument('AAPL').type,
          currency: 'EUR',
          peaEligible: false,
          amount: amount,
          buyDay: DateTime.utc(2025, 10, 6),
          sellDay: DateTime.utc(2025, 10, 20),
          envelope: Envelope.securitiesAccount,
        ),
        candles: weeklySeries([100, 110, 120]),
        fxRates: const [],
        inflationPercent: const {2025: 1.0},
      );
      return outcome.result!;
    }

    test('saved result is read back identical, newest first', () async {
      final first = result(1000);
      await repository.save(first);
      now = now.add(const Duration(minutes: 1));
      await repository.save(result(500));

      final saved = await repository.loadSaved();
      expect(saved.map((s) => s.result.params.amount), [500, 1000]);
      expect(saved.last.result.toJson(), first.toJson());
    });

    test('delete removes only that row', () async {
      final a = await repository.save(result(1000));
      await repository.save(result(500));
      await repository.delete(a.id);
      expect((await repository.loadSaved()).single.result.params.amount, 500);
    });

    test('an unreadable row is skipped', () async {
      await repository.save(result(1000));
      await db.simulationsDao.insertSimulation(
        SimulationsCompanion.insert(
          symbol: 'X',
          assetName: 'X',
          paramsJson: '{}',
          resultJson: 'not json',
          createdAt: now,
        ),
      );
      expect(await repository.loadSaved(), hasLength(1));
    });
  });
}
