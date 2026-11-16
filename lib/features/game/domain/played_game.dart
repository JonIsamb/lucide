// The player's history: finished games and what they add up to.

/// A finished game, as saved on the phone.
class PlayedGame {
  const PlayedGame({
    required this.finishedAt,
    required this.score,
    required this.roundCount,
  });

  final DateTime finishedAt;

  /// Good answers.
  final int score;

  /// Rounds of the game: a score only means something next to it.
  final int roundCount;
}

/// Numbers shown under the final score.
class GameStats {
  const GameStats({
    required this.gamesPlayed,
    required this.bestScore,
    required this.averageScore,
  });

  final int gamesPlayed;
  final int bestScore;
  final double averageScore;
}

/// Games played, best and average score of [games]. Null when no game was
/// played yet: there is nothing to average.
GameStats? summarizeGames(List<PlayedGame> games) {
  if (games.isEmpty) return null;
  var best = games.first.score;
  var total = 0;
  for (final game in games) {
    if (game.score > best) best = game.score;
    total += game.score;
  }
  return GameStats(
    gamesPlayed: games.length,
    bestScore: best,
    averageScore: total / games.length,
  );
}
