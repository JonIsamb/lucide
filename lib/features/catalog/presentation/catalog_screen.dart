import 'package:flutter/material.dart';

import '../../../core/widgets/placeholder_view.dart';

/// Placeholder: this module is built in a later task.
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderView(
      title: 'Catalogue',
      icon: Icons.trending_up_rounded,
      message: 'Le catalogue arrive.',
    );
  }
}
