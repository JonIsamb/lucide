// The player's finished games, read from the database. Shared by the final
// score screen and the home screen.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/game_repository.dart';
import '../domain/played_game.dart';

/// Every finished game, newest first. A stream: a game saved by
/// [GameController] reaches every screen that watches it, without reload.
final playedGamesProvider = StreamProvider<List<PlayedGame>>(
  (ref) => ref.watch(gameRepositoryProvider).watchPlayedGames(),
  // No automatic retry: a local read either works or the app is broken.
  retry: (_, _) => null,
);

/// The last finished game. Null data: no game played yet.
final lastPlayedGameProvider = Provider<AsyncValue<PlayedGame?>>(
  (ref) =>
      ref.watch(playedGamesProvider).whenData((games) => games.firstOrNull),
);

/// Games played, best and average score. Null data: no game played yet.
final gameStatsProvider = Provider<AsyncValue<GameStats?>>(
  (ref) => ref.watch(playedGamesProvider).whenData(summarizeGames),
);
