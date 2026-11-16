// What the costs took from the announced gain, and what is left: the
// numbers behind the bar of the home screen.

import 'simulation_result.dart';

/// Below this size (a fraction of the amount invested), a step took
/// nothing: what remains is floating point noise, not a cost.
const _negligible = 1e-9;

/// The parts of a bar where every part has a positive width.
///
/// The bar adds up to the announced gain plus the steps that added to it
/// (a favourable exchange rate, a period of deflation):
/// sum of [costs] + [remaining] = gross performance + favourable steps.
/// This follows from the cascade, where gross + every bar = real.
class GainBreakdown {
  const GainBreakdown({required this.costs, required this.remaining});

  /// The steps that lowered the performance, in cascade order, each with
  /// the size of what it took (a positive fraction of the amount
  /// invested). Steps that took nothing or added are left out.
  final List<CascadeBar> costs;

  /// The real performance: what is left in purchasing power (positive).
  final double remaining;
}

/// Splits [result] into what each cost took and what is left.
///
/// Null when nothing is left in purchasing power (real performance zero or
/// negative): a bar of "what is left" would have nothing to show.
GainBreakdown? gainBreakdown(SimulationResult result) {
  final remaining = result.realPerformance;
  // Written this way, a NaN performance also gives null.
  if (!(remaining > _negligible)) return null;
  return GainBreakdown(
    costs: [
      for (final bar in result.bars)
        if (bar.delta < -_negligible) CascadeBar(bar.step, -bar.delta),
    ],
    remaining: remaining,
  );
}
