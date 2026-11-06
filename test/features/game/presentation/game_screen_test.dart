import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lucide/core/theme/app_theme.dart';
import 'package:lucide/features/catalog/domain/instrument.dart';
import 'package:lucide/features/game/data/game_repository.dart';
import 'package:lucide/features/game/domain/earnings_announcement.dart';
import 'package:lucide/features/game/domain/game_round.dart';
import 'package:lucide/features/game/domain/market_event.dart';
import 'package:lucide/features/game/presentation/game_screen.dart';

import '../../../helpers.dart';

/// 26 visible weeks going from 100 to 106, then 4 hidden weeks ending
/// 6,2 % lower (the example of the mockup) or 5 % higher.
GameRound round({
  required bool rises,
  List<MarketEvent> events = const [],
  List<MarketEvent> contextEvents = const [],
  List<EarningsAnnouncement> earnings = const [],
}) {
  final history = [for (var i = 0; i < 26; i++) 100 + i * 6 / 25];
  final last = rises ? 106 * 1.05 : 106 * (1 - 0.062);
  return GameRound(
    asset: instrument(
      'KO',
      name: 'Coca-Cola',
      description: 'Le fabricant de sodas le plus connu au monde.',
    ),
    history: history,
    future: [106, 105, 104, last],
    start: DateTime.utc(2019, 3, 4),
    end: DateTime.utc(2019, 10, 21),
    events: events,
    contextEvents: contextEvents,
    earnings: earnings,
  );
}

