import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/period_stats.dart';
import 'detail_card.dart';

/// Compact landmarks of the period: where the price stands between its
/// low and its high, then four small figures on a 2×2 grid.
class MarkersCard extends StatelessWidget {
  const MarkersCard({super.key, required this.stats, required this.currency});

  final PeriodStats stats;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final best = stats.bestWeek;
    final worst = stats.worstWeek;
    final volume = stats.averageVolume;
    final weeks = stats.weekCount;

    return DetailCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _RangeBar(stats: stats, currency: currency),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Marker(
                  label: 'Meilleure semaine',
                  value: best == null ? '—' : formatPercent(best.value),
                  valueColor: best == null
                      ? AppColors.ink
                      : trendColor(best.value),
                  detail: best == null ? null : formatDay(best.date),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Marker(
                  label: 'Pire semaine',
                  value: worst == null ? '—' : formatPercent(worst.value),
                  valueColor: worst == null
                      ? AppColors.ink
                      : trendColor(worst.value),
                  detail: worst == null ? null : formatDay(worst.date),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Marker(
                  label: 'Semaines en hausse',
                  value: weeks == 0
                      ? '—'
                      : formatPercent(
                          stats.risingWeeks / weeks * 100,
                          decimals: 0,
                          signed: false,
                        ),
                  detail: weeks == 0 ? null : '${stats.risingWeeks} sur $weeks',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                // Cryptos come without volume: show the depth of the
                // period instead of an empty cell.
                child: volume == null
                    ? _Marker(
                        label: 'Semaines observées',
                        value: '$weeks',
                        detail: 'cours hebdomadaires',
                      )
                    : _Marker(
                        label: 'Volume moyen',
                        value: formatCompactNumber(volume),
                        detail: 'titres par semaine',
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Low on the left, high on the right, and a dot for the last price.
class _RangeBar extends StatelessWidget {
  const _RangeBar({required this.stats, required this.currency});

  final PeriodStats stats;
  final String currency;

  static const _dot = 14.0;

  @override
  Widget build(BuildContext context) {
    final low = stats.low;
    final high = stats.high;
    final position = stats.rangePosition;
    final fromHigh = stats.fromHighPercent;

    const labelStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: AppColors.muted,
    );
    const valueStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w900);
    const dateStyle = TextStyle(fontSize: 12, color: AppColors.muted);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Plus bas', style: labelStyle),
            Text('Plus haut', style: labelStyle),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              low == null ? '—' : formatPrice(low.value, currency),
              style: valueStyle,
            ),
            Text(
              high == null ? '—' : formatPrice(high.value, currency),
              style: valueStyle,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ExcludeSemantics(
          child: SizedBox(
            height: _dot,
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  if (position != null)
                    Positioned(
                      left: position * (constraints.maxWidth - _dot),
                      child: Container(
                        width: _dot,
                        height: _dot,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(low == null ? '' : formatDay(low.date), style: dateStyle),
            Text(high == null ? '' : formatDay(high.date), style: dateStyle),
          ],
        ),
        if (fromHigh != null) ...[
          const SizedBox(height: 8),
          Text(
            fromHigh >= 0
                ? 'Le dernier cours est au plus haut de la période.'
                : 'Le dernier cours est à ${formatPercent(fromHigh)} '
                      'du plus haut.',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
        ],
      ],
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker({
    required this.label,
    required this.value,
    this.detail,
    this.valueColor = AppColors.ink,
  });

  final String label;
  final String value;
  final String? detail;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: valueColor,
          ),
        ),
        if (detail != null)
          Text(
            detail!,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
      ],
    );
  }
}
