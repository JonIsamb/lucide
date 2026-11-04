// The cascade: from the gain announced by the price to the gain in
// purchasing power. Pure functions, no clock, no I/O.

import '../../catalog/domain/instrument.dart';
import '../../catalog/domain/weekly_candle.dart';
import 'fiscal_rules_2026.dart';
import 'fisher.dart';
import 'simulation_error.dart';
import 'simulation_params.dart';
import 'simulation_result.dart';

/// Either a [result] or the [error] to show. Exactly one is set.
class SimulationOutcome {
  const SimulationOutcome.success(SimulationResult this.result) : error = null;
  const SimulationOutcome.failure(SimulationError this.error) : result = null;

  final SimulationResult? result;
  final SimulationError? error;
}

/// A weekly candle covers 7 days: a day is inside the history up to 6 days
/// after the first day of the last candle.
const _lastCandleCoverage = Duration(days: 6);

/// Close of the latest candle that started on or before [day]: a day
/// without a price takes the last earlier one. Null before the first candle.
///
/// [candles] are sorted, oldest first.
double? closeOnOrBefore(List<WeeklyCandle> candles, DateTime day) {
  double? close;
  for (final candle in candles) {
    if (candle.date.isAfter(day)) break;
    close = candle.close;
  }
  return close;
}

/// Euro rate of the latest day on or before [day] (no quote on weekends).
/// Null before the first rate. [rates] are sorted, oldest first.
double? fxOnOrBefore(List<FxRate> rates, DateTime day) {
  double? rate;
  for (final entry in rates) {
    if (entry.day.isAfter(day)) break;
    rate = entry.eurUsd;
  }
  return rate;
}

/// Checks the form values that do not need any market data. Null when
/// they are all fine.
SimulationError? validateParams(SimulationParams params) {
  if (!(params.amount > 0)) return SimulationError.amountNotPositive;
  if (!params.buyDay.isBefore(params.sellDay)) {
    return SimulationError.datesInverted;
  }
  if (params.envelope == Envelope.pea && !params.peaEligible) {
    return SimulationError.peaNotEligible;
  }
  final brokerage = params.brokerageValue;
  final brokerageLimit = params.brokerageKind == BrokerageKind.percent
      ? maxBrokeragePercent
      : params.amount;
  if (brokerage < 0 || brokerage > brokerageLimit) {
    return SimulationError.brokerageOutOfRange;
  }
  if (params.annualFeePercent < 0 ||
      params.annualFeePercent > maxAnnualFeePercent) {
    return SimulationError.annualFeeOutOfRange;
  }
  return null;
}

/// Runs the five steps of the cascade.
///
/// Every step is a cumulative performance (a fraction of the amount
/// invested); a bar is the gap between two successive ones, so the bars
/// always add up to the final result.
///
/// [candles] and [fxRates] are sorted, oldest first. [inflationPercent]
/// maps a year to the yearly rate in %.
SimulationOutcome runSimulation({
  required SimulationParams params,
  required List<WeeklyCandle> candles,
  required List<FxRate> fxRates,
  required Map<int, double> inflationPercent,
}) {
  final invalid = validateParams(params);
  if (invalid != null) return SimulationOutcome.failure(invalid);
  if (candles.isEmpty) {
    return const SimulationOutcome.failure(SimulationError.noPrices);
  }
  if (params.buyDay.isBefore(candles.first.date)) {
    return const SimulationOutcome.failure(SimulationError.buyBeforeHistory);
  }
  if (params.sellDay.isAfter(candles.last.date.add(_lastCandleCoverage))) {
    return const SimulationOutcome.failure(SimulationError.sellAfterHistory);
  }
  final buyPrice = closeOnOrBefore(candles, params.buyDay);
  final sellPrice = closeOnOrBefore(candles, params.sellDay);
  if (buyPrice == null ||
      sellPrice == null ||
      buyPrice <= 0 ||
      sellPrice <= 0) {
    return const SimulationOutcome.failure(SimulationError.noPrices);
  }

  // 1. Gross performance, in the currency of the asset.
  final gross = sellPrice / buyPrice - 1;

  // 2. Performance in euros. Euro-quoted assets have no exchange effect.
  double? buyFx;
  double? sellFx;
  var inEuros = gross;
  if (params.currency != 'EUR') {
    buyFx = fxOnOrBefore(fxRates, params.buyDay);
    sellFx = fxOnOrBefore(fxRates, params.sellDay);
    if (buyFx == null || sellFx == null || buyFx <= 0 || sellFx <= 0) {
      return const SimulationOutcome.failure(SimulationError.fxMissing);
    }
    // A dollar price divided by dollars per euro is a euro price.
    inEuros = (sellPrice / sellFx) / (buyPrice / buyFx) - 1;
  }

  final inflation = cumulativeInflation(
    inflationPercent,
    params.buyDay,
    params.sellDay,
  );
  if (inflation == null) {
    return const SimulationOutcome.failure(SimulationError.inflationMissing);
  }

  final amount = params.amount;
  final saleValue = amount * (1 + inEuros);
  final holdingDays = params.sellDay.difference(params.buyDay).inDays;

  // 3. Fees: broker on both sides, yearly fees in proportion to the time.
  final isPercent = params.brokerageKind == BrokerageKind.percent;
  final buyFee = isPercent
      ? amount * params.brokerageValue / 100
      : params.brokerageValue;
  final sellFee = isPercent
      ? saleValue * params.brokerageValue / 100
      : params.brokerageValue;
  final annualFees = amount * params.annualFeePercent / 100 * holdingDays / 365;
  final proceeds = saleValue - sellFee - annualFees;
  final acquisitionCost = amount + buyFee;
  final afterFees = (proceeds - acquisitionCost) / amount;

  // 4. Tax on the gain, fees included. No gain, no tax.
  final taxBase = proceeds - acquisitionCost;
  final taxRate = _taxRate(params);
  var exemption = TaxExemption.none;
  var tax = taxBase > 0 ? taxBase * taxRate : 0.0;
  if (taxBase <= 0) {
    exemption = TaxExemption.loss;
  } else if (params.assetType == InstrumentType.crypto &&
      saleValue <= cryptoExemptionThresholdEur) {
    exemption = TaxExemption.crypto;
    tax = 0;
  }
  final afterTax = (taxBase - tax) / amount;

  // 5. Purchasing power.
  final real = fisherRealReturn(afterTax, inflation.cumulative);

  return SimulationOutcome.success(
    SimulationResult(
      params: params,
      buyPrice: buyPrice,
      sellPrice: sellPrice,
      buyFxRate: buyFx,
      sellFxRate: sellFx,
      grossPerformance: gross,
      eurPerformance: inEuros,
      afterFeesPerformance: afterFees,
      afterTaxPerformance: afterTax,
      realPerformance: real,
      buyFee: buyFee,
      sellFee: sellFee,
      annualFees: annualFees,
      taxBase: taxBase,
      taxRate: taxRate,
      tax: tax,
      taxExemption: exemption,
      cumulativeInflation: inflation.cumulative,
      inflationIsEstimate: inflation.isEstimate,
      holdingDays: holdingDays,
    ),
  );
}

/// The rate of the flat tax for these parameters.
double _taxRate(SimulationParams params) {
  if (params.envelope == Envelope.pea) {
    final fiveYears = DateTime.utc(
      params.buyDay.year + peaHoldingYears,
      params.buyDay.month,
      params.buyDay.day,
    );
    return params.sellDay.isBefore(fiveYears)
        ? peaBeforeFiveYearsTaxRate
        : peaAfterFiveYearsTaxRate;
  }
  return securitiesAccountTaxRate;
}
