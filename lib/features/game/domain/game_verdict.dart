// Pure rules of the game: who was right, and what a score is worth.

import 'dart:math';

import 'game_round.dart';

/// Rounds in one game.
const roundsPerGame = 10;

/// Risk accepted when saying "this score is not luck" (5 %).
const chanceLevel = 0.05;

/// Change in % over the hidden weeks: last hidden close against the last
/// visible close. Null when the round has no usable prices.
double? roundChangePercent(GameRound round) {
  if (round.history.isEmpty || round.future.isEmpty) return null;
  final from = round.history.last;
  if (from <= 0) return null;
  return (round.future.last / from - 1) * 100;
}

/// Change in % over the visible weeks: last visible close against the
/// first one. Null when the round has no usable prices.
double? historyChangePercent(GameRound round) {
  if (round.history.length < 2) return null;
  final from = round.history.first;
  if (from <= 0) return null;
  return (round.history.last / from - 1) * 100;
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

/// The scores a coin flipped [rounds] times plausibly gets: from `lower`
/// to `upper`, both included (two-sided binomial test at [chanceLevel]).
///
/// We widen the two tails one score at a time, as long as landing in them
/// by pure luck stays under 5 %. With 10 rounds: 2 to 8 (scores 0, 1, 9
/// and 10 together have a 2,1 % chance). With 20 rounds: 6 to 14.
({int lower, int upper}) chanceBounds(int rounds) {
  var lower = 0;
  // Chance that a coin scores less than `lower`.
  var tail = 0.0;
  // Chance that a coin scores exactly `lower`.
  var probability = pow(0.5, rounds).toDouble();

  while (lower < rounds / 2 && 2 * (tail + probability) <= chanceLevel) {
    tail += probability;
    // From C(n, k) to C(n, k + 1).
    probability = probability * (rounds - lower) / (lower + 1);
    lower++;
  }
  return (lower: lower, upper: rounds - lower);
}

/// How a final score compares with flipping a coin.
enum ChanceVerdict { belowChance, withinChance, aboveChance }

ChanceVerdict chanceVerdict(int score, {int rounds = roundsPerGame}) {
  final bounds = chanceBounds(rounds);
  if (score < bounds.lower) return ChanceVerdict.belowChance;
  if (score > bounds.upper) return ChanceVerdict.aboveChance;
  return ChanceVerdict.withinChance;
}
