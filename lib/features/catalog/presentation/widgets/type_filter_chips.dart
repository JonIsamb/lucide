import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/instrument.dart';

/// "Tout", "Actions", "ETF", "Cryptos". The selected chip is filled in ink.
class TypeFilterChips extends StatelessWidget {
  const TypeFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  /// Null means "Tout".
  final InstrumentType? selected;
  final ValueChanged<InstrumentType?> onSelected;

  @override
  Widget build(BuildContext context) {
    final options = <(String, InstrumentType?)>[
      ('Tout', null),
      for (final type in InstrumentType.values) (type.pluralLabel, type),
    ];

    // Scrolls sideways on very narrow phones instead of overflowing.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (label, type) in options)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _Chip(
                label: label,
                isSelected: selected == type,
                onTap: () => onSelected(type),
              ),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      button: true,
      child: Material(
        color: isSelected ? AppColors.ink : AppColors.surface,
        shape: StadiumBorder(
          side: BorderSide(
            color: isSelected ? AppColors.ink : AppColors.divider,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
