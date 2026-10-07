import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lucide/core/theme/app_theme.dart';
import 'package:lucide/features/game/domain/game_round.dart';
import 'package:lucide/features/game/presentation/game_screen.dart';
import 'package:lucide/features/game/presentation/sample_rounds.dart';

/// 26 visible weeks going from 100 to 106, then 4 hidden weeks ending
/// 6,2 % lower (the example of the mockup) or 5 % higher.
GameRound round({required bool rises}) {
  final history = [for (var i = 0; i < 26; i++) 100 + i * 6 / 25];
  final last = rises ? 106 * 1.05 : 106 * (1 - 0.062);
  return GameRound(
    assetName: 'Coca-Cola',
    history: history,
    future: [106, 105, 104, last],
    start: DateTime.utc(2019, 3, 4),
    end: DateTime.utc(2019, 10, 21),
  );
}

/// Finds a text whatever kind of space it uses: percentages are written
/// with a no-break space before "%".
Finder findPlainText(String text) => find.byWidgetPredicate(
  (widget) =>
      widget is Text &&
      widget.data?.replaceAll('\u00A0', ' ').replaceAll('\u202F', ' ') == text,
);

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  var wentHome = false;

  Future<void> pumpGame(
    WidgetTester tester,
    List<GameRound> rounds, {
    Size? size,
  }) async {
    wentHome = false;
    if (size != null) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }
    await tester.pumpWidget(
      ProviderScope(
        overrides: [gameRoundsProvider.overrideWithValue(rounds)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(body: GameScreen(onGoHome: () => wentHome = true)),
        ),
      ),
    );
  }

  testWidgets('a round shows the question, both answers and no asset name', (
    tester,
  ) async {
    await pumpGame(tester, [round(rises: false), round(rises: true)]);

    expect(find.text('Manche 1 sur 2'), findsOneWidget);
    expect(
      find.text('Un actif mystère, 26 semaines, ramené à 100 au départ'),
      findsOneWidget,
    );
    expect(
      find.text('Dans 4 semaines, le cours sera plus haut ou plus bas ?'),
      findsOneWidget,
    );
    expect(find.text('Plus haut'), findsOneWidget);
    expect(find.text('Plus bas'), findsOneWidget);
    expect(find.textContaining('Coca-Cola'), findsNothing);
  });

  testWidgets('the hint button is shown but disabled', (tester) async {
    await pumpGame(tester, [round(rises: false)]);

    final button = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Voir un indice'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('a wrong answer reveals the asset, the period and the loss', (
    tester,
  ) async {
    await pumpGame(tester, [round(rises: false), round(rises: true)]);

    await tester.tap(find.text('Plus haut'));
    await tester.pumpAndSettle();

    expect(findPlainText('Raté : −6,2 % en 4 semaines'), findsOneWidget);
    expect(find.text('Tu avais répondu plus haut.'), findsOneWidget);
    expect(
      find.text("C'était Coca-Cola, de mars à octobre 2019"),
      findsOneWidget,
    );
    expect(find.text('0 bonne sur 1'), findsOneWidget);
    expect(find.textContaining('La courbe montait depuis 6 mois'), findsOne);
    expect(find.text('Plus haut'), findsNothing);
    expect(find.text('Manche suivante'), findsOneWidget);
  });

  testWidgets('a full game ends on the score, then can be replayed', (
    tester,
  ) async {
    await pumpGame(tester, [round(rises: false), round(rises: true)]);

    await tester.tap(find.text('Plus bas'));
    await tester.pumpAndSettle();
    expect(findPlainText('Bien vu : −6,2 % en 4 semaines'), findsOneWidget);
    await tester.tap(find.text('Manche suivante'));
    await tester.pumpAndSettle();

    expect(find.text('Manche 2 sur 2'), findsOneWidget);
    expect(find.text('1 bonne sur 1'), findsOneWidget);
    await tester.tap(find.text('Plus haut'));
    await tester.pumpAndSettle();
    expect(findPlainText('Bien vu : +5,0 % en 4 semaines'), findsOneWidget);
    await tester.tap(find.text('Voir le bilan'));
    await tester.pumpAndSettle();

    expect(find.text('Partie terminée'), findsOneWidget);
    expect(find.bySemanticsLabel('2 sur 2'), findsOneWidget);
    expect(find.text('/ 2'), findsOneWidget);
    expect(find.text('zone du hasard'), findsOneWidget);
    expect(find.text('meilleur score'), findsOneWidget);

    await tester.tap(find.text('Accueil'));
    expect(wentHome, isTrue);

    await tester.tap(find.text('Rejouer'));
    await tester.pumpAndSettle();
    expect(find.text('Manche 1 sur 2'), findsOneWidget);
  });

  testWidgets('the three screens fit a small phone without overflow', (
    tester,
  ) async {
    await pumpGame(tester, [round(rises: false)], size: const Size(320, 568));
    expect(tester.takeException(), isNull);

    // The answers are below the fold on such a small screen.
    await tester.ensureVisible(find.text('Plus haut'));
    await tester.tap(find.text('Plus haut'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Voir le bilan'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('without any round, the game says it is unavailable', (
    tester,
  ) async {
    await pumpGame(tester, const []);

    expect(
      find.text("Le jeu n'est pas disponible pour l'instant."),
      findsOneWidget,
    );
  });
}
