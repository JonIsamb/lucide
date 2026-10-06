import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';

/// "Mise à jour : 12/30" with a small spinner.
class RefreshProgressLabel extends StatelessWidget {
  const RefreshProgressLabel({
    super.key,
    required this.done,
    required this.total,
  });

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Row(
        children: [
          const SizedBox.square(
            dimension: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Mise à jour : $done/$total',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Banner shown above cached data when the last refresh failed.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.error, this.lastUpdate});

  final ApiException error;
  final DateTime? lastUpdate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isOffline = error.kind == ApiErrorKind.network;
    final date = lastUpdate == null
        ? ''
        : ' : données du ${formatDateTime(lastUpdate!)}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.sand,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isOffline ? Icons.cloud_off_rounded : Icons.error_outline_rounded,
            color: AppColors.ink,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isOffline ? 'Hors ligne' : 'Mise à jour impossible'}$date',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!isOffline) ...[
                  const SizedBox(height: 2),
                  Text(error.userMessage, style: textTheme.bodyMedium),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Cours du 5 octobre à 22:00", in the alert color when too old.
class LastUpdateLabel extends StatelessWidget {
  const LastUpdateLabel({
    super.key,
    required this.lastUpdate,
    required this.isStale,
  });

  final DateTime lastUpdate;
  final bool isStale;

  @override
  Widget build(BuildContext context) {
    final color = isStale ? AppColors.fall : AppColors.muted;
    final text = 'Cours du ${formatDateTime(lastUpdate)}';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isStale) ...[
          Icon(Icons.schedule_rounded, size: 16, color: color),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            text,
            semanticsLabel: isStale ? '$text, données anciennes' : text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: isStale ? FontWeight.w700 : null,
            ),
          ),
        ),
      ],
    );
  }
}

/// Full-screen message used for "no result" and "error without data".
class CatalogMessage extends StatelessWidget {
  const CatalogMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.buttonLabel,
    required this.onPressed,
    this.message,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        children: [
          Icon(icon, size: 44, color: AppColors.muted),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium,
          ),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              minimumSize: const Size(48, 48),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              textStyle: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}
