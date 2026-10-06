import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/features/game/domain/game_round.dart';
import 'package:lucide/features/game/presentation/game_controller.dart';
import 'package:lucide/features/game/presentation/game_state.dart';
import 'package:lucide/features/game/presentation/sample_rounds.dart';

GameRound round({required bool rises}) => GameRound(
  assetName: 'Test',
  history: const [100, 110],
  future: [rises ? 120 : 90],
  start: DateTime.utc(2019, 3, 4),
  end: DateTime.utc(2019, 10, 21),
);

void main() {
  late ProviderContainer container;

  GameState state() => container.read(gameControllerProvider);
  GameController controller() =>
      container.read(gameControllerProvider.notifier);

  setUp(() {
    container = ProviderContainer(
      overrides: [
        gameRoundsProvider.overrideWithValue([
          round(rises: true),
          round(rises: false),
          round(rises: true),
        ]),
      ],
    );
    addTearDown(container.dispose);
  });

  test('a game starts on the first round, with no answer', () {
    expect(state().phase, GamePhase.playing);
    expect(state().roundIndex, 0);
    expect(state().guess, isNull);
    expect(state().score, 0);
  });

  test('answering reveals the round and counts the good answer', () {
    controller().answer(Guess.higher);

    expect(state().phase, GamePhase.revealed);
    expect(state().roundIndex, 0);
    expect(state().guess, Guess.higher);
    expect(state().score, 1);
  });

  test('a second answer to the same round is ignored', () {
    controller().answer(Guess.lower);
    controller().answer(Guess.higher);

    expect(state().guesses, [Guess.lower]);
    expect(state().score, 0);
  });

  test('nextRound does nothing before an answer', () {
    controller().nextRound();

    expect(state().phase, GamePhase.playing);
    expect(state().roundIndex, 0);
  });

  test('the game ends after the last round, then can be replayed', () {
    controller().answer(Guess.higher); // right
    controller().nextRound();
    expect(state().roundIndex, 1);
    expect(state().phase, GamePhase.playing);

    controller().answer(Guess.higher); // wrong
    controller().nextRound();
    controller().answer(Guess.higher); // right
    expect(state().isLastRound, isTrue);

    controller().nextRound();
    expect(state().phase, GamePhase.finished);
    expect(state().score, 2);

    controller().restart();
    expect(state().phase, GamePhase.playing);
    expect(state().roundIndex, 0);
    expect(state().guesses, isEmpty);
  });

  test('the sample data gives a full game of 26 + 4 weeks', () {
    final rounds = ProviderContainer.test().read(gameRoundsProvider);

    expect(rounds, hasLength(20));
    for (final round in rounds) {
      expect(round.history, hasLength(26));
      expect(round.future, hasLength(4));
      expect(round.history.first, 100);
    }
  });
}
