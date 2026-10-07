import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/features/game/domain/game_round.dart';
import 'package:lucide/features/game/domain/game_verdict.dart';

GameRound round(List<double> history, List<double> future) => GameRound(
  assetName: 'Test',
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

  test('chanceVerdict: 6 to 14 good answers are within chance', () {
    expect(chanceVerdict(5), ChanceVerdict.belowChance);
    expect(chanceVerdict(6), ChanceVerdict.withinChance);
    expect(chanceVerdict(14), ChanceVerdict.withinChance);
    expect(chanceVerdict(15), ChanceVerdict.aboveChance);
  });
}
