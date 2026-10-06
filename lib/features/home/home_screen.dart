import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_view.dart';

/// Placeholder: this module is built in a later task.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderView(
      title: 'Accueil',
      icon: Icons.home_outlined,
      message: 'L’accueil arrive bientôt.',
    );
  }
}
