import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/asset_overview.dart';
import 'asset_logo.dart';
import 'favorite_button.dart';
import 'skeleton_box.dart';
import 'sparkline.dart';

/// One line of the catalogue: logo, name, price, sparkline, change, star.
///
/// The whole row opens the detail screen, except the star which has its
/// own tap target.
class AssetRow extends StatelessWidget {
  const AssetRow({
    super.key,
    required this.asset,
    required this.isLoading,
    required this.onTap,
    required this.onFavoritePressed,
  });

  final AssetOverview asset;

  /// True while a refresh runs: an asset without price shows a skeleton
  /// instead of "Cours indisponible".
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback onFavoritePressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final instrument = asset.instrument;
    final change = asset.yearlyChange;
    final trendColor = change == null
        ? AppColors.muted
        : change >= 0
        ? AppColors.rise
        : AppColors.fall;
    final price = asset.lastPrice;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 4, 10),
        child: Row(
          children: [
            AssetLogo(instrument: instrument, url: asset.logoUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    instrument.name,
                    style: textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  if (price != null)
                    Text(
                      '${instrument.type.label}, '
                      '${formatPrice(price, instrument.currency, compact: true)}',
                      style: textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: SkeletonBox(width: 90, height: 12),
                    )
                  else
                    Text(
                      '${instrument.type.label}, cours indisponible',
                      style: textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (price == null && isLoading)
              const SkeletonBox(width: 56 + 8 + 56, height: 20)
            else ...[
              // No sparkline without data: the name gets the space instead.
              if (asset.sparkline.length >= 2) ...[
                Sparkline(points: asset.sparkline, color: trendColor),
                const SizedBox(width: 8),
              ],
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 56),
                child: Text(
                  change == null ? '—' : formatPercent(change),
                  textAlign: TextAlign.end,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: trendColor,
                  ),
                ),
              ),
            ],
            FavoriteButton(
              isFavorite: asset.isFavorite,
              assetName: instrument.name,
              onPressed: onFavoritePressed,
            ),
          ],
        ),
      ),
    );
  }
}

/// A whole row still loading, for the first frame before the database
/// answers.
class AssetRowSkeleton extends StatelessWidget {
  const AssetRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          SkeletonBox(width: 40, height: 40, radius: 14),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 110, height: 14),
                SizedBox(height: 6),
                SkeletonBox(width: 80, height: 12),
              ],
            ),
          ),
          SkeletonBox(width: 56, height: 20),
        ],
      ),
    );
  }
}
