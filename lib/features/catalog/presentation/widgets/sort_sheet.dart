import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/catalog_filters.dart';

/// Opens the bottom sheet and returns the chosen order (null if closed).
Future<CatalogSort?> showSortSheet(BuildContext context, CatalogSort current) {
  return showModalBottomSheet<CatalogSort>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              'Trier par',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final sort in CatalogSort.values)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              minTileHeight: 52,
              title: Text(
                sort.label,
                style: TextStyle(
                  fontWeight: sort == current
                      ? FontWeight.w800
                      : FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              trailing: sort == current
                  ? const Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              selected: sort == current,
              onTap: () => Navigator.pop(context, sort),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// "Variation sur 1 an ⌄" button above the list.
class SortButton extends StatelessWidget {
  const SortButton({super.key, required this.sort, required this.onPressed});

  final CatalogSort sort;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            sort.buttonLabel,
            semanticsLabel: 'Trier : ${sort.label}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 4),
          Icon(
            sort == CatalogSort.changeAsc
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            size: 22,
          ),
        ],
      ),
    );
  }
}
