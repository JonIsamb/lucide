import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../catalog/domain/asset_metrics.dart';
import '../../../catalog/presentation/widgets/asset_logo.dart';
import '../../domain/asset_detail.dart';
import '../../domain/chart_period.dart';
import 'detail_card.dart';

/// Top of the detail screen: who the asset is, its last price, the change
/// of the selected period and how fresh the data is.
class DetailHeader extends StatelessWidget {
  const DetailHeader({
    super.key,
    required this.detail,
    required this.period,
    required this.change,
    required this.isRefreshing,
  });

  final AssetDetail detail;
  final ChartPeriod period;

  /// Change over [period], in percent. Null when unknown.
  final double? change;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final instrument = detail.instrument;
    final price = detail.lastPrice;
    final change = this.change;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AssetLogo(instrument: instrument, url: detail.logoUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                instrument.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 26,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            DetailPill(text: '${instrument.type.label}, ${instrument.symbol}'),
            if (instrument.exchange != null)
              DetailPill(text: instrument.exchange!),
            DetailPill(
              text: instrument.peaEligible
                  ? 'Éligible PEA'
                  : 'Non éligible PEA',
            ),
          ],
        ),
        if (instrument.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            instrument.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              // Shrinks a long price ("108 420 €") instead of cutting it.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  price == null ? '—' : formatPrice(price, instrument.currency),
                  style: const TextStyle(
                    fontSize: 40,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            if (change != null) ...[
              const SizedBox(width: 10),
              DetailPill.trend(
                text: '${formatPercent(change)} sur ${period.label}',
                trend: trendColor(change),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        _Freshness(
          lastFetchedAt: detail.lastFetchedAt,
          isRefreshing: isRefreshing,
        ),
      ],
    );
  }
}

/// "Mis à jour le 5 octobre à 22:00", with a dot in the alert color when
/// the data is too old, or a small spinner while it is being refreshed.
class _Freshness extends StatelessWidget {
  const _Freshness({required this.lastFetchedAt, required this.isRefreshing});

  final DateTime? lastFetchedAt;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final fetched = lastFetchedAt;
    final stale = fetched != null && isStale(fetched, DateTime.now());
    final color = stale ? AppColors.fall : AppColors.muted;
    final text = fetched == null
        ? 'Cours jamais mis à jour'
        : 'Mis à jour le ${formatDateTime(fetched)}';

    return Semantics(
      liveRegion: true,
      label: isRefreshing
          ? 'Actualisation en cours'
          : stale
          ? '$text, données anciennes'
          : text,
      excludeSemantics: true,
      child: Row(
        children: [
          if (isRefreshing)
            const SizedBox.square(
              dimension: 10,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          else
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: stale ? AppColors.fall : AppColors.rise,
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              isRefreshing ? 'Actualisation…' : text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: stale ? FontWeight.w700 : FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
