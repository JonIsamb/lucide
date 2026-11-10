import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/earnings_hint.dart';

/// The hint of a round: the earnings announcements published during the
/// visible weeks, without the asset's name nor any date.
class HintCard extends StatelessWidget {
  const HintCard({super.key, required this.hints});

  final List<EarningsHint> hints;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Indice : les annonces de résultats',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (hints.isEmpty)
            const Text(
              'Aucune annonce de résultats connue sur ces semaines.',
              style: _textStyle,
            )
          else
            for (final hint in hints)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(_sentence(hint), style: _textStyle),
              ),
        ],
      ),
    );
  }

  static const _textStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: AppColors.ink,
  );

  /// "Il y a 3 semaines : résultats meilleurs que prévu (+6,3 %)."
  String _sentence(EarningsHint hint) {
    final when = switch (hint.weeksAgo) {
      0 => 'Cette semaine',
      1 => 'Il y a 1 semaine',
      final weeks => 'Il y a $weeks semaines',
    };
    final percent = hint.surprisePercent;
    final what = switch (hint.surprise) {
      EarningsSurprise.above =>
        'résultats meilleurs que prévu (${formatPercent(percent!)})',
      EarningsSurprise.below =>
        'résultats moins bons que prévu (${formatPercent(percent!)})',
      EarningsSurprise.inLine => 'résultats conformes aux attentes',
      EarningsSurprise.unknown => 'résultats publiés',
    };
    return '$when : $what.';
  }
}
