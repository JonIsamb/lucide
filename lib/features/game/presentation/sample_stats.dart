// Temporary numbers so the final screen can be shown before games are
// saved. The step that persists the games replaces this provider.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/game_round.dart';

final gameStatsProvider = Provider<GameStats>(
  (ref) => const GameStats(gamesPlayed: 3, bestScore: 7, averageScore: 5.3),
);
