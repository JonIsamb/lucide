import 'package:flutter/material.dart';
import 'package:segmented_progress_bar/segmented_progress_bar.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../simulator/domain/gain_breakdown.dart';
import '../../simulator/domain/simulation_result.dart';
import '../home_texts.dart';

const _onCard = Colors.white;
final _light = _onCard.withValues(alpha: 0.85);

/// Big card at the top of the home screen: the result of the last saved
/// simulation, and how much of the gain the costs ate. The numbers are the
/// frozen ones, never recomputed.
class LastSimulationCard extends StatelessWidget {
  const LastSimulationCard({
    super.key,
    required this.result,
    required this.onDetailPressed,
  });

  final SimulationResult result;
  final VoidCallback onDetailPressed;

  @override
  Widget build(BuildContext context) {
    final real = result.realPerformance * 100;
    final announced = result.grossPerformance * 100;

    return _GreenCard(
      children: [
        Text(
          'Ta dernière simulation : ${simulationTitle(result.params)}',
          style: TextStyle(fontSize: 15, color: _light),
        ),
        const SizedBox(height: 8),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 10,
          children: [
            Text(
              formatPercent(real),
              style: const TextStyle(
                fontSize: 48,
                height: 1,
                fontWeight: FontWeight.w900,
                color: _onCard,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                realGainCaption(result.realPerformance),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _onCard,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'pour ${formatPercent(announced)} annoncés par le cours',
          style: TextStyle(fontSize: 15, color: _light),
        ),
        const SizedBox(height: 16),
        _GainBar(result: result),
        const SizedBox(height: 20),
        _CardButton(label: 'Voir le détail', onPressed: onDetailPressed),
      ],
    );
  }
}

/// What the costs took, then what is left. Replaced by a sentence when
/// nothing is left: the bar would have nothing to show.
class _GainBar extends StatelessWidget {
  const _GainBar({required this.result});

  final SimulationResult result;

  static final _labelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: _light,
  );

  @override
  Widget build(BuildContext context) {
    final breakdown = gainBreakdown(result);
    if (breakdown == null) {
      return Text(
        nothingLeftSentence(result),
        style: _labelStyle.copyWith(fontSize: 14),
      );
    }

    final costSteps = [for (final cost in breakdown.costs) cost.step];
    final costs = costsSentence(costSteps);
    final segments = [
      // Labels are drawn under the bar by us: the package would overlap them.
      for (final cost in breakdown.costs)
        ProgressSegment(
          value: cost.delta,
          color: AppColors.costSegment,
          label: '',
        ),
      ProgressSegment(
        value: breakdown.remaining,
        color: AppColors.remainSegment,
        label: '',
      ),
    ];
    final remaining = formatPercent(breakdown.remaining * 100);
    final announced = formatPercent(result.grossPerformance * 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: costs.isEmpty
              ? 'Sur $announced, il reste $remaining : rien n’a été retenu'
              : 'Sur $announced, il reste $remaining après '
                    '${costs.toLowerCase()}',
          child: ExcludeSemantics(
            child: SegmentedProgressBar(
              segments: segments,
              height: 12,
              borderRadius: 6,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ExcludeSemantics(
          child: Row(
            children: [
              Expanded(child: Text(costs, style: _labelStyle)),
              Text('Ce qu’il reste', style: _labelStyle),
            ],
          ),
        ),
      ],
    );
  }
}

/// Takes the place of [LastSimulationCard] when there is no simulation to
/// show: on the first launch, or when the saved ones cannot be read.
class SimulationInviteCard extends StatelessWidget {
  const SimulationInviteCard({
    super.key,
    required this.onStart,
    this.unreadable = false,
  });

  /// Opens the Simulations tab.
  final VoidCallback onStart;

  /// The saved simulations exist but could not be read.
  final bool unreadable;

  @override
  Widget build(BuildContext context) {
    return _GreenCard(
      children: [
        const Icon(Icons.calculate_outlined, color: _onCard, size: 30),
        const SizedBox(height: 12),
        Text(
          unreadable
              ? 'Tes simulations n’ont pas pu être lues'
              : 'Ce que tu aurais vraiment gagné',
          style: const TextStyle(
            fontSize: 22,
            height: 1.2,
            fontWeight: FontWeight.w900,
            color: _onCard,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          unreadable
              ? 'Tu peux en faire une nouvelle dans l’onglet Simulations.'
              : 'Choisis un actif, un montant et deux dates : tu verras ce '
                    'qu’il reste après change, frais, impôt et inflation. '
                    'Enregistre ta simulation pour la retrouver ici.',
          style: TextStyle(fontSize: 15, height: 1.4, color: _light),
        ),
        const SizedBox(height: 20),
        _CardButton(label: 'Faire une simulation', onPressed: onStart),
      ],
    );
  }
}

/// Grey block with the rough size of the card, while the database answers.
class SimulationCardSkeleton extends StatelessWidget {
  const SimulationCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: AppColors.skeleton,
        borderRadius: BorderRadius.circular(28),
      ),
    );
  }
}

class _GreenCard extends StatelessWidget {
  const _GreenCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.simulationCard,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _CardButton extends StatelessWidget {
  const _CardButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: _onCard,
        foregroundColor: AppColors.simulationCard,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      child: Text(label),
    );
  }
}
