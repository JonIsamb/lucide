import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/features/catalog/domain/instrument.dart';
import 'package:lucide/features/catalog/domain/weekly_candle.dart';
import 'package:lucide/features/simulator/domain/fiscal_rules_2026.dart';
import 'package:lucide/features/simulator/domain/run_simulation.dart';
import 'package:lucide/features/simulator/domain/simulation_error.dart';
import 'package:lucide/features/simulator/domain/simulation_params.dart';
import 'package:lucide/features/simulator/domain/simulation_result.dart';

import '../../../helpers.dart';

final _buy = DateTime.utc(2020, 1, 6);

/// Two candles: [buyClose] on [_buy], [sellClose] five years later.
List<WeeklyCandle> _candles(double buyClose, double sellClose) => [
  candle(_buy, buyClose),
  candle(DateTime.utc(2025, 1, 6), sellClose),
];

const _inflation = {
  2020: 1.0,
  2021: 1.0,
  2022: 1.0,
  2023: 1.0,
  2024: 1.0,
  2025: 1.0,
};

final _fx = [
  FxRate(DateTime.utc(2020, 1, 1), 1.0),
  FxRate(DateTime.utc(2025, 1, 1), 1.0),
];

SimulationParams _params({
  InstrumentType type = InstrumentType.stock,
  String currency = 'EUR',
  bool peaEligible = true,
  double amount = 1000,
  DateTime? buyDay,
  DateTime? sellDay,
  Envelope envelope = Envelope.securitiesAccount,
  BrokerageKind kind = BrokerageKind.percent,
  double brokerage = 0,
  double annualFee = 0,
}) => SimulationParams(
  symbol: 'X',
  assetName: 'X',
  assetType: type,
  currency: currency,
  peaEligible: peaEligible,
  amount: amount,
  buyDay: buyDay ?? _buy,
  sellDay: sellDay ?? DateTime.utc(2025, 1, 6),
  envelope: envelope,
  brokerageKind: kind,
  brokerageValue: brokerage,
  annualFeePercent: annualFee,
);

SimulationOutcome _run(
  SimulationParams params, {
  List<WeeklyCandle>? candles,
  List<FxRate>? fx,
  Map<int, double> inflation = _inflation,
}) => runSimulation(
  params: params,
  candles: candles ?? _candles(100, 120),
  fxRates: fx ?? _fx,
  inflationPercent: inflation,
);

