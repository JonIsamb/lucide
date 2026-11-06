import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/game_round.dart';
import '../../domain/window_regime.dart';
import '../explanation_texts.dart';
import 'card_parts.dart';

/// "Expliquer la réponse": how the 30 weeks behaved (from the numbers),
/// what real events happened around them, and how to behave in such a
/// market. Shown only when the player asks for it, after the answer.
class ExplanationCard extends StatelessWidget {
  const ExplanationCard({
    super.key,
    required this.round,
    required this.analysis,
  });

  final GameRound round;

  /// Null when the prices cannot be analyzed: only the events are shown.
  final WindowAnalysis? analysis;

  @override
  Widget build(BuildContext context) {
    final analysis = this.analysis;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (analysis != null) ...[
            RegimeHeader(regime: analysis.regime),
            const SizedBox(height: 8),
            Text(regimeSentence(analysis), style: CardText.body),
            const SizedBox(height: 8),
            Text(regimeMeaning(analysis.regime), style: CardText.body),
            const SizedBox(height: 16),
          ],
          const SectionTitle('Pourquoi le cours a bougé'),
          const SizedBox(height: 8),
          if (round.events.isEmpty)
            const Text(noEventSentence, style: CardText.body)
          else
            for (final event in round.events) EventTile(event: event),
          if (round.earnings.isNotEmpty) ...[
            const SizedBox(height: 8),
            const SectionTitle('Résultats de l\'entreprise'),
            const SizedBox(height: 6),
            for (final announcement in round.earnings)
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
            const SectionTitle('Comment réagir'),
            const SizedBox(height: 6),
            for (final tip in regimeTips(analysis.regime)) TipRow(text: tip),
          ],
          const SizedBox(height: 12),
          const Text(explanationDisclaimer, style: CardText.small),
        ],
      ),
    );
  }
}
