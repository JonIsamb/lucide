// Pure rules of the game: who was right, and what a score is worth.

import 'game_round.dart';

/// Rounds in one game.
const roundsPerGame = 20;

/// With 20 coin flips, a score between 6 and 14 happens by pure chance
/// (two-sided binomial test at the 5 % level).
const chanceLowerBound = 6;
const chanceUpperBound = 14;

/// Change in % over the hidden weeks: last hidden close against the last
/// visible close. Null when the round has no usable prices.
double? roundChangePercent(GameRound round) {
  if (round.history.isEmpty || round.future.isEmpty) return null;
  final from = round.history.last;
  if (from <= 0) return null;
  return (round.future.last / from - 1) * 100;
}

/// What the price really did. An unchanged price is "lower": it did not
/// end higher. Null when the round has no usable prices.
Guess? roundOutcome(GameRound round) {
  final change = roundChangePercent(round);
  if (change == null) return null;
  return change > 0 ? Guess.higher : Guess.lower;
}

bool isCorrect(GameRound round, Guess guess) => roundOutcome(round) == guess;

/// Whether the visible weeks ended higher than they started.
bool historyRose(GameRound round) =>
    round.history.length >= 2 && round.history.last > round.history.first;

/// How a final score compares with flipping a coin.
enum ChanceVerdict { belowChance, withinChance, aboveChance }

ChanceVerdict chanceVerdict(int score) {
  if (score < chanceLowerBound) return ChanceVerdict.belowChance;
  if (score > chanceUpperBound) return ChanceVerdict.aboveChance;
  return ChanceVerdict.withinChance;
}
