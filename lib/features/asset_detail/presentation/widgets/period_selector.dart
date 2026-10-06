import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/chart_period.dart';
import 'detail_card.dart';

/// Segmented control "1 mois / 6 mois / 1 an / 5 ans". Each segment also
/// shows the change of its period, so the four are compared at a glance.
class PeriodSelector extends StatelessWidget {
  const PeriodSelector({
    super.key,
    required this.selected,
    required this.changes,
    required this.onSelected,
  });

  final ChartPeriod selected;

  /// Change of each period in percent. Null when unknown.
  final Map<ChartPeriod, double?> changes;
  final ValueChanged<ChartPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final period in ChartPeriod.values)
            Expanded(
              child: _Segment(
                period: period,
                change: changes[period],
                isSelected: period == selected,
                onTap: () => onSelected(period),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.period,
    required this.change,
    required this.isSelected,
    required this.onTap,
  });

  final ChartPeriod period;
  final double? change;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final change = this.change;
    final changeText = change == null ? '—' : formatPercent(change);

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${period.label}, variation $changeText',
      excludeSemantics: true,
      child: Material(
        color: isSelected ? AppColors.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 48,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  period.label,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.2,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                    color: isSelected ? AppColors.ink : AppColors.muted,
                  ),
                ),
                Text(
                  changeText,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: trendColor(change),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
