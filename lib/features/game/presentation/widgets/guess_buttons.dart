import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/game_round.dart';

/// The two big answers: "Plus haut" and "Plus bas".
class GuessButtons extends StatelessWidget {
  const GuessButtons({super.key, required this.onGuess});

  final ValueChanged<Guess> onGuess;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GuessButton(
            label: 'Plus haut',
            icon: Icons.arrow_upward_rounded,
            color: AppColors.rise,
            onPressed: () => onGuess(Guess.higher),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _GuessButton(
            label: 'Plus bas',
            icon: Icons.arrow_downward_rounded,
            color: AppColors.fall,
            onPressed: () => onGuess(Guess.lower),
          ),
        ),
      ],
    );
  }
}

class _GuessButton extends StatelessWidget {
  const _GuessButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(64),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 8),
          // Shrinks on narrow phones instead of overflowing.
          Flexible(
            child: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
          ),
        ],
      ),
    );
  }
}

/// "Expliquer la réponse": opens the explanation of a revealed round.
class ExplainButton extends StatelessWidget {
  const ExplainButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: const Icon(Icons.help_outline_rounded, size: 20),
      label: const Text('Expliquer la réponse'),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        backgroundColor: AppColors.lightGreen,
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
