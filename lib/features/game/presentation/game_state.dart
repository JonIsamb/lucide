import '../domain/game_round.dart';
import '../domain/game_verdict.dart';

/// Where the player is in the game.
enum GamePhase {
  /// Welcome screen: past games, the score to beat and advice. No round
  /// is started yet.
  intro,

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
    this.phase = GamePhase.intro,
    this.explainedRounds = const {},
  });

  final List<GameRound> rounds;

  /// One answer per round already played, in order.
  final List<Guess> guesses;
  final GamePhase phase;

  /// Indexes of the rounds where the player asked for the explanation.
  final Set<int> explainedRounds;

  /// Index of the round on screen. While a round is revealed, its answer
  /// is already in [guesses], hence the "- 1".
  int get roundIndex => _awaitingAnswer ? guesses.length : guesses.length - 1;

  /// No answer is waiting to be shown: on the welcome screen or while
  /// playing.
  bool get _awaitingAnswer =>
      phase == GamePhase.intro || phase == GamePhase.playing;

  GameRound get round => rounds[roundIndex];

  /// The player's answer to the round on screen (null before answering).
  Guess? get guess => _awaitingAnswer ? null : guesses.last;

  /// Whether the explanation of the round on screen is displayed.
  bool get explanationShown => explainedRounds.contains(roundIndex);

  bool get isLastRound => roundIndex == rounds.length - 1;

  /// Good answers so far.
  int get score {
    var count = 0;
    for (var i = 0; i < guesses.length; i++) {
      if (isCorrect(rounds[i], guesses[i])) count++;
    }
    return count;
  }

  GameState copyWith({
    List<Guess>? guesses,
    GamePhase? phase,
    Set<int>? explainedRounds,
  }) {
    return GameState(
      rounds: rounds,
      guesses: guesses ?? this.guesses,
      phase: phase ?? this.phase,
      explainedRounds: explainedRounds ?? this.explainedRounds,
    );
  }
}
