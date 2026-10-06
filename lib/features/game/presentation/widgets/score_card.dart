import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/game_verdict.dart';

/// The big final score, with a gauge showing where it falls compared with
/// the scores a coin would get.
class ScoreCard extends StatelessWidget {
  const ScoreCard({super.key, required this.score, required this.roundCount});

  final int score;
  final int roundCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Partie terminée',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.sand,
            ),
          ),
          const SizedBox(height: 10),
          Semantics(
            label: '$score sur $roundCount',
            excludeSemantics: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$score',
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -3,
                    height: 1,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '/ $roundCount',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.sand,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Semantics(
            header: true,
            child: Text(
              _title(chanceVerdict(score)),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                height: 1.2,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 18),
          // Decorative: the paragraph under the card says the same thing.
          ExcludeSemantics(
            child: _ChanceGauge(score: score, roundCount: roundCount),
          ),
        ],
      ),
    );
  }

  String _title(ChanceVerdict verdict) => switch (verdict) {
    ChanceVerdict.belowChance => 'Moins bien qu\'une pièce de monnaie',
    ChanceVerdict.withinChance => 'Autant qu\'une pièce de monnaie',
    ChanceVerdict.aboveChance => 'Mieux qu\'une pièce de monnaie',
  };
}

/// A 0-to-20 track, a lighter band for the scores chance explains
/// (6 to 14), and a white dot at the player's score.
class _ChanceGauge extends StatelessWidget {
  const _ChanceGauge({required this.score, required this.roundCount});

  final int score;
  final int roundCount;

  static const _dotSize = 28.0;
  static const _trackHeight = 10.0;
  static const _labelStyle = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w800,
    color: AppColors.sand,
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Position of a score on the track, in pixels from the left.
        double at(int value) => width * value / roundCount;
        const trackTop = (_dotSize - _trackHeight) / 2;

        return Column(
          children: [
            SizedBox(
              height: _dotSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: trackTop,
                    height: _trackHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(_trackHeight / 2),
                      ),
                    ),
                  ),
                  Positioned(
                    left: at(chanceLowerBound),
                    width: at(chanceUpperBound) - at(chanceLowerBound),
                    top: trackTop,
                    height: _trackHeight,
                    child: const ColoredBox(color: AppColors.sand),
                  ),
                  Positioned(
                    // Kept inside the track at 0 and at 20.
                    left: (at(score) - _dotSize / 2).clamp(
                      0.0,
                      width - _dotSize,
                    ),
                    top: 0,
                    width: _dotSize,
                    height: _dotSize,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 18,
              child: Stack(
                children: [
                  const Positioned(
                    left: 0,
                    child: Text('0', style: _labelStyle),
                  ),
                  _centered(at(chanceLowerBound), '$chanceLowerBound'),
                  Positioned.fill(
                    child: Center(
                      child: Text(
                        'zone du hasard',
                        style: _labelStyle.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  _centered(at(chanceUpperBound), '$chanceUpperBound'),
                  Positioned(
                    right: 0,
                    child: Text('$roundCount', style: _labelStyle),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// A label centred on [x].
  Widget _centered(double x, String text) {
    const boxWidth = 30.0;
    return Positioned(
      left: x - boxWidth / 2,
      width: boxWidth,
      child: Text(text, textAlign: TextAlign.center, style: _labelStyle),
    );
  }
}
