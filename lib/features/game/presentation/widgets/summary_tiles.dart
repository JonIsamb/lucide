import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/game_round.dart';

/// Three small tiles: games played, best score, average score.
class StatsTiles extends StatelessWidget {
  const StatsTiles({super.key, required this.stats, required this.roundCount});

  final GameStats stats;
  final int roundCount;

  @override
  Widget build(BuildContext context) {
    final played = stats.gamesPlayed > 1 ? 'parties jouées' : 'partie jouée';

    // IntrinsicHeight gives the three tiles the height of the tallest one.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _Tile(value: '${stats.gamesPlayed}', label: played),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _Tile(
              value: '${stats.bestScore}/$roundCount',
              label: 'meilleur score',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _Tile(
              value: formatDecimal(stats.averageScore),
              label: 'moyenne',
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Green card that sends the player to a long-term chart: the lesson of
/// the game is to stop guessing and give investments time.
class LongTermCard extends StatelessWidget {
  const LongTermCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.riseTint,
      borderRadius: BorderRadius.circular(24),
      // Clips the ripple to the rounded corners.
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.rise,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plutôt que deviner, laisse du temps',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Vois ce qu\'a donné le S&P 500 sur 5 ans',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.rise,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
