import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/earnings_announcement.dart';
import '../../domain/game_round.dart';
import '../../domain/game_verdict.dart';
import '../../domain/window_regime.dart';
import '../explanation_texts.dart';
import 'card_parts.dart';

/// Shown before the player bets: the company, the period and what the
/// stock market was going through. It only holds what was known at the end
/// of the visible weeks, never what happened in the hidden ones.
///
/// Folded by default: only the company is shown (the chart caption above
/// already gives the period), so the question and the answer buttons stay
/// on screen. The player unfolds the rest on demand. Give it a key per
/// round to fold it again each round.
class ContextCard extends StatefulWidget {
  const ContextCard({super.key, required this.round, required this.analysis});

  final GameRound round;

  /// Analysis of the visible weeks only. Null when it cannot be computed.
  final WindowAnalysis? analysis;

  @override
  State<ContextCard> createState() => _ContextCardState();
}

class _ContextCardState extends State<ContextCard> {
  /// Purely visual state: whether the details are unfolded.
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final round = widget.round;
    final asset = round.asset;
    final analysis = widget.analysis;
    final change = historyChangePercent(round);
    final earnings = round.visibleEarnings;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${asset.type.label}, ${asset.symbol}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.muted,
                      ),
                    ),
                    Semantics(
                      header: true,
                      child: Text(
                        asset.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // On a narrow phone the label wraps instead of overflowing.
              Flexible(
                child: _ToggleButton(
                  expanded: _expanded,
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _expanded
                ? _details(
                    asset.description,
                    'Les ${round.history.length} semaines affichées couvrent '
                    'la période '
                    '${formatMonthRange(round.start, round.visibleEnd)}'
                    '${change == null ? '' : ' : ${formatPercent(change)} sur la période'}.',
                    analysis,
                    earnings,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  /// Everything below the company, shown once unfolded.
  Widget _details(
    String description,
    String period,
    WindowAnalysis? analysis,
    List<EarningsAnnouncement> earnings,
  ) {
    final round = widget.round;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(description, style: CardText.body),
        ],
        const SizedBox(height: 8),
        Text(period, style: CardText.body),
        if (analysis != null) ...[
          const SizedBox(height: 16),
          RegimeHeader(regime: analysis.regime),
          const SizedBox(height: 8),
          Text(regimeSentence(analysis), style: CardText.body),
          const SizedBox(height: 8),
          Text(regimeMeaning(analysis.regime), style: CardText.body),
        ],
        const SizedBox(height: 16),
        const SectionTitle('Ce qui se passait dans le monde'),
        const SizedBox(height: 8),
        if (round.contextEvents.isEmpty)
          const Text(noContextEventSentence, style: CardText.body)
        else
          for (final event in round.contextEvents)
            EventTile(event: event, cutoff: round.hiddenStart),
        if (earnings.isNotEmpty) ...[
          const SizedBox(height: 8),
          const SectionTitle('Résultats de l\'entreprise'),
          const SizedBox(height: 6),
          for (final announcement in earnings)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(earningsSentence(announcement), style: CardText.body),
            ),
        ],
        if (analysis != null) ...[
          const SizedBox(height: 16),
          const SectionTitle('Comment réagir dans ce marché'),
          const SizedBox(height: 6),
          for (final tip in regimeTips(analysis.regime)) TipRow(text: tip),
        ],
        const SizedBox(height: 12),
        const Text(contextDisclaimer, style: CardText.small),
      ],
    );
  }
}

/// "Voir le contexte" / "Masquer", at the right of the company name.
class _ToggleButton extends StatelessWidget {
  const _ToggleButton({required this.expanded, required this.onPressed});

  final bool expanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      expanded: expanded,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(
          expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
        ),
        label: Text(expanded ? 'Masquer' : 'Voir le contexte'),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
