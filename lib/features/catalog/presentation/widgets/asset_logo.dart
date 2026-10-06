import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/instrument.dart';

/// 40×40 rounded logo. Without a logo (or offline before the first
/// download), shows the ticker on a sand-colored square instead.
class AssetLogo extends StatelessWidget {
  const AssetLogo({super.key, required this.instrument, this.url});

  final Instrument instrument;
  final String? url;

  static const size = 40.0;

  @override
  Widget build(BuildContext context) {
    final fallback = _Initials(code: instrument.shortCode);
    final url = this.url;

    // Decorative: the name next to it is what a screen reader needs.
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox.square(
          dimension: size,
          child: url == null
              ? fallback
              : CachedNetworkImage(
                  // Downloaded once, then read from the phone's cache.
                  imageUrl: url,
                  fit: BoxFit.contain,
                  placeholder: (_, _) => fallback,
                  errorWidget: (_, _, _) => fallback,
                  imageBuilder: (_, image) => ColoredBox(
                    color: AppColors.surface,
                    child: Image(image: image, fit: BoxFit.contain),
                  ),
                ),
        ),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.sand,
      child: Padding(
        padding: const EdgeInsets.all(4),
        // FittedBox shrinks "GOOGL" so it fits like "V".
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              code,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