/// An event with a fact before the hidden weeks (round start: 4 March 2019,
/// hidden weeks from 9 September 2019) and one inside them.
final fedEvent = MarketEvent(
  id: 'fed',
  start: DateTime.utc(2019, 6, 3),
  end: DateTime.utc(2019, 10, 1),
  title: 'La Fed change de cap',
  milestones: [
    Milestone(day: DateTime.utc(2019, 6, 3), text: 'Elle baisse son taux.'),
    Milestone(day: DateTime.utc(2019, 9, 20), text: 'Elle le baisse encore.'),
  ],
  mechanism: 'Un crédit moins cher aide plutôt les actions.',
  summary: 'La banque centrale américaine modifie son taux.',
  appliesTo: const {InstrumentType.stock},
  sources: const [
    EventSource(label: 'Fed', url: 'https://www.federalreserve.gov/'),
  ],
);

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
    // Tall by default: the context card pushes the answers down the page.
    tester.view.physicalSize = size ?? const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameRepositoryProvider.overrideWithValue(FakeGameRepository(rounds)),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(body: GameScreen(onGoHome: () => wentHome = true)),
        ),
      ),
    );
    // The rounds arrive one frame later: they are drawn asynchronously.
    await tester.pumpAndSettle();
  }

  testWidgets('a round names the company and asks the question', (
    tester,
  ) async {
    await pumpGame(tester, [round(rises: false), round(rises: true)]);

    expect(find.text('Manche 1 sur 2'), findsOneWidget);
    expect(find.text('Coca-Cola'), findsOneWidget);
    expect(find.text('Action, KO'), findsOneWidget);
    expect(
      find.text('Le fabricant de sodas le plus connu au monde.'),
      findsOneWidget,
    );
    expect(
      find.text('Coca-Cola, de mars à août 2019, ramené à 100 au départ'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Dans 4 semaines, le cours de Coca-Cola sera plus haut ou plus bas ?',
      ),
      findsOneWidget,
    );
    expect(find.text('Plus haut'), findsOneWidget);
    expect(find.text('Plus bas'), findsOneWidget);
    expect(find.text('Voir un indice'), findsNothing);
  });

  testWidgets('before the bet: the period, the market and the events known', (
    tester,
  ) async {
    await pumpGame(tester, [
      round(
        rises: false,
        events: [fedEvent],
        contextEvents: [fedEvent],
        earnings: [
          EarningsAnnouncement(day: DateTime.utc(2019, 7, 18)),
          // After the visible weeks: kept for the explanation.
          EarningsAnnouncement(day: DateTime.utc(2019, 9, 19)),
        ],
      ),
    ]);

    expect(find.text('Une période calme'), findsOneWidget);
    expect(find.text('Ce qui se passait dans le monde'), findsOneWidget);
    expect(find.text('La Fed change de cap'), findsOneWidget);
    expect(
      find.textContaining('3 juin 2019 : Elle baisse son taux.'),
      findsOne,
    );
    expect(
      find.text('Un crédit moins cher aide plutôt les actions.'),
      findsOneWidget,
    );
    expect(find.textContaining('Comment réagir dans ce marché'), findsOne);
    // The announcement of the visible weeks is listed, not the later one.
    expect(find.text('Résultats de l\'entreprise'), findsOneWidget);
    expect(find.text('18 juil. 2019 : résultats publiés.'), findsOneWidget);
    expect(find.textContaining('19 sept. 2019'), findsNothing);
  });

  testWidgets('nothing from the hidden weeks leaks before the bet', (
    tester,
  ) async {
    await pumpGame(tester, [
      round(rises: false, events: [fedEvent], contextEvents: [fedEvent]),
    ]);

    // The fact dated inside the hidden weeks and the story of the event
    // wait for the answer.
    expect(find.textContaining('Elle le baisse encore'), findsNothing);
    expect(
      find.text('La banque centrale américaine modifie son taux.'),
      findsNothing,
    );
    expect(find.text('Expliquer la réponse'), findsNothing);
  });

  testWidgets('the context says so when no event was going on', (tester) async {
    await pumpGame(tester, [round(rises: true)]);

    expect(find.textContaining('Aucun événement majeur'), findsOneWidget);
    expect(find.text('Résultats de l\'entreprise'), findsNothing);
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

  testWidgets('the reveal gives the context of the real asset', (tester) async {
    await pumpGame(tester, [round(rises: false), round(rises: true)]);

    await tester.tap(find.text('Plus bas'));
    await tester.pumpAndSettle();

    expect(find.text('Action, KO'), findsOneWidget);
    expect(find.text('Coca-Cola'), findsOneWidget);
    expect(
      find.text('Le fabricant de sodas le plus connu au monde.'),
      findsOneWidget,
    );
    expect(find.text('Les 26 semaines affichées'), findsOneWidget);
    expect(findPlainText('+6,0 %'), findsOneWidget);
    expect(find.text('Les 4 semaines suivantes'), findsOneWidget);
    expect(findPlainText('−6,2 %'), findsOneWidget);
    expect(find.text('Voir la fiche de cet actif'), findsOneWidget);
  });

  testWidgets('the explanation only appears when the player asks for it', (
    tester,
  ) async {
    await pumpGame(tester, [
      round(rises: false, events: [fedEvent]),
    ]);
    // No button before the answer, and no story of the events.
    expect(find.text('Expliquer la réponse'), findsNothing);
    expect(
      find.text('La banque centrale américaine modifie son taux.'),
      findsNothing,
    );

    await tester.tap(find.text('Plus bas'));
    await tester.pumpAndSettle();
    // Revealed, but still not explained.
    expect(find.text('Expliquer la réponse'), findsOneWidget);
    expect(find.text('La Fed change de cap'), findsNothing);

    await tester.ensureVisible(find.text('Expliquer la réponse'));
    await tester.tap(find.text('Expliquer la réponse'));
    await tester.pumpAndSettle();

    expect(find.text('Expliquer la réponse'), findsNothing);
    expect(find.text('La Fed change de cap'), findsOneWidget);
    expect(
      find.text('La banque centrale américaine modifie son taux.'),
      findsOneWidget,
    );
    expect(
      find.text('Fed : https://www.federalreserve.gov/', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Pourquoi le cours a bougé'), findsOneWidget);
    expect(find.text('Comment réagir'), findsOneWidget);
    expect(
      find.textContaining('pas un conseil en investissement'),
      findsOneWidget,
    );
  });

  testWidgets('without any known event, the card says so and stays honest', (
    tester,
  ) async {
    await pumpGame(tester, [round(rises: true)]);
    await tester.tap(find.text('Plus haut'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Expliquer la réponse'));
    await tester.tap(find.text('Expliquer la réponse'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Aucun événement de notre liste'), findsOne);
    // The numbers are still analyzed: a steady climb of 6 % is calm.
    expect(find.text('Une période calme'), findsOneWidget);
  });

  testWidgets('earnings of the company are listed in the explanation', (
    tester,
  ) async {
    await pumpGame(tester, [
      round(
        rises: true,
        earnings: [
          EarningsAnnouncement(
            day: DateTime.utc(2019, 7, 18),
            surprisePercent: 4.5,
          ),
        ],
      ),
    ]);
    await tester.tap(find.text('Plus haut'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Expliquer la réponse'));
    await tester.tap(find.text('Expliquer la réponse'));
    await tester.pumpAndSettle();

    expect(find.text('Résultats de l\'entreprise'), findsOneWidget);
    expect(
      findPlainText('18 juil. 2019 : résultats meilleurs que prévu (+4,5 %).'),
      findsOneWidget,
    );
  });

  testWidgets('the explanation is asked again for each round', (tester) async {
    await pumpGame(tester, [round(rises: true), round(rises: true)]);
    await tester.tap(find.text('Plus haut'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Expliquer la réponse'));
    await tester.tap(find.text('Expliquer la réponse'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Manche suivante'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Plus haut'));
    await tester.pumpAndSettle();

    expect(find.text('Expliquer la réponse'), findsOneWidget);
  });

  testWidgets('the explanation fits a small phone', (tester) async {
    await pumpGame(tester, [
      round(rises: false, events: [fedEvent, fedEvent]),
    ], size: const Size(320, 640));
    await tester.ensureVisible(find.text('Plus bas'));
    await tester.tap(find.text('Plus bas'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Expliquer la réponse'));
    await tester.tap(find.text('Expliquer la réponse'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
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
    expect(find.textContaining('Ouvre le catalogue'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
  });
}
