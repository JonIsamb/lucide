import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/game_round.dart';

/// "Raté : −6,2 % en 4 semaines" or "Bien vu : +3,1 % en 4 semaines".
///
/// The color says whether the player was right, the arrow says what the
/// price did.
class RevealBanner extends StatelessWidget {
  const RevealBanner({
    super.key,
    required this.correct,
    required this.guess,
    required this.changePercent,
    required this.weeks,
  });

  final bool correct;
  final Guess guess;
  final double changePercent;
  final int weeks;

  @override
  Widget build(BuildContext context) {
    final color = correct ? AppColors.rise : AppColors.fall;
    final verdict = correct ? 'Bien vu' : 'Raté';
    final answer = guess == Guess.higher ? 'plus haut' : 'plus bas';

    // Announced by screen readers as soon as the answer is known.
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: correct ? AppColors.riseTint : AppColors.fallTint,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                changePercent > 0
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$verdict : ${formatPercent(changePercent)} '
                    'en $weeks semaines',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tu avais répondu $answer.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
