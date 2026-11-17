import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catalog/domain/instrument.dart';
import '../../catalog/domain/weekly_candle.dart';
import '../data/simulator_repository.dart';
import '../domain/input_parsing.dart';
import '../domain/run_simulation.dart';
import '../domain/saved_simulation.dart';
import '../domain/simulation_error.dart';
import '../domain/simulation_params.dart';
import 'simulator_state.dart';

final simulatorControllerProvider =
    AsyncNotifierProvider<SimulatorController, SimulatorState>(
      SimulatorController.new,
      // No automatic retry: local reads either work or the app is broken.
      retry: (_, _) => null,
    );

/// Receives the user's actions on the Simulations tab and turns them into
/// a new [SimulatorState]. The calculation itself lives in `domain/`.
class SimulatorController extends AsyncNotifier<SimulatorState> {
  SimulatorRepository get _repository => ref.read(simulatorRepositoryProvider);

  /// Reads everything from the local database (the bundled seed fills the
  /// rates on the first launch), then refreshes the rates in the
  /// background.
  @override
  Future<SimulatorState> build() async {
    await _repository.seedIfEmpty();
    final loaded = SimulatorState(
      instruments: await _repository.loadInstruments(),
      fxRates: await _repository.loadFxRates(),
      inflation: await _repository.loadInflation(),
      saved: await _repository.loadSaved(),
    );
    Future.microtask(_refreshRates);
    return loaded;
  }

  /// Completes the local rates from the network. Failing is fine: the
  /// simulation keeps working with what is stored.
  Future<void> _refreshRates() async {
    try {
      if (!await _repository.refreshRates()) return;
      final current = state.value;
      if (!ref.mounted || current == null) return;
      state = AsyncData(
        current.copyWith(
          fxRates: await _repository.loadFxRates(),
          inflation: await _repository.loadInflation(),
        ),
      );
    } on Object {
      // Optional update, started in the background: whatever goes wrong
      // (no network, answer in an unexpected format, screen closed during
      // the download), the stored rates stay valid.
      return;
    }
  }

  // --- Form ------------------------------------------------------------------

  /// Picks the asset and proposes the last year of its history. An asset
  /// with no stored prices has them downloaded.
  Future<void> selectAsset(Instrument asset) async {
    final current = state.value;
    if (current == null) return;
    var candles = await _repository.loadCandles(asset.symbol);
    if (!ref.mounted) return;
    final needsDownload = candles.isEmpty;
    _showAsset(
      asset,
      candles,
      needsDownload ? PricesStatus.downloading : PricesStatus.ready,
    );
    if (!needsDownload) {
      unawaited(_completeHistory(asset));
      return;
    }

    var status = PricesStatus.failed;
    try {
      candles = await _repository.downloadCandles(asset.symbol);
      if (candles.isNotEmpty) status = PricesStatus.ready;
    } on Object {
      // No network, quota reached, unknown symbol: the form says so and
      // offers to try again.
    }
    // The user may have chosen another asset in the meantime.
    if (!ref.mounted || state.value?.asset != asset) return;
    _showAsset(asset, candles, status);
  }

  /// Opens a fresh form for the asset [symbol], as when coming from its
  /// detail screen: any earlier result or half-filled form is dropped.
  /// An unknown symbol leaves the form empty.
  Future<void> startWith(String symbol) async {
    final current = await future;
    if (!ref.mounted) return;
    Instrument? asset;
    for (final i in current.instruments) {
      if (i.symbol == symbol) asset = i;
    }
    state = AsyncData(
      SimulatorState(
        instruments: current.instruments,
        fxRates: current.fxRates,
        inflation: current.inflation,
        saved: current.saved,
      ),
    );
    if (asset != null) await selectAsset(asset);
  }

  /// Brings older or missing weeks to the stored prices, in the background,
  /// so the date pickers reach the true start of the history. The dates
  /// already chosen are kept. Failing is fine: the stored prices stay valid.
  Future<void> _completeHistory(Instrument asset) async {
    try {
      final fresh = await _repository.refreshCandlesIfNeeded(asset.symbol);
      final current = state.value;
      if (fresh == null || !ref.mounted || current?.asset != asset) return;
      state = AsyncData(current!.copyWith(candles: fresh));
    } on Object {
      return;
    }
  }

