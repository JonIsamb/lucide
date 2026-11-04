import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catalog/domain/instrument.dart';
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

  /// Picks the asset and proposes the last year of its history.
  Future<void> selectAsset(Instrument asset) async {
    final current = state.value;
    if (current == null) return;
    final candles = await _repository.loadCandles(asset.symbol);
    if (!ref.mounted) return;
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

  void setEnvelope(Envelope envelope) =>
      _edit((s) => s.copyWith(envelope: envelope));

  void setBrokerageKind(BrokerageKind kind) =>
      _edit((s) => s.copyWith(brokerageKind: kind));

  /// An empty field means no fee; an unreadable one is refused later.
  void setBrokerageText(String text) => _edit(
    (s) => s.copyWith(
      brokerageValue: text.trim().isEmpty ? 0.0 : parseDecimalInput(text),
    ),
  );

  void setAnnualFeeText(String text) => _edit(
    (s) => s.copyWith(
      annualFeePercent: text.trim().isEmpty ? 0.0 : parseDecimalInput(text),
    ),
  );

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
    if (current == null) return;

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
        brokerageKind: current.brokerageKind,
        brokerageValue: current.brokerageValue!,
        annualFeePercent: current.annualFeePercent!,
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
    if (s.brokerageValue == null) return SimulationError.brokerageOutOfRange;
    if (s.annualFeePercent == null) return SimulationError.annualFeeOutOfRange;
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
