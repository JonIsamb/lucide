import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lucide/core/database/app_database.dart';
import 'package:lucide/app.dart';
import 'package:lucide/core/theme/app_theme.dart';
import 'package:lucide/core/widgets/glass_nav_bar.dart';
import 'package:lucide/features/catalog/data/catalog_repository.dart';
import 'package:lucide/features/simulator/data/simulator_repository.dart';
import 'package:lucide/features/simulator/simulator_screen.dart';

import '../../../helpers.dart';
import '../data/simulator_repository_test.dart' show FakeRatesApi;

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  testWidgets('empty form: calculating explains what is missing', (
    tester,
  ) async {
    // A tall screen shows the whole form without scrolling.
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final catalog = CatalogRepository(
      database: db,
      api: FakeApi(),
      loadCatalogJson: () async => jsonEncode([
        {
          'symbol': 'KO',
          'name': 'Coca-Cola',
          'type': 'stock',
          'currency': 'USD',
        },
      ]),
    );
    await catalog.seedCatalog();
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
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [simulatorRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: SimulatorScreen()),
        ),
      ),
    );
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }

    expect(find.text('Choisir un actif'), findsOneWidget);
    final button = find.text('Calculer ce que j’aurais vraiment gagné');
    await tester.tap(button);
    await tester.pump();
    expect(find.text('Choisis un actif.'), findsOneWidget);
  });

  testWidgets('compute button stays clickable above the glass bar', (
    tester,
  ) async {
    // A small phone: the form must scroll, not hide under the bar.
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final catalog = CatalogRepository(
      database: db,
      api: FakeApi(),
      loadCatalogJson: () async => jsonEncode([
        {
          'symbol': 'KO',
          'name': 'Coca-Cola',
          'type': 'stock',
          'currency': 'USD',
        },
      ]),
    );
    await catalog.seedCatalog();
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
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogRepositoryProvider.overrideWithValue(catalog),
          simulatorRepositoryProvider.overrideWithValue(repository),
        ],
        child: const LucideApp(),
      ),
    );
    await tester.tap(find.text('Simulations'));
    for (var i = 0; i < 8; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }

    final button = find.text('Calculer ce que j’aurais vraiment gagné');
    await tester.ensureVisible(button);
    await tester.pump();
    final center = tester.getCenter(button);
    expect(center.dy, lessThan(tester.getRect(find.byType(GlassNavBar)).top));
    // Nothing (the bar) may cover the button: it is part of the hit path.
    final hit = tester.hitTestOnBinding(center).path.map((e) => e.target);
    expect(hit, contains(tester.renderObject(button)));
  });
}
