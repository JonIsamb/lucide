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

  /// The player asks for the hint of the round on screen, before betting.
  void showHint() {
    final current = state.value;
    if (current == null ||
        current.phase != GamePhase.playing ||
        current.rounds.isEmpty) {
      return;
    }
    state = AsyncData(
      current.copyWith(hintRounds: {...current.hintRounds, current.roundIndex}),
    );
  }

  /// Moves to the next round, or to the final score after the last one.
  void nextRound() {
    final current = state.value;
    if (current == null || current.phase != GamePhase.revealed) return;
    state = AsyncData(
      current.copyWith(
        phase: current.isLastRound ? GamePhase.finished : GamePhase.playing,
      ),
    );
  }

  /// Starts a new game, with newly drawn rounds.
  void restart() => ref.invalidateSelf();
}
