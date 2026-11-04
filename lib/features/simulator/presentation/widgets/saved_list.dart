import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/saved_simulation.dart';

/// "Mes simulations": the saved ones, newest first. Their numbers are the
/// frozen ones, not recomputed.
class SavedList extends StatelessWidget {
  const SavedList({
    super.key,
    required this.saved,
    required this.onOpen,
    required this.onDelete,
  });

  final List<SavedSimulation> saved;
  final ValueChanged<SavedSimulation> onOpen;
  final ValueChanged<SavedSimulation> onDelete;

  @override
  Widget build(BuildContext context) {
    if (saved.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        Text('Mes simulations', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final item in saved)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: AppColors.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              onTap: () => onOpen(item),
              title: Text(
                item.result.params.assetName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                '${formatPercent(item.result.grossPerformance * 100)} annoncés, '
                '${formatPercent(item.result.realPerformance * 100)} en vrai',
              ),
              trailing: IconButton(
                tooltip: 'Supprimer',
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () => onDelete(item),
              ),
            ),
          ),
      ],
    );
  }
}
