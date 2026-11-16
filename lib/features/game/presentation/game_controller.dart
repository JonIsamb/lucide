import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/game_repository.dart';
import '../domain/game_round.dart';
import 'game_state.dart';

final gameControllerProvider = AsyncNotifierProvider<GameController, GameState>(
  GameController.new,
  // No automatic retry: the player decides with the "Réessayer" button.
  retry: (_, _) => null,
);

/// Receives the player's actions and turns them into a new [GameState].
/// The screens only display that state.
class GameController extends AsyncNotifier<GameState> {
  /// A new game: the repository draws its rounds from the stored prices.
  @override
  Future<GameState> build() async {
    return GameState(rounds: await ref.read(gameRepositoryProvider).drawGame());
  }

  /// The player bets on the round on screen: the hidden weeks are shown.
  void answer(Guess guess) {
    final current = state.value;
    if (current == null ||
        current.phase != GamePhase.playing ||
        current.rounds.isEmpty) {
      return;
    }
    state = AsyncData(
      current.copyWith(
        guesses: [...current.guesses, guess],
        phase: GamePhase.revealed,
      ),
    );
  }

  /// The player asks why the price moved, once the round is revealed.
  void explain() {
    final current = state.value;
    if (current == null || current.phase != GamePhase.revealed) return;
    state = AsyncData(
      current.copyWith(
        explainedRounds: {...current.explainedRounds, current.roundIndex},
      ),
    );
  }

  /// Moves to the next round, or to the final score after the last one.
  /// A finished game is saved: it feeds the statistics and the home screen.
  void nextRound() {
    final current = state.value;
    if (current == null || current.phase != GamePhase.revealed) return;
    final finished = current.isLastRound;
    state = AsyncData(
      current.copyWith(
        phase: finished ? GamePhase.finished : GamePhase.playing,
      ),
    );
    // A game reaches "finished" only once, so it is saved only once.
    if (finished) unawaited(_save(current));
  }

  /// The final score is shown at once; saving happens in the background.
  Future<void> _save(GameState game) async {
    try {
      await ref
          .read(gameRepositoryProvider)
          .saveGame(score: game.score, roundCount: game.rounds.length);
    } on Object {
      // The player still sees the score: only the history misses this
      // game. There is nothing useful to ask them to do about it.
      return;
    }
  }

  /// Starts a new game, with newly drawn rounds.
  void restart() => ref.invalidateSelf();
}
