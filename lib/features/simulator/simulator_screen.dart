import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_view.dart';

/// Placeholder: this module is built in a later task.
class SimulatorScreen extends StatelessWidget {
  const SimulatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderView(
      title: 'Simulations',
      icon: Icons.calculate_outlined,
      message: 'Ici, tu verras ce que tu aurais vraiment gagné.',
    );
  }
}
