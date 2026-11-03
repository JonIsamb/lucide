import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../asset_detail/presentation/widgets/detail_card.dart';
import '../../domain/simulation_result.dart';
import '../cascade_progress.dart';
import 'cascade_painter.dart';

/// How long the numbers take to settle.
const _animationDuration = Duration(milliseconds: 4200);

/// The result of one simulation: the counters and the cascade, animated,
/// then the detail of each step.
///
/// The widget owns the [AnimationController] (purely visual state). The
/// user can skip the animation at any time; the system setting "reduce
/// animations" skips it from the start.
class ResultView extends StatefulWidget {
  const ResultView({
    super.key,
    required this.result,
    required this.animate,
    required this.isSaved,
    required this.onSave,
    required this.onBack,
  });

  final SimulationResult result;

  /// False for a saved simulation read again: final values at once.
  final bool animate;
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onBack;

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // Read here, not in initState: MediaQuery is not available yet there.
    if (widget.animate && !MediaQuery.disableAnimationsOf(context)) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Jumps to the final values.
  void _skip() => _controller.value = 1;

  void _replay() => _controller.forward(from: 0);

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final params = result.params;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Modifier la simulation'),
          ),
        ),
        Text(
          params.assetName,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          '${params.envelope.label} · du ${formatDay(params.buyDay)} '
          'au ${formatDay(params.sellDay)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        // Only the animated parts rebuild at every frame.
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => _HeroCard(
            result: result,
            t: _controller.value,
            running: _controller.isAnimating,
            onSkip: _skip,
            onReplay: _replay,
          ),
        ),
        const SizedBox(height: 16),
        DetailCard(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'D’où vient la différence ?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => Semantics(
                  label: _chartDescription(result),
                  excludeSemantics: true,
                  child: GestureDetector(
                    // Tap the chart to skip the animation.
                    onTap: _controller.isAnimating ? _skip : null,
                    child: SizedBox(
                      height: 190,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: CascadePainter(
                          result: result,
                          t: _controller.value,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) =>
                    _StepRows(result: result, t: _controller.value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Notes(result: result),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: widget.isSaved ? null : widget.onSave,
          icon: Icon(
            widget.isSaved ? Icons.check_rounded : Icons.bookmark_add_outlined,
          ),
          label: Text(
            widget.isSaved ? 'Simulation sauvegardée' : 'Sauvegarder',
          ),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        ),
      ],
    );
  }

  String _chartDescription(SimulationResult r) =>
      'Gain annoncé ${formatPercent(r.grossPerformance * 100)}, '
      'gain réel en pouvoir d’achat ${formatPercent(r.realPerformance * 100)}.';
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.result,
    required this.t,
    required this.running,
    required this.onSkip,
    required this.onReplay,
  });

  final SimulationResult result;
  final double t;
  final bool running;
  final VoidCallback onSkip;
  final VoidCallback onReplay;

  @override
  Widget build(BuildContext context) {
    final announced = result.grossPerformance * sliceProgress(t, 0);
    final current = runningPerformance(result, t);
    final amount = result.params.amount;
    final done = t >= 1;
    final gained = result.realPerformance >= 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${formatPercent(announced * 100)} annoncés',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.sand,
            ),
          ),
          const SizedBox(height: 6),
          Semantics(
            // Read once, with the final value, not at every frame.
            label:
                'Gain réel en pouvoir d’achat '
                '${formatPercent(result.realPerformance * 100)}',
            excludeSemantics: true,
            child: Text(
              formatPercent(current * 100),
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                letterSpacing: -2,
                height: 1.05,
                color: Colors.white,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Text(
            gained ? 'gagnés en pouvoir d’achat' : 'perdus en pouvoir d’achat',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${formatPrice(amount, 'EUR')} investis  →  '
            '${formatPrice(amount * (1 + announced), 'EUR')} annoncés  →  '
            '${formatPrice(amount * (1 + current), 'EUR')} en vrai',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.sand,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: done
                ? TextButton.icon(
                    onPressed: onReplay,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.sand,
                    ),
                    icon: const Icon(Icons.replay_rounded, size: 18),
                    label: const Text('Rejouer l’animation'),
                  )
                : TextButton.icon(
                    onPressed: onSkip,
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    icon: const Icon(Icons.skip_next_rounded, size: 20),
                    label: const Text('Passer l’animation'),
                  ),
          ),
        ],
      ),
    );
  }
}

/// One line per step, with its number counting up as the step plays.
class _StepRows extends StatelessWidget {
  const _StepRows({required this.result, required this.t});

  final SimulationResult result;
  final double t;

  @override
  Widget build(BuildContext context) {
    final amount = result.params.amount;
    final bars = result.bars;
    return Column(
      children: [
        for (var i = 0; i < bars.length; i++)
          _StepRow(
            step: bars[i].step,
            delta: bars[i].delta * sliceProgress(t, i + 1),
            amount: amount,
            explanation: _explain(result, bars[i].step),
            visible: sliceProgress(t, i + 1),
          ),
      ],
    );
  }

  String _explain(SimulationResult r, CascadeStep step) {
    switch (step) {
      case CascadeStep.fx:
        if (r.buyFxRate == null) {
          return 'Actif coté en euros : pas d’effet de change.';
        }
        return 'Le cours est en dollars : un euro valait '
            '${formatDecimal(r.buyFxRate!, decimals: 4)} \$ à l’achat '
            'et ${formatDecimal(r.sellFxRate!, decimals: 4)} \$ à la vente.';
      case CascadeStep.fees:
        return 'Courtage ${formatPrice(r.buyFee + r.sellFee, 'EUR')} '
            'et frais annuels ${formatPrice(r.annualFees, 'EUR')}.';
      case CascadeStep.tax:
        return switch (r.taxExemption) {
          TaxExemption.loss => 'Pas de gain, donc pas d’impôt.',
          TaxExemption.crypto =>
            'Cessions de crypto de 305 € ou moins : pas d’impôt.',
          TaxExemption.none =>
            'Taux de ${formatPercent(r.taxRate * 100, signed: false)} '
                'sur un gain de ${formatPrice(r.taxBase, 'EUR')}.',
        };
      case CascadeStep.inflation:
        return 'Les prix ont monté de '
            '${formatPercent(r.cumulativeInflation * 100)} sur la période : '
            '100 € d’hier achètent moins aujourd’hui.';
    }
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.delta,
    required this.amount,
    required this.explanation,
    required this.visible,
  });

  final CascadeStep step;
  final double delta;
  final double amount;
  final String explanation;

  /// 0 to 1: the row fades in when its step starts.
  final double visible;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.25 + 0.75 * visible,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    explanation,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatPercent(delta * 100),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: trendColor(delta == 0 ? null : delta),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  formatPrice(delta * amount, 'EUR'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Notes extends StatelessWidget {
  const _Notes({required this.result});

  final SimulationResult result;

  @override
  Widget build(BuildContext context) {
    final notes = <String>[
      if (result.inflationIsEstimate)
        'Inflation estimée : l’année en cours n’est pas encore publiée, '
            'on a reconduit le dernier taux connu.',
      if (result.params.currency != 'EUR')
        'Cours non ajustés des dividendes : la performance des actifs qui en '
            'versent est sous-estimée.'
      else
        'Cours non ajustés des dividendes.',
      'Simulation pédagogique : aucune transaction réelle, taux d’impôt à '
          'vérifier avant toute décision.',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final note in notes)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(note, style: Theme.of(context).textTheme.bodySmall),
          ),
      ],
    );
  }
}
