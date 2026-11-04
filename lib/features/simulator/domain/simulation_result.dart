import 'simulation_params.dart';

/// The four steps between the announced gain and the real one.
enum CascadeStep {
  fx('Change'),
  fees('Frais'),
  tax('Impôt'),
  inflation('Inflation');

  const CascadeStep(this.label);
  final String label;
}

/// One bar of the cascade: how much a step moves the cumulative
/// performance (a fraction: −0.03 is −3 points).
class CascadeBar {
  const CascadeBar(this.step, this.delta);
  final CascadeStep step;
  final double delta;
}

/// Why a tax is zero although the sale made a gain.
enum TaxExemption { none, loss, crypto }

/// The outcome of a simulation. Every percentage is a fraction (0.2 = 20 %)
/// of the amount invested, so the steps add up exactly:
/// [grossPerformance] + the four bars = [realPerformance].
///
/// All values are stored, never recomputed: a saved simulation read later
/// shows exactly what was computed at the time.
class SimulationResult {
  const SimulationResult({
    required this.params,
    required this.buyPrice,
    required this.sellPrice,
    required this.buyFxRate,
    required this.sellFxRate,
    required this.grossPerformance,
    required this.eurPerformance,
    required this.afterFeesPerformance,
    required this.afterTaxPerformance,
    required this.realPerformance,
    required this.buyFee,
    required this.sellFee,
    required this.annualFees,
    required this.taxBase,
    required this.taxRate,
    required this.tax,
    required this.taxExemption,
    required this.cumulativeInflation,
    required this.inflationIsEstimate,
    required this.holdingDays,
  });

  final SimulationParams params;

  /// Closing prices in the asset currency.
  final double buyPrice;
  final double sellPrice;

  /// USD per EUR on each day. Null for an asset quoted in euros.
  final double? buyFxRate;
  final double? sellFxRate;

  /// 1. Price move in the asset currency.
  final double grossPerformance;

  /// 2. The same, in euros.
  final double eurPerformance;

  /// 3. After the broker and yearly fees.
  final double afterFeesPerformance;

  /// 4. After tax.
  final double afterTaxPerformance;

  /// 5. After inflation: the gain in purchasing power.
  final double realPerformance;

  /// Euros.
  final double buyFee;
  final double sellFee;
  final double annualFees;

  /// Sale proceeds minus acquisition cost, fees included. Euros.
  final double taxBase;

  /// Rate that applies (fraction), even when the tax ends up zero.
  final double taxRate;
  final double tax;
  final TaxExemption taxExemption;

  final double cumulativeInflation;
  final bool inflationIsEstimate;
  final int holdingDays;

  double get totalFees => buyFee + sellFee + annualFees;

  /// What the investment was worth before anything was taken off.
  double get announcedValue => params.amount * (1 + grossPerformance);

  /// What it is worth in today's euros, after everything.
  double get realValue => params.amount * (1 + realPerformance);

  double get announcedGain => announcedValue - params.amount;
  double get realGain => realValue - params.amount;

  List<CascadeBar> get bars => [
    CascadeBar(CascadeStep.fx, eurPerformance - grossPerformance),
    CascadeBar(CascadeStep.fees, afterFeesPerformance - eurPerformance),
    CascadeBar(CascadeStep.tax, afterTaxPerformance - afterFeesPerformance),
    CascadeBar(CascadeStep.inflation, realPerformance - afterTaxPerformance),
  ];

  Map<String, dynamic> toJson() => {
    'params': params.toJson(),
    'buyPrice': buyPrice,
    'sellPrice': sellPrice,
    'buyFxRate': buyFxRate,
    'sellFxRate': sellFxRate,
    'grossPerformance': grossPerformance,
    'eurPerformance': eurPerformance,
    'afterFeesPerformance': afterFeesPerformance,
    'afterTaxPerformance': afterTaxPerformance,
    'realPerformance': realPerformance,
    'buyFee': buyFee,
    'sellFee': sellFee,
    'annualFees': annualFees,
    'taxBase': taxBase,
    'taxRate': taxRate,
    'tax': tax,
    'taxExemption': taxExemption.name,
    'cumulativeInflation': cumulativeInflation,
    'inflationIsEstimate': inflationIsEstimate,
    'holdingDays': holdingDays,
  };

  factory SimulationResult.fromJson(Map<String, dynamic> json) {
    double number(String key) => (json[key] as num).toDouble();
    double? optional(String key) => (json[key] as num?)?.toDouble();
    return SimulationResult(
      params: SimulationParams.fromJson(json['params'] as Map<String, dynamic>),
      buyPrice: number('buyPrice'),
      sellPrice: number('sellPrice'),
      buyFxRate: optional('buyFxRate'),
      sellFxRate: optional('sellFxRate'),
      grossPerformance: number('grossPerformance'),
      eurPerformance: number('eurPerformance'),
      afterFeesPerformance: number('afterFeesPerformance'),
      afterTaxPerformance: number('afterTaxPerformance'),
      realPerformance: number('realPerformance'),
      buyFee: number('buyFee'),
      sellFee: number('sellFee'),
      annualFees: number('annualFees'),
      taxBase: number('taxBase'),
      taxRate: number('taxRate'),
      tax: number('tax'),
      taxExemption: TaxExemption.values.byName(json['taxExemption'] as String),
      cumulativeInflation: number('cumulativeInflation'),
      inflationIsEstimate: json['inflationIsEstimate'] as bool,
      holdingDays: (json['holdingDays'] as num).toInt(),
    );
  }
}

/// A euro rate: how many dollars one euro buys on [day].
class FxRate {
  const FxRate(this.day, this.eurUsd);
  final DateTime day;
  final double eurUsd;
}
