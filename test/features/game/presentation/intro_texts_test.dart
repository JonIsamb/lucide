import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/features/game/domain/game_verdict.dart';
import 'package:lucide/features/game/presentation/intro_texts.dart';

void main() {
  test('the target score comes from the chance bounds', () {
    // 10 rounds: a coin gets 2 to 8, so 9 is the first score beyond chance.
    final sentence = targetScoreSentence(10);
    expect(sentence, contains('entre 2 et 8'));
    expect(sentence, contains('il faut 9 ou plus'));
  });

  test('the target follows the number of rounds', () {
    // 20 rounds: 6 to 14.
    expect(targetScoreSentence(20), contains('entre 6 et 14'));
    expect(targetScoreSentence(20), contains('il faut 15 ou plus'));
  });

  test('every verdict has its label', () {
    expect(verdictLabel(ChanceVerdict.withinChance), 'Comme le hasard');
    expect(verdictLabel(ChanceVerdict.aboveChance), 'Au dessus du hasard');
    expect(verdictLabel(ChanceVerdict.belowChance), 'Sous le hasard');
  });

  test('the rules sentence gives the rounds and the weeks', () {
    final text = howItWorks(10);
    expect(text, contains('10 manches'));
    expect(text, contains('26 semaines'));
    expect(text, contains('4 semaines'));
  });
}
