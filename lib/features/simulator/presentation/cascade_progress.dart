// How the result animation is cut in time. One controller goes from 0 to 1;
// every number and bar reads its own slice of it, so they stay in step.

import 'package:flutter/animation.dart';

import '../domain/simulation_result.dart';

/// Slices of the timeline: the announced gain first, then the four steps
/// one after the other.
const _slices = <Interval>[
  Interval(0.00, 0.20, curve: Curves.easeOutCubic), // announced gain
  Interval(0.22, 0.42, curve: Curves.easeInOutCubic), // exchange
  Interval(0.42, 0.62, curve: Curves.easeInOutCubic), // fees
  Interval(0.62, 0.82, curve: Curves.easeInOutCubic), // tax
  Interval(0.82, 1.00, curve: Curves.easeInOutCubic), // inflation
];

/// How far slice [index] has gone at time [t]: 0 before it, 1 after it.
/// Index 0 is the announced gain, 1 to 4 the [CascadeStep]s in order.
double sliceProgress(double t, int index) => _slices[index].transform(t);

/// Cumulative performance at time [t] (a fraction). At 0 it is nothing, at
/// 1 it is the real performance; in between, each step moves it by its
/// share of the bar.
double runningPerformance(SimulationResult result, double t) {
  var value = result.grossPerformance * sliceProgress(t, 0);
  final bars = result.bars;
  for (var i = 0; i < bars.length; i++) {
    value += bars[i].delta * sliceProgress(t, i + 1);
  }
  return value;
}
