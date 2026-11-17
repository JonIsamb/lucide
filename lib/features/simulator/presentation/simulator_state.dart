import '../../catalog/domain/instrument.dart';
import '../../catalog/domain/weekly_candle.dart';
import '../domain/projection.dart';
import '../domain/saved_simulation.dart';
import '../domain/simulation_error.dart';
import '../domain/simulation_params.dart';
import '../domain/simulation_result.dart';

/// The business states of the Simulations tab.
enum SimulatorPhase {
  /// Nothing computed yet (the form may be empty or half filled).
  unconfigured,

  /// The last attempt was refused: [SimulatorState.error] says why.
  invalid,

  /// A result is shown but not saved.
  computed,

  /// The result shown is saved.
  saved,
}

/// Where the prices of the chosen asset stand.
enum PricesStatus {
  /// Stored, or not asked for yet.
  ready,

  /// Being downloaded: the asset had none stored.
  downloading,

  /// The download failed (no network, quota, unknown symbol).
  failed,
}

const _unset = Object();

/// Everything the Simulations tab displays. Immutable: the controller
/// builds a new one for every change.
class SimulatorState {
  const SimulatorState({
    required this.instruments,
    required this.fxRates,
    required this.inflation,
    required this.saved,
    this.asset,
    this.candles = const [],
    this.pricesStatus = PricesStatus.ready,
    this.amount,
    this.buyDay,
    this.sellDay,
    this.envelope = Envelope.securitiesAccount,
    this.result,
    this.error,
    this.savedId,
    this.animateResult = true,
  });

  // Data read from the local database.
  final List<Instrument> instruments;
  final List<FxRate> fxRates;
  final Map<int, double> inflation;
  final List<SavedSimulation> saved;

  // The form. Null values are fields not filled (or unreadable).
  final Instrument? asset;

  /// Weekly prices of [asset], oldest first.
  final List<WeeklyCandle> candles;
  final PricesStatus pricesStatus;
  final double? amount;
  final DateTime? buyDay;
  final DateTime? sellDay;
  final Envelope envelope;

  // The outcome.
  final SimulationResult? result;
  final SimulationError? error;

  /// Id of the saved copy of [result], when it is saved.
  final int? savedId;

  /// False when a saved simulation is read again: numbers appear at once.
  final bool animateResult;

  SimulatorPhase get phase {
    if (result != null) {
      return savedId == null ? SimulatorPhase.computed : SimulatorPhase.saved;
    }
    return error == null ? SimulatorPhase.unconfigured : SimulatorPhase.invalid;
  }

  /// First and last day with a price, to bound the date pickers. Null
  /// while the asset has no stored prices.
  ({DateTime first, DateTime last})? get priceRange {
    if (candles.isEmpty) return null;
    return (
      first: candles.first.date,
      // A weekly candle covers 7 days.
      last: candles.last.date.add(const Duration(days: 6)),
    );
  }

  /// Last day a date picker accepts: a prediction may go past the last
  /// known price. Null while the asset has no stored prices.
  DateTime? get lastPickableDay =>
      candles.isEmpty ? null : lastProjectableDay(candles);

  /// A chosen date falls after the last known price: the result would be a
  /// prediction.
  bool get isPrediction {
    if (candles.isEmpty) return false;
    final known = lastKnownDay(candles);
    return (buyDay?.isAfter(known) ?? false) ||
        (sellDay?.isAfter(known) ?? false);
  }

  /// Assets the picker offers: only the PEA-eligible ones with a PEA.
  List<Instrument> get selectableInstruments => envelope == Envelope.pea
      ? [
          for (final i in instruments)
            if (i.peaEligible) i,
        ]
      : instruments;

  SimulatorState copyWith({
    List<FxRate>? fxRates,
    Map<int, double>? inflation,
    List<SavedSimulation>? saved,
    Object? asset = _unset,
    List<WeeklyCandle>? candles,
    PricesStatus? pricesStatus,
    Object? amount = _unset,
    Object? buyDay = _unset,
    Object? sellDay = _unset,
    Envelope? envelope,
    Object? result = _unset,
    Object? error = _unset,
    Object? savedId = _unset,
    bool? animateResult,
  }) {
    return SimulatorState(
      instruments: instruments,
      fxRates: fxRates ?? this.fxRates,
      inflation: inflation ?? this.inflation,
      saved: saved ?? this.saved,
      asset: identical(asset, _unset) ? this.asset : asset as Instrument?,
      candles: candles ?? this.candles,
      pricesStatus: pricesStatus ?? this.pricesStatus,
      amount: identical(amount, _unset) ? this.amount : amount as double?,
      buyDay: identical(buyDay, _unset) ? this.buyDay : buyDay as DateTime?,
      sellDay: identical(sellDay, _unset) ? this.sellDay : sellDay as DateTime?,
      envelope: envelope ?? this.envelope,
      result: identical(result, _unset)
          ? this.result
          : result as SimulationResult?,
      error: identical(error, _unset) ? this.error : error as SimulationError?,
      savedId: identical(savedId, _unset) ? this.savedId : savedId as int?,
      animateResult: animateResult ?? this.animateResult,
    );
  }
}
