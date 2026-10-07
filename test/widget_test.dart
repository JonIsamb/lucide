import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lucide/app.dart';
import 'package:lucide/core/database/app_database.dart';
import 'package:lucide/core/network/api_exception.dart';
import 'package:lucide/core/theme/app_theme.dart';
import 'package:lucide/features/asset_detail/asset_detail_screen.dart';
import 'package:lucide/features/catalog/data/catalog_repository.dart';

import 'helpers.dart';

/// Lets the database and the fake API finish their work. They run on real
/// futures, outside the fake clock of widget tests, hence runAsync.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

void main() {
  late AppDatabase db;
  late FakeApi api;

  // Read from disk: rootBundle caches its first future, and reusing it in
  // a later widget test (another fake clock) never completes.
  late String catalogJson;

  setUpAll(() async {
    await initializeDateFormatting('fr_FR');
    catalogJson = await File('assets/catalog.json').readAsString();
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    api = FakeApi()
      ..series['AAPL'] = weeklySeries([100, 122.3])
      ..series['INTC'] = weeklySeries([40, 21.76]);
  });

  tearDown(() => db.close());

  /// The whole app, with the real catalog.json, an in-memory database and
  /// a fake API (no network, no rate limiter).
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogRepositoryProvider.overrideWithValue(
            CatalogRepository(
              database: db,
              api: api,
              loadCatalogJson: () async => catalogJson,
            ),
          ),
        ],
        child: const LucideApp(),
      ),
    );
    await settle(tester);
  }

  testWidgets('the shell shows the 4 tabs and switches between them', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Accueil'), findsOneWidget);
    expect(find.text('Simulations'), findsOneWidget);

    await tester.tap(find.text('Jeu'));
    await tester.pumpAndSettle();
    expect(find.text('Manche 1 sur 20'), findsOneWidget);
  });

  testWidgets('catalogue shows prices and changes in French', (tester) async {
    await pumpApp(tester);

    expect(find.text('30 actifs'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Action, 122,30 \$'), findsOneWidget);
    expect(find.text('+22,3 %'), findsOneWidget);
  });

  testWidgets('search without result offers to clear it', (tester) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('Aucun actif ne correspond à « zzz »'), findsOneWidget);

    await tester.tap(find.text('Effacer la recherche'));
    await tester.pumpAndSettle();
    expect(find.text('30 actifs'), findsOneWidget);
  });

  testWidgets('type filter and favorite star', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Cryptos'));
    await tester.pumpAndSettle();
    expect(find.text('5 actifs'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Ajouter Bitcoin aux favoris'));
    await tester.pumpAndSettle();
    expect(
      find.bySemanticsLabel('Retirer Bitcoin des favoris'),
      findsOneWidget,
    );
    await settle(tester);
    expect(await db.favoritesDao.favoriteSymbols(), {'BTC/EUR'});
  });

  testWidgets('tapping a row opens the detail screen', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Apple'));
    await settle(tester);

    expect(find.byType(AssetDetailScreen), findsOneWidget);
    expect(find.text('Action, AAPL'), findsOneWidget);
    expect(find.text('Non éligible PEA'), findsOneWidget);
    expect(find.text('122,30\u00a0\$'), findsWidgets);
    expect(find.text('+22,3\u00a0% sur 1 an'), findsOneWidget);

    // The lower cards are built once scrolled into view.
    final list = find.descendant(
      of: find.byType(AssetDetailScreen),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.text('Baisse maximale'),
      200,
      scrollable: list,
    );
    expect(find.text('Variation'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Pire semaine'),
      200,
      scrollable: list,
    );
    expect(find.text('Ce que j’aurais vraiment gagné'), findsOneWidget);
  });

  testWidgets('detail: period and favorite star', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Apple'));
    await settle(tester);

    await tester.tap(find.text('1 mois'));
    await tester.pumpAndSettle();
    expect(find.text('+22,3\u00a0% sur 1 mois'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Ajouter Apple aux favoris'));
    await settle(tester);
    expect(await db.favoritesDao.favoriteSymbols(), {'AAPL'});

    // Back in the catalogue, the row shows the same star.
    await tester.tap(find.byTooltip('Retour au catalogue'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Retirer Apple des favoris'), findsOneWidget);
  });

  testWidgets('detail fits a small phone without overflow', (tester) async {
    // The real font: the test font is much wider and would overflow
    // where a phone does not.
    await tester.runAsync(() async {
      final loader = FontLoader('Nunito');
      for (final weight in ['Regular', 'SemiBold', 'Bold', 'ExtraBold']) {
        final bytes = await File('assets/fonts/Nunito-$weight.ttf')
            .readAsBytes();
        loader.addFont(Future.value(ByteData.sublistView(bytes)));
      }
      await loader.load();
    });
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // A long, bumpy series: every card has something to show.
    final repository = CatalogRepository(
      database: db,
      api: api,
      loadCatalogJson: () async => catalogJson,
    );
    api.series['BTC/EUR'] = weeklySeries([
      for (var i = 0; i < 80; i++) 98000 + 4000.0 * ((i * 7) % 11) - 150 * i,
    ]);
    await tester.runAsync(() async {
      await repository.seedCatalog();
      await repository.refreshSeries('BTC/EUR');
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [catalogRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const AssetDetailScreen(symbol: 'BTC/EUR'),
        ),
      ),
    );
    await settle(tester);

    expect(find.text('Bitcoin'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Semaines observées'),
      200,
      scrollable: find.byType(Scrollable),
    );
    // An overflow would have been reported as an exception.
    expect(tester.takeException(), isNull);
  });

  testWidgets('offline on first launch: error and retry button', (
    tester,
  ) async {
    for (final symbol in ['SPY', 'AAPL', 'BTC/EUR']) {
      api.errors[symbol] = const ApiException(ApiErrorKind.network);
    }
    await pumpApp(tester);

    expect(find.text('Impossible de charger les cours'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
  });
}
