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

/// "Voir un indice", with a dashed outline.
///
/// Disabled for now: what the hint shows is not defined yet. Pass
/// [onPressed] once it is.
class HintButton extends StatelessWidget {
  const HintButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _DashedBorderPainter(
        color: AppColors.primary.withValues(alpha: 0.45),
        radius: 16,
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lightbulb_outline_rounded, size: 18),
            SizedBox(width: 8),
            Text('Voir un indice'),
          ],
        ),
      ),
    );
  }
}

/// Flutter has no dashed border: this draws one around a rounded rectangle.
class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const _dash = 6.0;
  static const _gap = 5.0;
  static const _stroke = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          // Half the stroke inside, so the border is not cut at the edges.
          (Offset.zero & size).deflate(_stroke / 2),
          Radius.circular(radius),
        ),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke;

    for (final metric in outline.computeMetrics()) {
      for (var start = 0.0; start < metric.length; start += _dash + _gap) {
        canvas.drawPath(metric.extractPath(start, start + _dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
