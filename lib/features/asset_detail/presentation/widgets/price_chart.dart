import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../catalog/domain/weekly_candle.dart';
import '../../domain/period_stats.dart';

/// Price curve of one period, drawn by hand with a [CustomPainter].
///
/// - The curve is traced from left to right in 700 ms each time the
///   series changes (new period, fresh data).
/// - The maximum drawdown is marked: peak, low, dashed lines and label.
/// - A finger on the chart shows the price and the date of that week.
class PriceChart extends StatefulWidget {
  const PriceChart({
    super.key,
    required this.candles,
    required this.points,
    required this.currency,
    required this.color,
    this.drawdown,
  });

  /// Candles of the period, oldest first.
  final List<WeeklyCandle> candles;

  /// Their closes scaled between 0 and 1 (see sparklinePoints).
  final List<double> points;
  final String currency;
  final Color color;

  /// Its indices point into [candles]. Not drawn when null or 0 %.
  final Drawdown? drawdown;

  @override
  State<PriceChart> createState() => _PriceChartState();
}

class _PriceChartState extends State<PriceChart>
    with SingleTickerProviderStateMixin {
  static const _height = 170.0;

  late final AnimationController _controller;
  late final Animation<double> _progress;

  /// Candle under the finger. Purely visual, so it stays in the widget.
  int? _touchIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(PriceChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Replay only when the curve really changes, not on every rebuild.
    if (!_sameSeries(oldWidget.candles, widget.candles)) {
      _touchIndex = null;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    // An AnimationController holds a ticker: always free it.
    _controller.dispose();
    super.dispose();
  }

  static bool _sameSeries(List<WeeklyCandle> a, List<WeeklyCandle> b) =>
      a.length == b.length &&
      (a.isEmpty || (a.first == b.first && a.last == b.last));

  void _touch(double dx, double width) {
    final last = widget.candles.length - 1;
    final index = (dx / width * last).round().clamp(0, last);
    if (index != _touchIndex) setState(() => _touchIndex = index);
  }

  void _release() {
    if (_touchIndex != null) setState(() => _touchIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    final candles = widget.candles;
    if (candles.length < 2) {
      return const SizedBox(
        height: _height,
        child: Center(
          child: Text(
            'Pas assez de données pour tracer la courbe.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.muted),
          ),
        ),
      );
    }

    final touched = _touchIndex == null ? null : candles[_touchIndex!];
    final drawdown = widget.drawdown;
    const captionStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: AppColors.muted,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Same height with or without a finger, so nothing jumps.
        SizedBox(
          height: 20,
          child: touched == null
              ? const Text('Clôtures hebdomadaires', style: captionStyle)
              : Text(
                  '${formatDay(touched.date)} · '
                  '${formatPrice(touched.close, widget.currency)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
        ),
        Semantics(
          image: true,
          label:
              'Cours de ${formatMonthYear(candles.first.date)} à '
              '${formatMonthYear(candles.last.date)}, de '
              '${formatPrice(candles.first.close, widget.currency)} à '
              '${formatPrice(candles.last.close, widget.currency)}',
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                // Horizontal drags only: the page still scrolls vertically.
                onTapDown: (d) => _touch(d.localPosition.dx, width),
                onTapUp: (_) => _release(),
                onTapCancel: _release,
                onHorizontalDragStart: (d) => _touch(d.localPosition.dx, width),
                onHorizontalDragUpdate: (d) =>
                    _touch(d.localPosition.dx, width),
                onHorizontalDragEnd: (_) => _release(),
                onHorizontalDragCancel: _release,
                child: AnimatedBuilder(
                  animation: _progress,
                  builder: (context, _) => CustomPaint(
                    size: Size(width, _height),
                    painter: _PriceChartPainter(
                      points: widget.points,
                      progress: _progress.value,
                      color: widget.color,
                      drawdown: drawdown,
                      drawdownLabel: drawdown == null
                          ? ''
                          : formatPercent(-drawdown.percent),
                      touchIndex: _touchIndex,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formatMonthYear(candles.first.date), style: captionStyle),
            Text(formatMonthYear(candles.last.date), style: captionStyle),
          ],
        ),
      ],
    );
  }
}

class _PriceChartPainter extends CustomPainter {
  _PriceChartPainter({
    required this.points,
    required this.progress,
    required this.color,
    required this.drawdown,
    required this.drawdownLabel,
    required this.touchIndex,
  });

  final List<double> points;

  /// 0: nothing drawn, 1: whole curve.
  final double progress;
  final Color color;
  final Drawdown? drawdown;
  final String drawdownLabel;
  final int? touchIndex;

  /// Room above and below the curve for the dots and the stroke.
  static const _margin = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final last = points.length - 1;
    final stepX = size.width / last;
    final usableHeight = size.height - 2 * _margin;

    // 1 is the highest price, but y grows downwards on screen.
    Offset at(int i) =>
        Offset(i * stepX, _margin + (1 - points[i]) * usableHeight);

    canvas.drawLine(
      Offset(0, size.height - 0.5),
      Offset(size.width, size.height - 0.5),
      Paint()
        ..color = AppColors.divider
        ..strokeWidth = 1,
    );

    // The curve stops at `progress`: whole segments, then a part of the
    // next one, so the line grows smoothly.
    final reached = progress * last;
    final whole = reached.floor();
    var end = at(0);
    final line = Path()..moveTo(end.dx, end.dy);
    for (var i = 1; i <= whole; i++) {
      end = at(i);
      line.lineTo(end.dx, end.dy);
    }
    if (whole < last) {
      end = Offset.lerp(at(whole), at(whole + 1), reached - whole)!;
      line.lineTo(end.dx, end.dy);
    }

    final area = Path.from(line)
      ..lineTo(end.dx, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(area, Paint()..color = color.withValues(alpha: 0.12));
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // The drawdown fades in during the last 30 % of the animation.
    final opacity = ((progress - 0.7) / 0.3).clamp(0.0, 1.0);
    final drawdown = this.drawdown;
    if (drawdown != null && drawdown.percent > 0 && opacity > 0) {
      _paintDrawdown(
        canvas,
        size,
        at(drawdown.peakIndex),
        at(drawdown.troughIndex),
        opacity,
      );
    }

    final touchIndex = this.touchIndex;
    if (touchIndex != null && touchIndex <= last) {
      final point = at(touchIndex);
      canvas.drawLine(
        Offset(point.dx, 0),
        Offset(point.dx, size.height),
        Paint()
          ..color = AppColors.ink.withValues(alpha: 0.25)
          ..strokeWidth = 1,
      );
      _paintDot(canvas, point, color, 1);
    }
  }

  void _paintDrawdown(
    Canvas canvas,
    Size size,
    Offset peak,
    Offset trough,
    double opacity,
  ) {
    final fall = AppColors.fall.withValues(alpha: opacity);
    final dashes = Paint()
      ..color = fall
      ..strokeWidth = 1.5;
    final corner = Offset(trough.dx, peak.dy);
    _paintDashedLine(canvas, peak, corner, dashes);
    _paintDashedLine(canvas, corner, trough, dashes);
    _paintDot(canvas, peak, AppColors.ink, opacity);
    _paintDot(canvas, trough, AppColors.fall, opacity);

    final label = TextPainter(
      text: TextSpan(
        text: drawdownLabel,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: fall,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    // To the right of the fall, or to its left near the edge.
    var x = trough.dx + 8;
    if (x + label.width > size.width) x = trough.dx - 8 - label.width;
    final y = ((peak.dy + trough.dy) / 2 - label.height / 2).clamp(
      0.0,
      size.height - label.height,
    );
    final origin = Offset(math.max(0, x), y);
    // A white plate keeps the label readable where it crosses the curve.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        (origin & label.size).inflate(3),
        const Radius.circular(6),
      ),
      Paint()..color = AppColors.surface.withValues(alpha: 0.9 * opacity),
    );
    label.paint(canvas, origin);
    label.dispose();
  }

  void _paintDot(Canvas canvas, Offset center, Color stroke, double opacity) {
    canvas.drawCircle(
      center,
      5,
      Paint()..color = AppColors.surface.withValues(alpha: opacity),
    );
    canvas.drawCircle(
      center,
      5,
      Paint()
        ..color = stroke.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _paintDashedLine(Canvas canvas, Offset from, Offset to, Paint paint) {
    const dash = 4.0;
    const gap = 4.0;
    final length = (to - from).distance;
    if (length == 0) return;
    final direction = (to - from) / length;
    for (var start = 0.0; start < length; start += dash + gap) {
      final stop = math.min(start + dash, length);
      canvas.drawLine(from + direction * start, from + direction * stop, paint);
    }
  }

  @override
  bool shouldRepaint(_PriceChartPainter old) =>
      old.progress != progress ||
      old.points != points ||
      old.color != color ||
      old.touchIndex != touchIndex ||
      old.drawdownLabel != drawdownLabel;
}