  /// Puts [asset] and its [candles] in the form, with the proposed dates.
  void _showAsset(
    Instrument asset,
    List<WeeklyCandle> candles,
    PricesStatus status,
  ) {
    final current = state.value;
    if (current == null) return;
    final range = candles.isEmpty
        ? null
        : (
            first: candles.first.date,
            last: candles.last.date.add(const Duration(days: 6)),
          );
    DateTime? buy;
    DateTime? sell;
    if (range != null) {
      sell = range.last;
      final yearAgo = DateTime.utc(sell.year - 1, sell.month, sell.day);
      buy = yearAgo.isBefore(range.first) ? range.first : yearAgo;
    }
    state = AsyncData(
      current.copyWith(
        asset: asset,
        candles: candles,
        pricesStatus: status,
        buyDay: buy,
        sellDay: sell,
        result: null,
        error: null,
        savedId: null,
      ),
    );
  }

  void setAmountText(String text) =>
      _edit((s) => s.copyWith(amount: parseDecimalInput(text)));

  void setBuyDay(DateTime day) => _edit((s) => s.copyWith(buyDay: day));

  void setSellDay(DateTime day) => _edit((s) => s.copyWith(sellDay: day));

  /// A PEA only holds eligible assets: the list shrinks, and an asset that
  /// no longer fits is dropped with its prices and dates.
  void setEnvelope(Envelope envelope) {
    final current = state.value;
    if (current == null) return;
    final dropAsset =
        envelope == Envelope.pea &&
        current.asset != null &&
        !current.asset!.peaEligible;
    state = AsyncData(
      dropAsset
          ? current.copyWith(
              envelope: envelope,
              asset: null,
              candles: const [],
              pricesStatus: PricesStatus.ready,
              buyDay: null,
              sellDay: null,
              result: null,
              error: null,
              savedId: null,
            )
          : current.copyWith(envelope: envelope, error: null),
    );
  }

  /// Changing the form drops the previous message, never the typed values.
  void _edit(SimulatorState Function(SimulatorState) change) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(change(current).copyWith(error: null));
  }

  // --- Calculation and saving ----------------------------------------------------

  /// Validates the form and computes the cascade.
  void compute() {
    final current = state.value;
    if (current == null || current.pricesStatus == PricesStatus.downloading) {
      return;
    }

    final error = _firstError(current);
    if (error != null) {
      state = AsyncData(current.copyWith(error: error, result: null));
      return;
    }
    final asset = current.asset!;
    final outcome = runSimulation(
      params: SimulationParams(
        symbol: asset.symbol,
        assetName: asset.name,
        assetType: asset.type,
        currency: asset.currency,
        peaEligible: asset.peaEligible,
        amount: current.amount!,
        buyDay: current.buyDay!,
        sellDay: current.sellDay!,
        envelope: current.envelope,
        brokerageKind: BrokerageKind.percent,
        brokerageValue: defaultBrokeragePercent,
        annualFeePercent: defaultAnnualFeePercent,
      ),
      candles: current.candles,
      fxRates: current.fxRates,
      inflationPercent: current.inflation,
    );
    state = AsyncData(
      current.copyWith(
        result: outcome.result,
        error: outcome.error,
        savedId: null,
        animateResult: true,
      ),
    );
  }

  /// What the form lacks before the domain can judge it.
  SimulationError? _firstError(SimulatorState s) {
    if (s.asset == null) return SimulationError.noAsset;
    if (s.amount == null) return SimulationError.amountNotPositive;
    if (s.candles.isEmpty) return SimulationError.noPrices;
    if (s.buyDay == null || s.sellDay == null) {
      return SimulationError.datesInverted;
    }
    return null;
  }

  /// Freezes the result on screen with its parameters.
  Future<void> save() async {
    final current = state.value;
    final result = current?.result;
    if (current == null || result == null || current.savedId != null) return;
    final saved = await _repository.save(result);
    if (!ref.mounted) return;
    state = AsyncData(
      current.copyWith(savedId: saved.id, saved: [saved, ...current.saved]),
    );
  }

  /// Shows a saved simulation exactly as it was computed (no recalculation).
  void openSaved(SavedSimulation saved) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        result: saved.result,
        error: null,
        savedId: saved.id,
        animateResult: false,
      ),
    );
  }

  Future<void> deleteSaved(int id) async {
    final current = state.value;
    if (current == null) return;
    await _repository.delete(id);
    if (!ref.mounted) return;
    final stillShown = current.savedId == id;
    state = AsyncData(
      current.copyWith(
        saved: current.saved.where((s) => s.id != id).toList(),
        savedId: stillShown ? null : current.savedId,
      ),
    );
  }

  /// Back from the result to the form, which keeps its values.
  void backToForm() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(result: null, savedId: null));
  }
}
