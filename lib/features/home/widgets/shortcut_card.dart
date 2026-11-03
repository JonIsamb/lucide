import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// One of the two square-ish cards under the simulation: an icon, a title
/// and a short line of context. The whole card is tappable.
class ShortcutCard extends StatelessWidget {
  const ShortcutCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.background = AppColors.surface,
    this.accent = AppColors.primary,
    this.subtitleColor = AppColors.muted,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color background;
  final Color accent;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: accent, size: 26),
              const SizedBox(height: 12),
              Text(title, style: textTheme.titleMedium?.copyWith(fontSize: 17)),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(color: subtitleColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
