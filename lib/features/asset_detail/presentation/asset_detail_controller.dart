import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../catalog/presentation/catalog_controller.dart';
import '../domain/chart_period.dart';
import 'asset_detail_state.dart';

/// One controller per symbol (`family`), freed when the screen closes
/// (`autoDispose`): opening the screen again reads the cache again.
final assetDetailControllerProvider = AsyncNotifierProvider.autoDispose
    .family<AssetDetailController, AssetDetailState, String>(
      AssetDetailController.new,
      // No automatic retry: the user decides with the "Réessayer" button.
      retry: (_, _) => null,
    );

/// Turns the user's actions on the detail screen into a new
/// [AssetDetailState]. It asks the repository for data and never calls
/// the API itself.
class AssetDetailController extends AsyncNotifier<AssetDetailState> {
  AssetDetailController(this.symbol);

  final String symbol;

  CatalogRepository get _repository => ref.read(catalogRepositoryProvider);

  @override
  Future<AssetDetailState> build() async {
    final detail = await _repository.loadDetail(symbol);
    if (detail == null) {
      throw ApiException(ApiErrorKind.notFound, 'Unknown symbol $symbol');
    }

    // Show the cache first, then let the repository decide whether the
    // series is too old. A microtask waits for build() to finish, so the
    // state exists when refresh starts.
    Future.microtask(refresh);
    return AssetDetailState(detail: detail);
  }

  /// Downloads the series if it is missing or too old. [force] is for
  /// pull-to-refresh.
  Future<void> refresh({bool force = false}) async {
    final current = state.value;
    if (current == null || current.isRefreshing) return;

    _update((s) => s.copyWith(isRefreshing: true, refreshError: null));

    try {
      final downloaded = await _repository.refreshSeriesIfNeeded(
        symbol,
        force: force,
      );
      if (!ref.mounted) return;
      if (downloaded) {
        final detail = await _repository.loadDetail(symbol);
        if (!ref.mounted) return;
        _update((s) => s.copyWith(detail: detail));
        // The catalogue row shows the same series: keep it in step.
        if (ref.exists(catalogControllerProvider)) {
          unawaited(
            ref.read(catalogControllerProvider.notifier).reloadAsset(symbol),
          );
        }
      }
      _update((s) => s.copyWith(isRefreshing: false));
    } on ApiException catch (error, stackTrace) {
      if (!ref.mounted) return;
      if (state.value!.detail.hasPrices) {
        // Error with cache: keep the data, show the offline banner.
        _update((s) => s.copyWith(isRefreshing: false, refreshError: error));
      } else {
        // Error without data: nothing useful to show.
        state = AsyncError(error, stackTrace);
      }
    }
  }

  /// "Réessayer" button of the error screen: start again from scratch.
  void retry() => ref.invalidateSelf();

  /// Only changes which stored candles are shown: no network call.
  void setPeriod(ChartPeriod period) =>
      _update((s) => s.copyWith(period: period));

  /// Applies [change] to the current data, if there is any.
  void _update(AssetDetailState Function(AssetDetailState) change) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(change(current));
  }
}
