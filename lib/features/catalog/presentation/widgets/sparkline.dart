import 'package:flutter/material.dart';

/// Small line chart of the last year, without axes (56×26 in the list).
class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.points,
    required this.color,
    this.width = 56,
    this.height = 26,
  });

  /// Values between 0 and 1, oldest first (see sparklinePoints).
  final List<double> points;
  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    // Decorative: the change in % next to it already says the same thing.
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size(width, height),
        painter: _SparklinePainter(points, color),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.points, this.color);

  final List<double> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    const stroke = 1.8;
    // Keep half the stroke inside so the line is never cut at the edges.
    final usableHeight = size.height - stroke;
    final stepX = size.width / (points.length - 1);

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = i * stepX;
      // 1 is the highest price, but y grows downwards on screen.
      final y = stroke / 2 + (1 - points[i]) * usableHeight;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.color != color || old.points != points;
}
