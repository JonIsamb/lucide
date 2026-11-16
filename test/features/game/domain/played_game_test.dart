import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/features/game/domain/played_game.dart';

PlayedGame game(int score, {int rounds = 10}) => PlayedGame(
  finishedAt: DateTime.utc(2026, 11, 10),
  score: score,
  roundCount: rounds,
);

void main() {
  test('no game played: no statistics', () {
    expect(summarizeGames(const []), isNull);
  });

  test('one game: it is the best and the average', () {
    final stats = summarizeGames([game(6)])!;
    expect(stats.gamesPlayed, 1);
    expect(stats.bestScore, 6);
    expect(stats.averageScore, 6);
  });

  test('several games: count, best and average', () {
    final stats = summarizeGames([game(4), game(9), game(5), game(4)])!;
    expect(stats.gamesPlayed, 4);
    expect(stats.bestScore, 9);
    expect(stats.averageScore, 5.5);
  });

  test('only zeros: best and average are zero', () {
    final stats = summarizeGames([game(0), game(0)])!;
    expect(stats.bestScore, 0);
    expect(stats.averageScore, 0);
  });
}
