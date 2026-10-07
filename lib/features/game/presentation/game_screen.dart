import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../asset_detail/asset_detail_screen.dart';
import '../domain/game_round.dart';
import '../domain/game_verdict.dart';
import 'game_controller.dart';
import 'game_state.dart';
import 'sample_rounds.dart';
import 'widgets/game_action_bar.dart';
import 'widgets/guess_buttons.dart';
import 'widgets/mystery_chart.dart';
import 'widgets/reveal_banner.dart';
import 'widgets/round_header.dart';
import 'widgets/score_card.dart';
import 'widgets/summary_tiles.dart';

/// The Jeu tab ("Teste ton intuition"). It only displays [GameState] and
/// forwards the player's actions to [GameController].
class GameScreen extends ConsumerWidget {
  const GameScreen({super.key, required this.onGoHome});

  /// Asks the shell to show the Accueil tab.
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);

    return SafeArea(
      bottom: false,
      child: switch (state.phase) {
        _ when state.rounds.isEmpty => const _Unavailable(),
        GamePhase.finished => _SummaryView(
          state: state,
          stats: ref.watch(gameStatsProvider),
          onGoHome: onGoHome,
          onReplay: controller.restart,
        ),
        _ => _RoundView(
          state: state,
          onGuess: controller.answer,
          onNext: controller.nextRound,
        ),
      },
    );
  }
}

/// Scrollable content, with an optional action bar pinned under it.
class _GameLayout extends StatelessWidget {
  const _GameLayout({required this.children, this.actionBar});

  final List<Widget> children;
  final Widget? actionBar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
        ?actionBar,
      ],
    );
  }
}

/// A round, before the answer (question and buttons) and after it (result
/// and revealed curve). Both share the same chart so the hidden weeks can
/// be animated in place.
class _RoundView extends StatelessWidget {
  const _RoundView({
    required this.state,
    required this.onGuess,
    required this.onNext,
  });

  final GameState state;
  final ValueChanged<Guess> onGuess;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final round = state.round;
    final guess = state.guess;
    final change = roundChangePercent(round);
    final revealed = guess != null && change != null;

    return _GameLayout(
      actionBar: revealed
          ? GameActionBar(
              primaryLabel: state.isLastRound
                  ? 'Voir le bilan'
                  : 'Manche suivante',
              onPrimary: onNext,
            )
          : null,
      children: [
        RoundHeader(
          roundIndex: state.roundIndex,
          roundCount: state.rounds.length,
          answered: state.guesses.length,
          score: state.score,
        ),
        const SizedBox(height: 14),
        if (revealed) ...[
          RevealBanner(
            correct: isCorrect(round, guess),
            guess: guess,
            changePercent: change,
            weeks: round.future.length,
          ),
          const SizedBox(height: 14),
        ],
        _ChartCard(
          // One chart per round: its state (the reveal animation) is kept
          // when the banner appears above it, and reset on the next round.
          key: ValueKey(state.roundIndex),
          round: round,
          revealed: revealed,
        ),
        const SizedBox(height: 16),
        if (revealed)
          Text(
            _lesson(round),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.45,
              color: AppColors.ink,
            ),
          )
        else ...[
          Semantics(
            header: true,
            child: Text(
              'Dans ${round.future.length} semaines, le cours sera plus '
              'haut ou plus bas ?',
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                height: 1.25,
                letterSpacing: -0.3,
                color: AppColors.ink,
              ),
            ),
          ),
          const SizedBox(height: 14),
          GuessButtons(onGuess: onGuess),
          const SizedBox(height: 14),
          const HintButton(),
        ],
      ],
    );
  }

  /// One sentence on what the round teaches.
  String _lesson(GameRound round) {
    final rose = historyRose(round);
    final wentUp = roundOutcome(round) == Guess.higher;
    if (rose == wentUp) {
      return 'Cette fois, la courbe a continué sur sa lancée. Mais rien ne '
          'permettait de le savoir à l\'avance.';
    }
    final before = rose ? 'montait' : 'baissait';
    final after = wentUp ? 'elle est remontée' : 'elle a baissé';
    return 'La courbe $before depuis 6 mois, et pourtant $after ensuite. '
        'Le passé récent n\'annonce presque jamais la suite.';
  }
}

/// White card around the chart, with its caption.
class _ChartCard extends StatelessWidget {
  const _ChartCard({super.key, required this.round, required this.revealed});

  final GameRound round;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: revealed
                ? Text(
                    'C\'était ${round.assetName}, '
                    '${formatMonthRange(round.start, round.end)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  )
                : Text(
                    'Un actif mystère, ${round.history.length} semaines, '
                    'ramené à 100 au départ',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted,
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          MysteryChart(round: round, revealed: revealed),
        ],
      ),
    );
  }
}

/// End of the game: the score, what it means, and what to do next.
class _SummaryView extends StatelessWidget {
  const _SummaryView({
    required this.state,
    required this.stats,
    required this.onGoHome,
    required this.onReplay,
  });

  final GameState state;
  final GameStats stats;
  final VoidCallback onGoHome;
  final VoidCallback onReplay;

  /// The S&P 500 ETF: the long-term example the last card points to.
  static const _longTermSymbol = 'SPY';

  @override
  Widget build(BuildContext context) {
    final roundCount = state.rounds.length;

    return _GameLayout(
      actionBar: GameActionBar(
        secondaryLabel: 'Accueil',
        onSecondary: onGoHome,
        primaryLabel: 'Rejouer',
        onPrimary: onReplay,
      ),
      children: [
        ScoreCard(score: state.score, roundCount: roundCount),
        const SizedBox(height: 16),
        Text(
          _explanation(chanceVerdict(state.score)),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.45,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 16),
        StatsTiles(stats: stats, roundCount: roundCount),
        const SizedBox(height: 16),
        LongTermCard(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const AssetDetailScreen(symbol: _longTermSymbol),
            ),
          ),
        ),
      ],
    );
  }

  String _explanation(ChanceVerdict verdict) => switch (verdict) {
    ChanceVerdict.withinChance =>
      'Entre $chanceLowerBound et $chanceUpperBound bonnes réponses, le '
          'hasard suffit à expliquer ton score. Sur 4 semaines, personne ne '
          'prédit une courbe, ni toi ni les professionnels.',
    ChanceVerdict.aboveChance =>
      'Plus de $chanceUpperBound bonnes réponses : c\'est rare avec le seul '
          'hasard. Rejoue pour voir si cela se reproduit.',
    ChanceVerdict.belowChance =>
      'Moins de $chanceLowerBound bonnes réponses : c\'est rare avec le '
          'seul hasard, dans l\'autre sens. Rejoue pour voir si cela se '
          'reproduit.',
  };
}

/// Shown when there is no round to play.
class _Unavailable extends StatelessWidget {
  const _Unavailable();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Le jeu n\'est pas disponible pour l\'instant.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: AppColors.muted),
        ),
      ),
    );
  }
}
