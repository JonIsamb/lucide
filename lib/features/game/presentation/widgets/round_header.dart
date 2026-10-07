import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// "Manche 7 sur 20", the running score and one small bar per round.
class RoundHeader extends StatelessWidget {
  const RoundHeader({
    super.key,
    required this.roundIndex,
    required this.roundCount,
    required this.answered,
    required this.score,
  });

  /// Round on screen, starting at 0.
  final int roundIndex;
  final int roundCount;

  /// Rounds already answered (includes the current one once revealed).
  final int answered;
  final int score;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final good = score > 1 ? 'bonnes' : 'bonne';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  'Manche ${roundIndex + 1} sur $roundCount',
                  style: textTheme.headlineMedium?.copyWith(
                    fontSize: 26,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
            // Nothing to count before the first answer.
            if (answered > 0)
              Text(
                '$score $good sur $answered',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        // Decorative: the title already says which round it is.
        ExcludeSemantics(
          child: Row(
            children: [
              for (var i = 0; i < roundCount; i++) ...[
                if (i > 0) const SizedBox(width: 3),
                Expanded(child: _Segment(color: _segmentColor(i))),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Color _segmentColor(int index) {
    if (index < answered) return AppColors.primary;
    if (index == roundIndex) return AppColors.primary.withValues(alpha: 0.45);
    return AppColors.sand;
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
