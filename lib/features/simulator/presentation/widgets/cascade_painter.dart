import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/simulation_result.dart';
import '../cascade_progress.dart';

/// The waterfall chart: the announced gain on the left, one floating bar
/// per step, the real gain on the right.
///
/// It only draws. The animation value [t] (0 to 1) comes from the
/// controller of the screen that owns it.
class CascadePainter extends CustomPainter {
  CascadePainter({required this.result, required this.t});

  final SimulationResult result;
  final double t;

  static const _labels = [
    'Annoncé',
    'Change',
    'Frais',
    'Impôt',
    'Inflation',
    'Réel',
  ];
  static const _labelHeight = 22.0;

  @override
  void paint(Canvas canvas, Size size) {
    final bars = result.bars;

    // Cumulative values at the end of the animation, to fix the scale
    // once: bars grow inside a stable frame.
    final ends = <double>[0, result.grossPerformance];
    for (final bar in bars) {
      ends.add(ends.last + bar.delta);
    }
    final low = ends
        .reduce((a, b) => a < b ? a : b)
        .clamp(double.negativeInfinity, 0.0);
    final high = ends
        .reduce((a, b) => a > b ? a : b)
        .clamp(0.0, double.infinity);
    final span = (high - low) == 0 ? 1.0 : high - low;

    final plotHeight = size.height - _labelHeight;
    double y(double value) => plotHeight * (1 - (value - low) / span);

    final columnWidth = size.width / _labels.length;
    final barWidth = columnWidth * 0.58;

    // Zero line.
    canvas.drawLine(
      Offset(0, y(0)),
      Offset(size.width, y(0)),
      Paint()
        ..color = AppColors.divider
        ..strokeWidth = 1.5,
    );

    double left(int column) =>
        column * columnWidth + (columnWidth - barWidth) / 2;

    // Announced gain: from 0 up to its (growing) value.
    final announced = result.grossPerformance * sliceProgress(t, 0);
    _drawBar(canvas, left(0), barWidth, y(0), y(announced), AppColors.ink);

    // Steps: each bar starts where the previous cumulative value stopped.
    var start = result.grossPerformance;
    for (var i = 0; i < bars.length; i++) {
      final delta = bars[i].delta;
      final end = start + delta * sliceProgress(t, i + 1);
      final color = delta < 0 ? AppColors.fall : AppColors.rise;
      if (sliceProgress(t, i + 1) > 0) {
        _drawBar(canvas, left(i + 1), barWidth, y(start), y(end), color);
      }
      start += delta;
    }

    // Real gain: appears with the last step and follows the running total.
    if (sliceProgress(t, 4) > 0) {
      final running = runningPerformance(result, t);
      _drawBar(canvas, left(5), barWidth, y(0), y(running), AppColors.primary);
    }

    for (var i = 0; i < _labels.length; i++) {
      final painter = TextPainter(
        text: TextSpan(
          text: _labels[i],
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: columnWidth);
      painter.paint(
        canvas,
        Offset(
          i * columnWidth + (columnWidth - painter.width) / 2,
          plotHeight + 6,
        ),
      );
    }
  }

  void _drawBar(
    Canvas canvas,
    double x,
    double width,
    double y0,
    double y1,
    Color color,
  ) {
    final rect = Rect.fromLTRB(
      x,
      y0 < y1 ? y0 : y1,
      x + width,
      y0 < y1 ? y1 : y0,
    );
    if (rect.height < 0.5) return;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(CascadePainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.result != result;
}