void main() {
  group('cascade', () {
    test('the bars add up to the final result', () {
      final result = _run(
        _params(
          currency: 'USD',
          brokerage: 1,
          annualFee: 0.5,
          sellDay: DateTime.utc(2024, 6, 3),
        ),
        fx: [
          FxRate(DateTime.utc(2020, 1, 1), 1.1),
          FxRate(DateTime.utc(2024, 1, 1), 1.25),
        ],
      ).result!;
      final sum = result.bars.fold(
        result.grossPerformance,
        (s, b) => s + b.delta,
      );
      expect(sum, closeTo(result.realPerformance, 1e-12));
    });

    test('worked example: euro asset, no fees, securities account', () {
      final r = _run(_params()).result!;
      expect(r.grossPerformance, closeTo(0.2, 1e-12));
      expect(r.eurPerformance, closeTo(0.2, 1e-12));
      expect(r.tax, closeTo(200 * securitiesAccountTaxRate, 1e-9));
      expect(r.afterTaxPerformance, closeTo(0.2 * (1 - 0.314), 1e-12));
      expect(r.taxExemption, TaxExemption.none);
    });

    test('exchange effect: the dollar loses against the euro', () {
      // Price +20 % in dollars, but the euro went from 1.00 to 1.20 dollars.
      final r = _run(
        _params(currency: 'USD'),
        fx: [
          FxRate(DateTime.utc(2020, 1, 1), 1.0),
          FxRate(DateTime.utc(2025, 1, 1), 1.2),
        ],
      ).result!;
      expect(r.eurPerformance, closeTo(0.0, 1e-12));
      expect(r.bars.first.delta, closeTo(-0.2, 1e-12));
    });

    test('a weekend takes the last earlier rate', () {
      final r = _run(
        _params(currency: 'USD'),
        fx: [
          FxRate(DateTime.utc(2020, 1, 3), 1.1), // Friday before the buy day
          FxRate(DateTime.utc(2025, 1, 3), 1.1),
        ],
      ).result!;
      expect(r.buyFxRate, 1.1);
    });

    test('a loss pays no tax', () {
      final r = _run(_params(), candles: _candles(100, 80)).result!;
      expect(r.tax, 0);
      expect(r.taxExemption, TaxExemption.loss);
      expect(r.afterTaxPerformance, closeTo(-0.2, 1e-12));
    });

    test('fees count in the tax base', () {
      final r = _run(_params(brokerage: 10, kind: BrokerageKind.amount))
          .result!;
      // Proceeds 1200 − 10, cost 1000 + 10.
      expect(r.taxBase, closeTo(180, 1e-9));
      expect(r.buyFee, 10);
      expect(r.sellFee, 10);
    });

    test('yearly fees are prorated on the days held', () {
      final r = _run(_params(annualFee: 1)).result!;
      expect(r.annualFees, closeTo(1000 * 0.01 * r.holdingDays / 365, 1e-9));
    });

    test('same buy and sell price: nothing gained, nothing taxed', () {
      final r = _run(_params(), candles: _candles(100, 100)).result!;
      expect(r.grossPerformance, 0);
      expect(r.tax, 0);
    });
  });

  group('PEA', () {
    SimulationParams pea(DateTime sell) => _params(
      envelope: Envelope.pea,
      buyDay: DateTime.utc(2020, 1, 6),
      sellDay: sell,
    );
    final candles = [
      candle(DateTime.utc(2020, 1, 6), 100),
      candle(DateTime.utc(2025, 1, 6), 120),
    ];

    test('held exactly 5 years: lower rate', () {
      final r = _run(pea(DateTime.utc(2025, 1, 6)), candles: candles).result!;
      expect(r.taxRate, peaAfterFiveYearsTaxRate);
    });

    test('held one day less than 5 years: full rate', () {
      final r = _run(pea(DateTime.utc(2025, 1, 5)), candles: candles).result!;
      expect(r.taxRate, peaBeforeFiveYearsTaxRate);
    });

    test('refused when the asset is not eligible', () {
      final outcome = _run(_params(envelope: Envelope.pea, peaEligible: false));
      expect(outcome.error, SimulationError.peaNotEligible);
    });
  });

  group('cryptos', () {
    final crypto = InstrumentType.crypto;

    test('sales of 305 € or less are exempt', () {
      final r = _run(
        _params(type: crypto, amount: 152.5),
        candles: _candles(100, 200),
      ).result!;
      expect(r.taxExemption, TaxExemption.crypto);
      expect(r.tax, 0);
    });

    test('sales of 306 € are taxed', () {
      final r = _run(
        _params(type: crypto, amount: 153),
        candles: _candles(100, 200),
      ).result!;
      expect(r.taxExemption, TaxExemption.none);
      expect(r.tax, closeTo(153 * 0.314, 1e-9));
    });
  });

  group('validation', () {
    test('dates reversed or equal are refused', () {
      expect(
        _run(_params(buyDay: DateTime.utc(2025, 1, 6), sellDay: _buy)).error,
        SimulationError.datesInverted,
      );
      expect(_run(_params(sellDay: _buy)).error, SimulationError.datesInverted);
    });

    test('amount must be strictly positive', () {
      expect(_run(_params(amount: 0)).error, SimulationError.amountNotPositive);
      expect(
        _run(_params(amount: -5)).error,
        SimulationError.amountNotPositive,
      );
    });

    test('dates outside the history are refused', () {
      expect(
        _run(_params(buyDay: DateTime.utc(2019, 12, 31))).error,
        SimulationError.buyBeforeHistory,
      );
      expect(
        _run(_params(sellDay: DateTime.utc(2025, 1, 13))).error,
        SimulationError.sellAfterHistory,
      );
      // Still inside the last candle's week.
      expect(_run(_params(sellDay: DateTime.utc(2025, 1, 12))).error, isNull);
    });

    test('a day without price takes the last earlier close', () {
      final candles = [
        candle(DateTime.utc(2020, 1, 6), 100),
        candle(DateTime.utc(2020, 1, 13), 110),
        candle(DateTime.utc(2025, 1, 6), 120),
      ];
      final r = _run(
        _params(buyDay: DateTime.utc(2020, 1, 16)),
        candles: candles,
      ).result!;
      expect(r.buyPrice, 110);
    });

    test('empty history', () {
      expect(
        _run(_params(), candles: const []).error,
        SimulationError.noPrices,
      );
    });

    test('fees are bounded', () {
      expect(
        _run(_params(brokerage: 5.5)).error,
        SimulationError.brokerageOutOfRange,
      );
      expect(
        _run(_params(brokerage: 1001, kind: BrokerageKind.amount)).error,
        SimulationError.brokerageOutOfRange,
      );
      expect(
        _run(_params(annualFee: 6)).error,
        SimulationError.annualFeeOutOfRange,
      );
      expect(_run(_params(brokerage: -1)).error, isNotNull);
    });

    test('missing exchange rate', () {
      expect(
        _run(_params(currency: 'USD'), fx: const []).error,
        SimulationError.fxMissing,
      );
    });

    test('missing inflation', () {
      expect(
        _run(_params(), inflation: const {}).error,
        SimulationError.inflationMissing,
      );
    });

    test('recent year without rate: last known one, marked as estimate', () {
      final r = _run(_params(), inflation: const {2020: 2.0}).result!;
      expect(r.inflationIsEstimate, isTrue);
      expect(r.cumulativeInflation, greaterThan(0.1));
    });
  });

  test('the result survives a JSON round trip', () {
    final r = _run(_params(currency: 'USD', brokerage: 1)).result!;
    final copy = SimulationResult.fromJson(r.toJson());
    expect(copy.toJson(), r.toJson());
    expect(copy.params.buyDay, r.params.buyDay);
  });
}
