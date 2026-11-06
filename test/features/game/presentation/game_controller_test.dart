import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/features/game/data/game_repository.dart';
import 'package:lucide/features/game/domain/game_round.dart';
import 'package:lucide/features/game/presentation/game_controller.dart';
import 'package:lucide/features/game/presentation/game_state.dart';

import '../../../helpers.dart';

GameRound round({required bool rises}) => GameRound(
  asset: instrument('TEST'),
  history: const [100, 110],
  future: [rises ? 120 : 90],
  start: DateTime.utc(2019, 3, 4),
  end: DateTime.utc(2019, 10, 21),
);

void main() {
  late ProviderContainer container;
  late FakeGameRepository repository;

  GameState state() => container.read(gameControllerProvider).requireValue;
  GameController controller() =>
      container.read(gameControllerProvider.notifier);

  setUp(() async {
    repository = FakeGameRepository([
      round(rises: true),
      round(rises: false),
      round(rises: true),
    ]);
    container = ProviderContainer(
      overrides: [gameRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    // The rounds are drawn before each test starts.
    await container.read(gameControllerProvider.future);
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

  test('the explanation is for the revealed round on screen only', () {
    // Too early: the answer is not given yet.
    controller().explain();
    expect(state().explainedRounds, isEmpty);

    controller().answer(Guess.higher);
    expect(state().explanationShown, isFalse);
    controller().explain();
    expect(state().explanationShown, isTrue);
    expect(state().explainedRounds, {0});

    // Not carried over to the next round.
    controller().nextRound();
    expect(state().explanationShown, isFalse);
    controller().answer(Guess.lower);
    expect(state().explanationShown, isFalse);
  });

  test('nextRound does nothing before an answer', () {
    controller().nextRound();

    expect(state().phase, GamePhase.playing);
    expect(state().roundIndex, 0);
  });

  test('the game ends after the last round, then can be replayed', () async {
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
    await container.read(gameControllerProvider.future);
    expect(state().phase, GamePhase.playing);
    expect(state().roundIndex, 0);
    expect(state().guesses, isEmpty);
    // Replaying asks the repository for newly drawn rounds.
    expect(repository.draws, 2);
  });

  test('actions are ignored when no round could be drawn', () async {
    container = ProviderContainer(
      overrides: [
        gameRepositoryProvider.overrideWithValue(FakeGameRepository(const [])),
      ],
    );
    addTearDown(container.dispose);
    await container.read(gameControllerProvider.future);

    controller().answer(Guess.higher);
    controller().nextRound();

    expect(state().rounds, isEmpty);
    expect(state().guesses, isEmpty);
    expect(state().phase, GamePhase.playing);
  });
}
