import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// White rounded card holding rows separated by dividers.
class CatalogCard extends StatelessWidget {
  const CatalogCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
      // Clips the row ripples to the rounded corners.
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(indent: 16, endIndent: 16),
            children[i],
          ],
        ],
      ),
    );
  }
}
