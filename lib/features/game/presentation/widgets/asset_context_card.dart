import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../catalog/domain/instrument.dart';

/// Shown once a round is revealed: what the mystery asset really is, and
/// what its price did before and after the player's bet.
class AssetContextCard extends StatelessWidget {
  const AssetContextCard({
    super.key,
    required this.asset,
    required this.visibleWeeks,
    required this.visibleChangePercent,
    required this.hiddenWeeks,
    required this.hiddenChangePercent,
    required this.onOpenDetail,
  });

  final Instrument asset;
  final int visibleWeeks;

  /// Null when it cannot be computed: the line is then left out.
  final double? visibleChangePercent;
  final int hiddenWeeks;
  final double hiddenChangePercent;

  /// Opens the detail screen of [asset].
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final visibleChange = visibleChangePercent;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
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
          const SizedBox(height: 2),
          Text(
            asset.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          if (asset.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              asset.description,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: AppColors.ink,
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (visibleChange != null)
            _ChangeLine(
              label: 'Les $visibleWeeks semaines affichées',
              changePercent: visibleChange,
            ),
          _ChangeLine(
            label: 'Les $hiddenWeeks semaines suivantes',
            changePercent: hiddenChangePercent,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onOpenDetail,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
              ),
              child: const Text(
                'Voir la fiche de cet actif',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Les 26 semaines affichées        +12,3 %".
class _ChangeLine extends StatelessWidget {
  const _ChangeLine({required this.label, required this.changePercent});

  final String label;
  final double changePercent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatPercent(changePercent),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: changePercent > 0 ? AppColors.rise : AppColors.fall,
            ),
          ),
        ],
      ),
    );
  }
}
