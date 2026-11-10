import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lucide/core/database/app_database.dart';
import 'package:lucide/core/providers.dart';
import 'package:lucide/core/theme/app_theme.dart';
import 'package:lucide/features/catalog/data/catalog_repository.dart';
import 'package:lucide/features/game/data/game_repository.dart';
import 'package:lucide/features/game/domain/played_game.dart';
import 'package:lucide/features/home/home_screen.dart';
import 'package:lucide/features/simulator/data/simulator_repository.dart';
import 'package:lucide/features/simulator/presentation/simulator_controller.dart';
import 'package:lucide/features/simulator/presentation/simulator_state.dart';
import 'package:segmented_progress_bar/segmented_progress_bar.dart';

import '../../helpers.dart';
import '../simulator/data/simulator_repository_test.dart' show FakeRatesApi;

const _nbsp = ' ';

/// Lets the in-memory database answer. Its futures run outside the fake
/// clock of widget tests, hence runAsync.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

PlayedGame playedGame(int score) => PlayedGame(
  finishedAt: DateTime.utc(2026, 11, 10),
  score: score,
  roundCount: 10,
);

void main() {
  late AppDatabase db;
  late CatalogRepository catalog;
  late SimulatorRepository simulator;
  late FakeGameRepository game;

  /// Tabs the home screen asked to open, in order.
  late List<int> openedTabs;

  setUpAll(() => initializeDateFormatting('fr_FR'));

  setUp(() async {
    db = memoryDatabase();
    catalog = CatalogRepository(
      database: db,
      api: FakeApi(),
      loadCatalogJson: () async => jsonEncode([
        {'symbol': 'SPY', 'name': 'S&P 500', 'type': 'etf', 'currency': 'USD'},
      ]),
    );
    simulator = SimulatorRepository(
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
      now: () => DateTime.utc(2026, 11, 10),
    );
    game = FakeGameRepository(const []);
    openedTabs = [];
    addTearDown(db.close);
  });

  Future<ProviderContainer> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          catalogRepositoryProvider.overrideWithValue(catalog),
          simulatorRepositoryProvider.overrideWithValue(simulator),
          gameRepositoryProvider.overrideWithValue(game),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(body: HomeScreen(onOpenTab: openedTabs.add)),
        ),
      ),
    );
    await settle(tester);
    return ProviderScope.containerOf(tester.element(find.byType(HomeScreen)));
  }

  group('first launch, nothing saved', () {
    testWidgets('each card invites to the tab that fills it', (tester) async {
      await pumpHome(tester);

      expect(find.textContaining('Bienvenue !'), findsOneWidget);
      expect(find.text('Ce que tu aurais vraiment gagné'), findsOneWidget);
      expect(find.textContaining('Ta dernière simulation'), findsNothing);
      expect(
        find.text(
          'Pas encore de partie : devine la suite de 10 vraies courbes.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Faire une simulation'));
      await tester.tap(find.text('Teste ton intuition'));
      expect(openedTabs, [2, 3]);

      // Below the fold: the list builds it once scrolled into view.
      await tester.scrollUntilVisible(
        find.text(
          'Touche l’étoile d’un actif dans le catalogue pour le retrouver ici.',
        ),
        200,
      );
    });
  });

  group('with saved data', () {
    testWidgets('the last simulation and the last game are shown', (
      tester,
    ) async {
      await tester.runAsync(() async {
        // The older one must not be shown.
        await simulator.save(simulationResult(assetName: 'Apple'));
        await db.simulationsDao.insertSimulation(
          SimulationsCompanion.insert(
            symbol: 'SPY',
            assetName: 'S&P 500',
            paramsJson: '{}',
            resultJson: jsonEncode(simulationResult().toJson()),
            createdAt: DateTime.utc(2026, 11, 11),
          ),
        );
      });
      game.played.add(playedGame(6));
      await pumpHome(tester);

      expect(
        find.text('Ta dernière simulation : S&P 500, 1 000$_nbsp€ sur 2 ans'),
        findsOneWidget,
      );
      expect(find.text('+3,7$_nbsp%'), findsOneWidget);
      expect(find.text('gagnés en\npouvoir d’achat'), findsOneWidget);
      expect(
        find.text('pour +20,0$_nbsp% annoncés par le cours'),
        findsOneWidget,
      );
      expect(find.text('Change, frais, impôt, inflation'), findsOneWidget);
      expect(find.text('Ce qu’il reste'), findsOneWidget);
      expect(
        find.text('Dernière partie : 6/10, comme une pièce'),
        findsOneWidget,
      );
      // Something is saved: this is not a first visit.
      expect(find.textContaining('Bienvenue !'), findsNothing);
      expect(find.text('Faire une simulation'), findsNothing);
    });

    testWidgets('only the costs that took something are named', (tester) async {
      // A loss on the price is not taxed, and the change helped.
      await tester.runAsync(
        () => simulator.save(
          simulationResult(gross: 0.10, fx: 0.02, tax: 0, inflation: -0.03),
        ),
      );
      await pumpHome(tester);

      expect(find.text('Frais, inflation'), findsOneWidget);
    });

    testWidgets('nothing left: a sentence instead of the bar', (tester) async {
      await tester.runAsync(
        () => simulator.save(simulationResult(gross: 0.05)),
      );
      await pumpHome(tester);

      // 5 − 5 − 1,5 − 4,5 − 5,3 = −11,3 points.
      expect(find.text('−11,3$_nbsp%'), findsOneWidget);
      expect(find.text('de pouvoir\nd’achat'), findsOneWidget);
      expect(find.byType(SegmentedProgressBar), findsNothing);
      expect(
        find.text(
          'Après change, frais, impôt et inflation, il ne reste rien du gain '
          'annoncé.',
        ),
        findsOneWidget,
      );
    });
  });

  testWidgets('a simulation saved or a game played later shows up at once', (
    tester,
  ) async {
    await pumpHome(tester);
    expect(find.text('Faire une simulation'), findsOneWidget);

    // As if saved from the Simulations tab, and played in the Jeu tab.
    await tester.runAsync(() async {
      await simulator.save(simulationResult());
      await game.saveGame(score: 9, roundCount: 10);
    });
    await settle(tester);

    expect(find.textContaining('Ta dernière simulation'), findsOneWidget);
    expect(
      find.text('Dernière partie : 9/10, mieux qu’une pièce'),
      findsOneWidget,
    );

    // Deleted from the Simulations tab: back to the invitation.
    await tester.runAsync(() async {
      final saved = await simulator.loadSaved();
      await simulator.delete(saved.single.id);
    });
    await settle(tester);
    expect(find.text('Faire une simulation'), findsOneWidget);
  });

  testWidgets('"Voir le détail" opens that simulation, as it was saved', (
    tester,
  ) async {
    final result = simulationResult();
    await tester.runAsync(() => simulator.save(result));
    final container = await pumpHome(tester);

    await tester.tap(find.text('Voir le détail'));
    await settle(tester);

    expect(openedTabs, [2]);
    final state = container.read(simulatorControllerProvider).requireValue;
    expect(state.phase, SimulatorPhase.saved);
    expect(state.animateResult, isFalse);
    expect(state.result!.toJson(), result.toJson());
  });

  testWidgets('real data fits a small phone without overflow', (tester) async {
    // The real font: the test font is much wider and would overflow where
    // a phone does not.
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

    await tester.runAsync(
      () => simulator.save(
        simulationResult(
          assetName: 'iShares Core MSCI World UCITS ETF',
          amount: 12500,
          buyDay: DateTime.utc(2021, 1, 4),
          sellDay: DateTime.utc(2025, 8, 29),
        ),
      ),
    );
    game.played.add(playedGame(10));
    await pumpHome(tester);

    expect(find.textContaining('4 ans et 7 mois'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
