import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_view.dart';

/// Placeholder: this module is built in a later task.
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderView(
      title: 'Teste ton intuition',
      icon: Icons.casino_outlined,
      message: 'Le jeu arrive bientôt : sauras-tu prédire une courbe ?',
    );
  }
}
