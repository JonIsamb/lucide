import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// White rounded card of the detail screen.
class DetailCard extends StatelessWidget {
  const DetailCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}

/// Small rounded label: "ETF, SPY", "+31,5 % sur 1 an".
class DetailPill extends StatelessWidget {
  const DetailPill({
    super.key,
    required this.text,
    this.color = AppColors.muted,
    this.background = AppColors.divider,
    this.fontSize = 13,
    this.fontWeight = FontWeight.w700,
  });

  /// Tinted pill for a change: green when up, red when down.
  DetailPill.trend({super.key, required this.text, required Color trend})
    : color = trend,
      background = trend.withValues(alpha: 0.12),
      fontSize = 15,
      fontWeight = FontWeight.w800;

  final String text;
  final Color color;
  final Color background;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        ),
      ),
    );
  }
}

/// Green, red or grey, depending on the direction of a change.
Color trendColor(double? change) => change == null
    ? AppColors.muted
    : change >= 0
    ? AppColors.rise
    : AppColors.fall;
