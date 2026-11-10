import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lucide/features/game/domain/played_game.dart';
import 'package:lucide/features/home/home_texts.dart';
import 'package:lucide/features/simulator/domain/simulation_result.dart';

import '../../helpers.dart';

/// Thin no-break space: the French thousands separator of intl.
const _thin = ' ';
const _nbsp = ' ';

PlayedGame game(int score, {int rounds = 10}) => PlayedGame(
  finishedAt: DateTime.utc(2026, 11, 10),
  score: score,
  roundCount: rounds,
);

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  group('simulation card', () {
    test('title: asset, amount and holding time', () {
      expect(
        simulationTitle(simulationResult().params),
        'S&P 500, 1${_thin}000$_nbsp€ sur 2 ans',
      );
      expect(
        simulationTitle(
          simulationResult(
            assetName: 'Apple',
            amount: 250,
            buyDay: DateTime.utc(2025, 1, 10),
            sellDay: DateTime.utc(2025, 9, 10),
          ).params,
        ),
        'Apple, 250,00$_nbsp€ sur 8 mois',
      );
    });

    test('a gain is "gagnés", a loss is not', () {
      expect(realGainCaption(0.037), 'gagnés en\npouvoir d’achat');
      expect(realGainCaption(0), 'gagnés en\npouvoir d’achat');
      expect(realGainCaption(-0.042), 'de pouvoir\nd’achat');
    });

    test('nothing left: says whether the price fell or the costs ate it', () {
      expect(
        nothingLeftSentence(
          simulationResult(gross: -0.1, fx: 0, fees: 0, tax: 0, inflation: 0),
        ),
        contains('Le cours n’a pas monté'),
      );
      expect(
        nothingLeftSentence(simulationResult(gross: 0.05)),
        contains('il ne reste rien du gain annoncé'),
      );
    });

    test('costs are listed in a sentence, first word capitalised', () {
      expect(
        costsSentence([CascadeStep.fx, CascadeStep.fees, CascadeStep.tax]),
        'Change, frais, impôt',
      );
      expect(costsSentence([CascadeStep.inflation]), 'Inflation');
      expect(costsSentence(const []), '');
    });
  });

  group('game shortcut', () {
    test('no game yet: an invitation to play', () {
      expect(
        lastGameSubtitle(null),
        'Pas encore de partie : devine la suite de 10 vraies courbes.',
      );
    });

    test('the last score, compared with a coin', () {
      expect(
        lastGameSubtitle(game(6)),
        'Dernière partie : 6/10, comme une pièce',
      );
      // 2 and 8 are still inside the chance bounds on 10 rounds.
      expect(lastGameSubtitle(game(8)), endsWith('comme une pièce'));
      expect(lastGameSubtitle(game(2)), endsWith('comme une pièce'));
      expect(
        lastGameSubtitle(game(9)),
        'Dernière partie : 9/10, mieux qu’une pièce',
      );
      expect(
        lastGameSubtitle(game(1)),
        'Dernière partie : 1/10, moins bien qu’une pièce',
      );
    });

    test('the bounds follow the number of rounds of that game', () {
      // On 20 rounds, chance explains 6 to 14: 15 is above.
      expect(
        lastGameSubtitle(game(15, rounds: 20)),
        'Dernière partie : 15/20, mieux qu’une pièce',
      );
      expect(
        lastGameSubtitle(game(11, rounds: 20)),
        'Dernière partie : 11/20, comme une pièce',
      );
    });
  });
}
