import '../domain/game_round.dart';
import '../domain/game_verdict.dart';

/// Where the player is in the game.
enum GamePhase {
  /// The curve is shown, the player has not answered yet.
  playing,

  /// The player answered, the hidden weeks are shown.
  revealed,

  /// Every round was played, the final score is shown.
  finished,
}

/// Everything the game screens display.
class GameState {
  const GameState({
    required this.rounds,
    this.guesses = const [],
    this.phase = GamePhase.playing,
  });

  final List<GameRound> rounds;

  /// One answer per round already played, in order.
  final List<Guess> guesses;
  final GamePhase phase;

  /// Index of the round on screen. While a round is revealed, its answer
  /// is already in [guesses], hence the "- 1".
  int get roundIndex =>
      phase == GamePhase.playing ? guesses.length : guesses.length - 1;

  GameRound get round => rounds[roundIndex];

  /// The player's answer to the round on screen (null while playing).
  Guess? get guess => phase == GamePhase.playing ? null : guesses.last;

  bool get isLastRound => roundIndex == rounds.length - 1;

  /// Good answers so far.
  int get score {
    var count = 0;
    for (var i = 0; i < guesses.length; i++) {
      if (isCorrect(rounds[i], guesses[i])) count++;
    }
    return count;
  }

  GameState copyWith({List<Guess>? guesses, GamePhase? phase}) {
    return GameState(
      rounds: rounds,
      guesses: guesses ?? this.guesses,
      phase: phase ?? this.phase,
    );
  }
}
