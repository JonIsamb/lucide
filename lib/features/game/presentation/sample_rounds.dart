// Temporary data so the game screens can be built and shown before the
// real draw exists. The curves are invented: that is why the assets have
// neutral names instead of real ones.
//
// The functional step replaces these two providers with a repository that
// draws 30-week windows from the weekly series stored in the database.

import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/game_round.dart';
import '../domain/game_verdict.dart';

const _visibleWeeks = 26;
const _hiddenWeeks = 4;

final gameRoundsProvider = Provider<List<GameRound>>(
  (ref) => [for (var i = 0; i < roundsPerGame; i++) _sampleRound(i)],
);

final gameStatsProvider = Provider<GameStats>(
  (ref) => const GameStats(gamesPlayed: 3, bestScore: 13, averageScore: 10.3),
);

/// A made-up curve. The seed makes it the same at every launch.
GameRound _sampleRound(int index) {
  final random = Random(index);
  var price = 100.0;
  final prices = [price];
  for (var week = 1; week < _visibleWeeks + _hiddenWeeks; week++) {
    // A weekly move between about -3,4 % and +3,6 %.
    price *= 1 + (random.nextDouble() - 0.48) * 0.07;
    prices.add(price);
  }

  final start = DateTime.utc(2019 + index % 5, 1 + index % 12, 7);
  return GameRound(
    assetName: 'Actif exemple ${index + 1}',
    history: prices.sublist(0, _visibleWeeks),
    future: prices.sublist(_visibleWeeks),
    start: start,
    end: start.add(
      const Duration(days: 7 * (_visibleWeeks + _hiddenWeeks - 1)),
    ),
  );
}
