import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/game_round.dart';
import 'game_state.dart';
import 'sample_rounds.dart';

final gameControllerProvider = NotifierProvider<GameController, GameState>(
  GameController.new,
);

/// Receives the player's actions and turns them into a new [GameState].
/// The screens only display that state.
class GameController extends Notifier<GameState> {
  @override
  GameState build() => GameState(rounds: ref.watch(gameRoundsProvider));

  /// The player bets on the round on screen: the hidden weeks are shown.
  void answer(Guess guess) {
    if (state.phase != GamePhase.playing || state.rounds.isEmpty) return;
    state = state.copyWith(
      guesses: [...state.guesses, guess],
      phase: GamePhase.revealed,
    );
  }

  /// Moves to the next round, or to the final score after the last one.
  void nextRound() {
    if (state.phase != GamePhase.revealed) return;
    state = state.copyWith(
      phase: state.isLastRound ? GamePhase.finished : GamePhase.playing,
    );
  }

  /// Starts a new game from the first round.
  void restart() => ref.invalidateSelf();
}
