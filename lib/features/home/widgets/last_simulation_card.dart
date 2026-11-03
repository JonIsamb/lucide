import 'package:flutter/material.dart';
import 'package:segmented_progress_bar/segmented_progress_bar.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';

/// Big card at the top of the home screen: the result of the last
/// simulation, and how much of the gain the costs ate.
class LastSimulationCard extends StatelessWidget {
  const LastSimulationCard({
    super.key,
    required this.title,
    required this.realGain,
    required this.nominalGain,
    required this.costs,
    required this.onDetailPressed,
  });

  /// "S&P 500, 1 000 € sur 2 ans".
  final String title;

  /// Gain in purchasing power, in % (what is left at the end).
  final double realGain;

  /// Gain announced by the price, in %.
  final double nominalGain;

  /// Each cost in % of the nominal gain: change, frais, impôt, inflation.
  final Map<String, double> costs;
  final VoidCallback onDetailPressed;

  @override
  Widget build(BuildContext context) {
    const onCard = Colors.white;
    final light = onCard.withValues(alpha: 0.85);

    final segments = [
      // Labels are drawn under the bar by us: the package would overlap them.
      for (final value in costs.values)
        ProgressSegment(value: value, color: AppColors.costSegment, label: ''),
      ProgressSegment(
        value: realGain,
        color: AppColors.remainSegment,
        label: '',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.simulationCard,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ta dernière simulation : $title',
            style: TextStyle(fontSize: 15, color: light),
          ),
          const SizedBox(height: 8),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 10,
            children: [
              Text(
                formatPercent(realGain),
                style: const TextStyle(
                  fontSize: 48,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  color: onCard,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  'gagnés en\npouvoir d\'achat',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: onCard,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'pour ${formatPercent(nominalGain, decimals: 0)} annoncés par le cours',
            style: TextStyle(fontSize: 15, color: light),
          ),
          const SizedBox(height: 16),
          Semantics(
            label:
                'Sur ${formatPercent(nominalGain, decimals: 0)}, '
                'il reste ${formatPercent(realGain)} après '
                '${costs.keys.join(', ')}',
            child: ExcludeSemantics(
              child: SegmentedProgressBar(
                segments: segments,
                height: 12,
                borderRadius: 6,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  _sentence(costs.keys),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: light,
                  ),
                ),
              ),
              Text(
                'Ce qu\'il reste',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: light,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: onDetailPressed,
            style: FilledButton.styleFrom(
              backgroundColor: onCard,
              foregroundColor: AppColors.simulationCard,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            child: const Text('Voir le détail'),
          ),
        ],
      ),
    );
  }

  /// ["change", "frais"] → "Change, frais".
  static String _sentence(Iterable<String> words) {
    final text = words.join(', ');
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
