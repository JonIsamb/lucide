import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/game_round.dart';
import '../../domain/game_verdict.dart';
import '../../domain/window_regime.dart';
import '../explanation_texts.dart';
import 'card_parts.dart';

/// Shown before the player bets: the company, the period and what the
/// stock market was going through. It only holds what was known at the end
/// of the visible weeks, never what happened in the hidden ones.
class ContextCard extends StatelessWidget {
  const ContextCard({super.key, required this.round, required this.analysis});

  final GameRound round;

  /// Analysis of the visible weeks only. Null when it cannot be computed.
  final WindowAnalysis? analysis;

  @override
  Widget build(BuildContext context) {
    final asset = round.asset;
    final analysis = this.analysis;
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
          if (asset.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(asset.description, style: CardText.body),
          ],
          const SizedBox(height: 8),
          Text(
            'Les ${round.history.length} semaines affichées couvrent la '
            'période ${formatMonthRange(round.start, round.visibleEnd)}'
            '${change == null ? '' : ' : ${formatPercent(change)} sur la période'}.',
            style: CardText.body,
          ),
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
                child: Text(
                  earningsSentence(announcement),
                  style: CardText.body,
                ),
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
      ),
    );
  }
}
