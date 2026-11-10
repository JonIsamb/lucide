import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/features/simulator/domain/gain_breakdown.dart';
import 'package:lucide/features/simulator/domain/simulation_result.dart';

import '../../../helpers.dart';

double _sum(GainBreakdown b) =>
    b.costs.fold(0.0, (sum, cost) => sum + cost.delta) + b.remaining;

void main() {
  test('every cost takes its share, the parts add up to the gain', () {
    // +20 % announced: change 5, fees 1,5, tax 4,5, inflation 5,3 points.
    final breakdown = gainBreakdown(simulationResult())!;

    expect(breakdown.costs.map((c) => c.step), [
      CascadeStep.fx,
      CascadeStep.fees,
      CascadeStep.tax,
      CascadeStep.inflation,
    ]);
    expect(breakdown.costs.map((c) => c.delta), [
      closeTo(0.05, 1e-12),
      closeTo(0.015, 1e-12),
      closeTo(0.045, 1e-12),
      closeTo(0.053, 1e-12),
    ]);
    expect(breakdown.remaining, closeTo(0.037, 1e-12));
    expect(_sum(breakdown), closeTo(0.20, 1e-12));
  });

  test('every part is positive, so the bar can draw it', () {
    final breakdown = gainBreakdown(simulationResult())!;
    expect(breakdown.costs.every((c) => c.delta > 0), isTrue);
    expect(breakdown.remaining, greaterThan(0));
  });

  test('a favourable exchange rate is not a cost', () {
    final breakdown = gainBreakdown(simulationResult(fx: 0.03))!;

    expect(breakdown.costs.map((c) => c.step), isNot(contains(CascadeStep.fx)));
    // The bar then adds up to the gain plus what the change added.
    expect(_sum(breakdown), closeTo(0.20 + 0.03, 1e-12));
  });

  test('a step that took nothing is left out (no tax on a loss)', () {
    final breakdown = gainBreakdown(simulationResult(tax: 0))!;
    expect(
      breakdown.costs.map((c) => c.step),
      isNot(contains(CascadeStep.tax)),
    );
  });

  test('no cost at all: the whole bar is what is left', () {
    final breakdown = gainBreakdown(
      simulationResult(fx: 0, fees: 0, tax: 0, inflation: 0),
    )!;
    expect(breakdown.costs, isEmpty);
    expect(breakdown.remaining, closeTo(0.20, 1e-12));
  });

  test('nothing left in purchasing power: no breakdown', () {
    // Costs exactly equal to the gain.
    expect(
      gainBreakdown(
        simulationResult(
          gross: 0.10,
          fx: 0,
          fees: -0.04,
          tax: 0,
          inflation: -0.06,
        ),
      ),
      isNull,
    );
    // Costs bigger than the gain.
    expect(gainBreakdown(simulationResult(gross: 0.05)), isNull);
    // The price went down.
    expect(
      gainBreakdown(
        simulationResult(gross: -0.10, fx: 0, fees: 0, tax: 0, inflation: 0),
      ),
      isNull,
    );
  });

  test('a falling price saved by the exchange rate still has a bar', () {
    final breakdown = gainBreakdown(
      simulationResult(
        gross: -0.02,
        fx: 0.06,
        fees: -0.01,
        tax: 0,
        inflation: 0,
      ),
    )!;
    expect(breakdown.costs.single.step, CascadeStep.fees);
    expect(breakdown.remaining, closeTo(0.03, 1e-12));
  });

  test('an unreadable performance gives no breakdown', () {
    expect(
      gainBreakdown(
        simulationResult(
          gross: double.nan,
          fx: 0,
          fees: 0,
          tax: 0,
          inflation: 0,
        ),
      ),
      isNull,
    );
  });
}
