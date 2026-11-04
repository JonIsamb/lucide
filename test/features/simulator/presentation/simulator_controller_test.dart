import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/core/database/app_database.dart';
import 'package:lucide/features/catalog/data/catalog_repository.dart';
import 'package:lucide/features/simulator/data/simulator_repository.dart';
import 'package:lucide/features/simulator/domain/simulation_error.dart';
import 'package:lucide/features/simulator/domain/simulation_params.dart';
import 'package:lucide/features/simulator/presentation/simulator_controller.dart';
import 'package:lucide/features/simulator/presentation/simulator_state.dart';

import '../../../helpers.dart';
import '../data/simulator_repository_test.dart' show FakeRatesApi;

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final catalog = CatalogRepository(
      database: db,
      api: FakeApi(),
      loadCatalogJson: () async => jsonEncode([
        {
          'symbol': 'KO',
          'name': 'Coca-Cola',
          'type': 'stock',
          'currency': 'EUR',
        },
        {'symbol': 'AAPL', 'name': 'Apple', 'type': 'stock', 'currency': 'USD'},
      ]),
    );
    await catalog.seedCatalog();
    await db.candlesDao.upsertCandles([
      for (var i = 0; i < 10; i++)
        WeeklyCandlesCompanion.insert(
          symbol: 'KO',
          date: DateTime.utc(2025, 1, 6 + 7 * i),
          open: 100,
          high: 100,
          low: 100,
          close: 100.0 + i,
          volume: const Value(null),
        ),
    ]);
    final repository = SimulatorRepository(
      database: db,
      catalog: catalog,
      api: FakeRatesApi(),
      loadAsset: (path) async => path == SimulatorRepository.fxSeedAsset
          ? jsonEncode([
              ['2025-01-02', 1.1],
            ])
          : jsonEncode([
              [2024, 2.0],
            ]),
      now: () => DateTime.utc(2025, 3, 20),
    );
    container = ProviderContainer(
      overrides: [simulatorRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
  });

  Future<SimulatorController> start() async {
    await container.read(simulatorControllerProvider.future);
    return container.read(simulatorControllerProvider.notifier);
  }

  SimulatorState state() => container.read(simulatorControllerProvider).value!;

  test('starts unconfigured, with the catalogue loaded', () async {
    await start();
    expect(state().phase, SimulatorPhase.unconfigured);
    expect(state().instruments, hasLength(2));
  });

  test('computing without an asset is refused', () async {
    final controller = await start();
    controller.compute();
    expect(state().phase, SimulatorPhase.invalid);
    expect(state().error, SimulationError.noAsset);
  });

  test('choosing an asset proposes dates inside its history', () async {
    final controller = await start();
    await controller.selectAsset(state().instruments.first);
    expect(state().sellDay, DateTime.utc(2025, 3, 10 + 6));
    expect(state().buyDay, DateTime.utc(2025, 1, 6));
  });

  test('a filled form gives a computed result, then it can be saved', () async {
    final controller = await start();
    await controller.selectAsset(state().instruments.first);
    controller.setAmountText('1 000,50');
    controller.compute();
    expect(state().phase, SimulatorPhase.computed);
    expect(state().result!.params.amount, 1000.5);

    await controller.save();
    expect(state().phase, SimulatorPhase.saved);
    expect(state().saved, hasLength(1));

    controller.backToForm();
    expect(state().phase, SimulatorPhase.unconfigured);
    expect(state().asset, isNotNull, reason: 'the form keeps its values');
    expect(state().amount, 1000.5);
  });

  test(
    'a saved simulation is shown without recomputing or animating',
    () async {
      final controller = await start();
      await controller.selectAsset(state().instruments.first);
      controller.setAmountText('1000');
      controller.compute();
      await controller.save();
      final frozen = state().saved.single;
      controller.backToForm();

      controller.openSaved(frozen);
      expect(state().result, same(frozen.result));
      expect(state().animateResult, isFalse);
      expect(state().phase, SimulatorPhase.saved);
    },
  );

  test('deleting a saved simulation removes it', () async {
    final controller = await start();
    await controller.selectAsset(state().instruments.first);
    controller.setAmountText('1000');
    controller.compute();
    await controller.save();
    await controller.deleteSaved(state().saved.single.id);
    expect(state().saved, isEmpty);
    expect(state().phase, SimulatorPhase.computed);
  });

  test('PEA on a non eligible asset is refused with the reason', () async {
    final controller = await start();
    await controller.selectAsset(state().instruments.first);
    controller.setAmountText('1000');
    controller.setEnvelope(Envelope.pea);
    expect(state().peaRefused, isTrue);
    controller.compute();
    expect(state().error, SimulationError.peaNotEligible);
  });

  test('unreadable amount or fee is refused', () async {
    final controller = await start();
    await controller.selectAsset(state().instruments.first);
    controller.setAmountText('abc');
    controller.compute();
    expect(state().error, SimulationError.amountNotPositive);

    controller.setAmountText('100');
    controller.setBrokerageText('x');
    controller.compute();
    expect(state().error, SimulationError.brokerageOutOfRange);
  });

  test(
    'a dollar asset with an empty price history reports no prices',
    () async {
      final controller = await start();
      await controller.selectAsset(state().instruments.last);
      controller.setAmountText('100');
      controller.compute();
      expect(state().error, SimulationError.noPrices);
    },
  );
}
