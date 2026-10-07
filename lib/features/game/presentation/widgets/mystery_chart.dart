import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/game_round.dart';
import '../../domain/game_verdict.dart';

/// The curve of a round: the visible weeks, then a hidden zone with a "?".
///
/// When [revealed] becomes true, the hidden weeks are drawn point by point.
class MysteryChart extends StatefulWidget {
  const MysteryChart({super.key, required this.round, required this.revealed});

  final GameRound round;
  final bool revealed;

  static const height = 190.0;

  /// Share of the width given to the visible weeks. The hidden weeks get
  /// more room per week than the visible ones, so the "?" and then the
  /// revealed line stay readable.
  static const historyShare = 0.775;

  @override
  State<MysteryChart> createState() => _MysteryChartState();
}

class _MysteryChartState extends State<MysteryChart>
    with SingleTickerProviderStateMixin {
  // Purely visual state: how much of the hidden weeks is drawn (0 to 1).
  late final AnimationController _reveal;

  @override
  void initState() {
    super.initState();
    _reveal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.revealed) _reveal.forward();
  }

  @override
  void didUpdateWidget(MysteryChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.revealed && !oldWidget.revealed) {
      _reveal.forward(from: 0);
    } else if (!widget.revealed) {
      _reveal.value = 0;
    }
  }

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final round = widget.round;
    final rose = roundOutcome(round) == Guess.higher;
    final outcomeColor = rose ? AppColors.rise : AppColors.fall;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          image: true,
          label: _semanticsLabel(round, rose),
          child: SizedBox(
            height: MysteryChart.height,
            child: AnimatedBuilder(
              animation: _reveal,
              builder: (context, _) => CustomPaint(
                painter: _MysteryChartPainter(
                  history: round.history,
                  future: round.future,
                  reveal: _reveal.value,
                  outcomeColor: outcomeColor,
                  outcomeTint: rose ? AppColors.riseTint : AppColors.fallTint,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        if (widget.revealed)
          Row(
            children: [
              // Takes the room left by the end date, and never overflows.
              Expanded(
                child: Text(
                  formatLongMonthYear(round.start),
                  overflow: TextOverflow.ellipsis,
                  style: _axisStyle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatLongMonthYear(round.end),
                style: _axisStyle.copyWith(
                  color: outcomeColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                flex: (MysteryChart.historyShare * 1000).round(),
                child: Text(
                  'il y a ${round.history.length} semaines',
                  style: _axisStyle,
                ),
              ),
              Expanded(
                flex: ((1 - MysteryChart.historyShare) * 1000).round(),
                // Shrinks on narrow phones instead of wrapping.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${round.future.length} semaines',
                    style: _axisStyle.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  String _semanticsLabel(GameRound round, bool rose) {
    if (round.history.isEmpty) return 'Courbe indisponible';
    final lastVisible = round.history.last.round();
    if (!widget.revealed || round.future.isEmpty) {
      return 'Courbe de ${round.history.length} semaines partant de 100 et '
          'finissant vers $lastVisible, suivie de ${round.future.length} '
          'semaines masquées';
    }
    return 'La courbe continue et ${rose ? 'monte' : 'baisse'} de '
        '$lastVisible à ${round.future.last.round()} sur les '
        '${round.future.length} semaines révélées';
  }
}

const _axisStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w700,
  color: AppColors.muted,
);

class _MysteryChartPainter extends CustomPainter {
  _MysteryChartPainter({
    required this.history,
    required this.future,
    required this.reveal,
    required this.outcomeColor,
    required this.outcomeTint,
  });

  final List<double> history;
  final List<double> future;

  /// 0: hidden weeks masked. 1: hidden weeks fully drawn.
  final double reveal;
  final Color outcomeColor;
  final Color outcomeTint;

  /// Room kept above and below the curve, so dots are never cut. The
  /// bottom one also fits the "100" label under the lowest point.
  static const _topPadding = 12.0;
  static const _bottomPadding = 24.0;

  /// Room kept on the sides for the round line caps and the last dot.
  static const _sidePadding = 7.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (history.length < 2) return;

    final splitX = size.width * MysteryChart.historyShare;
    final accent = Color.lerp(AppColors.primary, outcomeColor, reveal)!;

    // The hidden zone: sand while masked, tinted by the outcome after.
    final zone = RRect.fromLTRBR(
      splitX,
      0,
      size.width,
      size.height,
      const Radius.circular(10),
    );
    canvas.drawRRect(
      zone,
      Paint()..color = Color.lerp(AppColors.sand, outcomeTint, reveal)!,
    );
    _drawDashedLine(
      canvas,
      Offset(splitX, 0),
      Offset(splitX, size.height),
      Paint()
        ..color = accent
        ..strokeWidth = 1.5,
      dash: 5,
      gap: 5,
    );

    // The vertical scale only uses the visible weeks while the round is
    // played: otherwise the empty space would give the answer away. It
    // widens during the reveal to make room for the hidden weeks.
    final visibleLow = history.reduce((a, b) => a < b ? a : b);
    final visibleHigh = history.reduce((a, b) => a > b ? a : b);
    final all = [...history, ...future];
    final low = lerpDouble(
      visibleLow,
      all.reduce((a, b) => a < b ? a : b),
      reveal,
    )!;
    final high = lerpDouble(
      visibleHigh,
      all.reduce((a, b) => a > b ? a : b),
      reveal,
    )!;
    // A flat series is drawn as a centred line instead of dividing by zero.
    final range = high - low;
    final usableHeight = size.height - _topPadding - _bottomPadding;
    double y(double value) => range == 0
        ? size.height / 2
        : _topPadding + (1 - (value - low) / range) * usableHeight;

    double historyX(int i) =>
        _sidePadding + i / (history.length - 1) * (splitX - 2 * _sidePadding);
    final lastVisible = Offset(historyX(history.length - 1), y(history.last));
    double futureX(int i) =>
        lastVisible.dx +
        (i + 1) / future.length * (size.width - _sidePadding - lastVisible.dx);

    // Dotted reference line at the starting value (100).
    final baseY = y(history.first);
    _drawDashedLine(
      canvas,
      Offset(0, baseY),
      Offset(reveal > 0 ? size.width : splitX - 4, baseY),
      Paint()
        ..color = AppColors.divider
        ..strokeWidth = 1,
      dash: 3,
      gap: 4,
    );
    final baseLabel = _text(history.first.round().toString(), _axisStyle);
    // On the side the curve leaves free: under the line when the first
    // weeks go up, above it when they go down (if there is room above).
    final startsUp = history[1] >= history.first;
    final labelBelow = startsUp || baseY - 3 - baseLabel.height < 0;
    baseLabel.paint(
      canvas,
      Offset(0, labelBelow ? baseY + 3 : baseY - 3 - baseLabel.height),
    );

    // The "?" fades out as soon as the reveal starts.
    final questionOpacity = (1 - reveal * 4).clamp(0.0, 1.0);
    if (questionOpacity > 0) {
      final question = _text(
        '?',
        TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w900,
          color: AppColors.primary.withValues(alpha: questionOpacity),
        ),
      );
      question.paint(
        canvas,
        Offset(
          (splitX + size.width - question.width) / 2,
          (size.height - question.height) / 2,
        ),
      );
    }

    final historyPath = Path()..moveTo(historyX(0), y(history.first));
    for (var i = 1; i < history.length; i++) {
      historyPath.lineTo(historyX(i), y(history[i]));
    }
    canvas.drawPath(historyPath, _linePaint(AppColors.ink, 2.5));

    if (reveal > 0 && future.isNotEmpty) {
      final futurePath = Path()..moveTo(lastVisible.dx, lastVisible.dy);
      for (var i = 0; i < future.length; i++) {
        futurePath.lineTo(futureX(i), y(future[i]));
      }
      // Only the first part of the path is drawn: the line grows from one
      // point to the next as the animation advances.
      final metric = futurePath.computeMetrics().first;
      final drawnLength = metric.length * reveal;
      canvas.drawPath(
        metric.extractPath(0, drawnLength),
        _linePaint(outcomeColor, 3.5),
      );
      final tip = metric.getTangentForOffset(drawnLength)?.position;
      if (tip != null) _drawDot(canvas, tip, outcomeColor);
    }

    _drawDot(canvas, lastVisible, AppColors.ink);
  }

  Paint _linePaint(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  /// A dot with a white ring, so it stands out from the line under it.
  void _drawDot(Canvas canvas, Offset center, Color color) {
    canvas.drawCircle(center, 6.5, Paint()..color = AppColors.surface);
    canvas.drawCircle(center, 4.5, Paint()..color = color);
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset from,
    Offset to,
    Paint paint, {
    required double dash,
    required double gap,
  }) {
    final length = (to - from).distance;
    if (length <= 0) return;
    final direction = (to - from) / length;
    for (var start = 0.0; start < length; start += dash + gap) {
      final end = (start + dash).clamp(0.0, length);
      canvas.drawLine(from + direction * start, from + direction * end, paint);
    }
  }

  TextPainter _text(String text, TextStyle style) => TextPainter(
    text: TextSpan(
      text: text,
      style: style.copyWith(fontFamily: 'Nunito'),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  @override
  bool shouldRepaint(_MysteryChartPainter old) =>
      old.reveal != reveal ||
      old.history != history ||
      old.future != future ||
      old.outcomeColor != outcomeColor;
}
