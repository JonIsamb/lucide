import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/features/game/domain/game_round.dart';
import 'package:lucide/features/game/domain/game_verdict.dart';

import '../../../helpers.dart';

GameRound round(List<double> history, List<double> future) => GameRound(
  asset: instrument('TEST'),
  history: history,
  future: future,
  start: DateTime.utc(2019, 3, 4),
  end: DateTime.utc(2019, 10, 21),
);

void main() {
  group('roundChangePercent', () {
    test('compares the last hidden week with the last visible week', () {
      expect(
        roundChangePercent(round([100, 120], [130, 126])),
        closeTo(5, 1e-9),
      );
      expect(
        roundChangePercent(round([100, 106], [104, 99.428])),
        closeTo(-6.2, 1e-9),
      );
    });

    test('is null without usable prices', () {
      expect(roundChangePercent(round([], [110])), isNull);
      expect(roundChangePercent(round([100], [])), isNull);
      expect(roundChangePercent(round([100, 0], [10])), isNull);
    });
  });

  group('roundOutcome and isCorrect', () {
    test('a rise is "higher"', () {
      final up = round([100, 110], [112, 115]);
      expect(roundOutcome(up), Guess.higher);
      expect(isCorrect(up, Guess.higher), isTrue);
      expect(isCorrect(up, Guess.lower), isFalse);
    });

    test('a fall is "lower", even after a first hidden week going up', () {
      final down = round([100, 110], [118, 104]);
      expect(roundOutcome(down), Guess.lower);
      expect(isCorrect(down, Guess.lower), isTrue);
    });

    test('an unchanged price counts as "lower"', () {
      final flat = round([100, 110], [112, 110]);
      expect(roundOutcome(flat), Guess.lower);
    });

    test('no answer is correct without usable prices', () {
      final empty = round([100], []);
      expect(roundOutcome(empty), isNull);
      expect(isCorrect(empty, Guess.higher), isFalse);
      expect(isCorrect(empty, Guess.lower), isFalse);
    });
  });

  test('historyRose compares the first and last visible weeks', () {
    expect(historyRose(round([100, 90, 105], [1])), isTrue);
    expect(historyRose(round([100, 120, 95], [1])), isFalse);
    expect(historyRose(round([100, 100], [1])), isFalse);
    expect(historyRose(round([100], [1])), isFalse);
    expect(historyRose(round([], [1])), isFalse);
  });

  group('historyChangePercent', () {
    test('compares the last visible week with the first one', () {
      expect(
        historyChangePercent(round([100, 90, 112], [1])),
        closeTo(12, 1e-9),
      );
      expect(
        historyChangePercent(round([100, 120, 95], [1])),
        closeTo(-5, 1e-9),
      );
      expect(historyChangePercent(round([100, 100], [1])), 0);
    });

    test('is null without usable prices', () {
      expect(historyChangePercent(round([], [1])), isNull);
      expect(historyChangePercent(round([100], [1])), isNull);
      expect(historyChangePercent(round([0, 10], [1])), isNull);
    });
  });

  group('chanceBounds', () {
    test('a game has 10 rounds: a coin scores between 2 and 8', () {
      expect(roundsPerGame, 10);
      expect(chanceBounds(10), (lower: 2, upper: 8));
    });

    test('20 rounds: between 6 and 14', () {
      expect(chanceBounds(20), (lower: 6, upper: 14));
    });

    test('too few rounds: no score is rare enough', () {
      expect(chanceBounds(0), (lower: 0, upper: 0));
      expect(chanceBounds(1), (lower: 0, upper: 1));
      expect(chanceBounds(5), (lower: 0, upper: 5));
    });
  });

  group('chanceVerdict', () {
    test('10 rounds: bounds 1, 2, 8, 9', () {
      expect(chanceVerdict(1), ChanceVerdict.belowChance);
      expect(chanceVerdict(2), ChanceVerdict.withinChance);
      expect(chanceVerdict(8), ChanceVerdict.withinChance);
      expect(chanceVerdict(9), ChanceVerdict.aboveChance);
    });

    test('20 rounds: bounds 5, 6, 14, 15', () {
      expect(chanceVerdict(5, rounds: 20), ChanceVerdict.belowChance);
      expect(chanceVerdict(6, rounds: 20), ChanceVerdict.withinChance);
      expect(chanceVerdict(14, rounds: 20), ChanceVerdict.withinChance);
      expect(chanceVerdict(15, rounds: 20), ChanceVerdict.aboveChance);
    });
  });
}
