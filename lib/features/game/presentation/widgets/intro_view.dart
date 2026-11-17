import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/game_verdict.dart';
import '../../domain/played_game.dart';
import '../intro_texts.dart';
import 'summary_tiles.dart';

/// How many past games the welcome screen lists.
const _recentGames = 5;

/// Welcome screen of the game: how it works, the score to reach, the past
/// games and some advice. It shows what it is given and calls [onStart].
class GameIntro extends StatelessWidget {
  const GameIntro({
    super.key,
    required this.games,
    required this.stats,
    required this.roundCount,
  });

  /// Finished games, newest first. Empty: none played yet (or still being
  /// read).
  final List<PlayedGame> games;
  final GameStats? stats;
  final int roundCount;

  @override
  Widget build(BuildContext context) {
    final bounds = chanceBounds(roundCount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Teste ton intuition',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 6),
        Text(
          howItWorks(roundCount),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 1.45,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 20),
        const _Heading('Le score à viser'),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ScoreScale(roundCount: roundCount, bounds: bounds),
              const SizedBox(height: 12),
              Text(targetScoreSentence(roundCount), style: _body),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _Heading('Tes parties'),
        if (stats case final stats?) ...[
          StatsTiles(stats: stats, roundCount: roundCount),
          const SizedBox(height: 10),
          _Card(
            child: Column(
              children: [
                for (final game in games.take(_recentGames))
                  _GameRow(game: game),
              ],
            ),
          ),
        ] else
          _Card(
            child: Text(
              'Pas encore de partie. Tes scores apparaîtront ici, comparés '
              'au hasard.',
              style: _body,
            ),
          ),
        const SizedBox(height: 20),
        const _Heading('Pour bien aborder le jeu'),
        for (final hint in gameHints) _Hint(icon: hint.$1, text: hint.$2),
      ],
    );
  }
}

const _body = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  height: 1.45,
  color: AppColors.ink,
);

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Semantics(
      header: true,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: AppColors.ink,
        ),
      ),
    ),
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
    ),
    child: child,
  );
}

/// 0 to N boxes: the scores a coin can get are grey, the others green.
class _ScoreScale extends StatelessWidget {
  const _ScoreScale({required this.roundCount, required this.bounds});

  final int roundCount;
  final ({int lower, int upper}) bounds;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Le hasard donne entre ${bounds.lower} et ${bounds.upper} '
          'sur $roundCount',
      excludeSemantics: true,
      child: Row(
        children: [
          for (var score = 0; score <= roundCount; score++)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: score >= bounds.lower && score <= bounds.upper
                      ? AppColors.divider
                      : AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$score',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GameRow extends StatelessWidget {
  const _GameRow({required this.game});
  final PlayedGame game;

  @override
  Widget build(BuildContext context) {
    final verdict = chanceVerdict(game.score, rounds: game.roundCount);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              formatDay(game.finishedAt.toLocal()),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
              ),
            ),
          ),
          Text(
            '${game.score}/${game.roundCount}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 130,
            child: Text(
              verdictLabel(verdict),
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: verdict == ChanceVerdict.aboveChance
                    ? AppColors.primary
                    : AppColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.icon, required this.text});

  final String icon;
  final String text;

  static const _icons = {
    'context': Icons.menu_book_rounded,
    'trend': Icons.show_chart_rounded,
    'flat': Icons.horizontal_rule_rounded,
    'explain': Icons.lightbulb_outline_rounded,
    'chance': Icons.casino_outlined,
    'time': Icons.timer_off_outlined,
  };

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          _icons[icon] ?? Icons.tips_and_updates_outlined,
          size: 22,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: _body)),
      ],
    ),
  );
}
