import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Bar pinned at the bottom of the game, above the tabs: one main button,
/// and an optional secondary one on its left.
class GameActionBar extends StatelessWidget {
  const GameActionBar({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  static const _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(18)),
  );
  static const _minimumSize = Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final secondaryLabel = this.secondaryLabel;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          if (secondaryLabel != null) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: onSecondary,
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.ink,
                  side: const BorderSide(color: AppColors.divider, width: 1.5),
                  minimumSize: _minimumSize,
                  shape: _shape,
                  textStyle: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: Text(secondaryLabel),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: FilledButton(
              onPressed: onPrimary,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: _minimumSize,
                shape: _shape,
                textStyle: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              child: Text(primaryLabel),
            ),
          ),
        ],
      ),
    );
  }
}
