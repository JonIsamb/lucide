import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Placeholder for the asset detail screen ("fiche actif").
///
/// It already takes the symbol so the catalogue can navigate to it now,
/// and the real screen will keep the same constructor.
class AssetDetailScreen extends StatelessWidget {
  const AssetDetailScreen({super.key, required this.symbol});

  final String symbol;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(symbol),
      ),
      body: Center(
        child: Text(
          'La fiche de $symbol arrive bientôt.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
