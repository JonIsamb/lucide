import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../data/catalog_repository.dart';
import '../domain/catalog_filters.dart';
import '../domain/instrument.dart';
import 'catalog_state.dart';

final catalogControllerProvider =
    AsyncNotifierProvider<CatalogController, CatalogState>(
      CatalogController.new,
    );

/// Receives the user's actions from the screen and turns them into a new
/// [CatalogState]. It asks the repository for data and never calls the
/// API itself.
class CatalogController extends AsyncNotifier<CatalogState> {
  CatalogRepository get _repository => ref.read(catalogRepositoryProvider);

  @override
  Future<CatalogState> build() async {
    // The catalogue comes from the app itself: always available offline.
    await _repository.seedCatalog();
    final assets = await _repository.loadOverviews();

    // Show the cache first, then update it in the background. A microtask
    // waits for build() to finish, so the state exists when refresh starts.
    Future.microtask(refresh);
    return CatalogState(assets: assets);
  }

  /// Downloads what is missing or too old. [force] is for pull-to-refresh.
  ///
  /// Does nothing if a refresh is already running: the rate limiter would
  /// only make both wait.
  Future<void> refresh({bool force = false}) async {
    final current = state.value;
    if (current == null || current.isRefreshing) return;

    _update(
      (s) => s.copyWith(
        isRefreshing: true,
        seriesDone: 0,
        seriesTotal: 0,
        refreshError: null,
      ),
    );

    try {
      await for (final progress in _repository.refreshAll(force: force)) {
        if (!ref.mounted) return;
        _update((s) {
          final next = s.copyWith(
            seriesDone: progress.done,
            seriesTotal: progress.total,
          );
          final updated = progress.updated;
          // Keep the star the user may have tapped during the download.
          return updated == null
              ? next
              : next.withAsset(
                  updated.copyWith(
                    isFavorite: s.assets
                        .firstWhere((a) => a.symbol == updated.symbol)
                        .isFavorite,
                  ),
                );
        });
      }
      if (!ref.mounted) return;
      _update((s) => s.copyWith(isRefreshing: false));
    } on ApiException catch (error, stackTrace) {
      if (!ref.mounted) return;
      final latest = state.value!;
      if (latest.hasAnyPrice) {
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

  void setQuery(String query) => _update((s) => s.copyWith(query: query));

  void setTypeFilter(InstrumentType? type) =>
      _update((s) => s.copyWith(typeFilter: type));

  void setSort(CatalogSort sort) => _update((s) => s.copyWith(sort: sort));

  /// Updates the star at once, then saves it. The user sees no delay.
  Future<void> toggleFavorite(String symbol) async {
    final current = state.value;
    if (current == null) return;
    final asset = current.assets.firstWhere((a) => a.symbol == symbol);
    final isFavorite = !asset.isFavorite;

    _update((s) => s.withAsset(asset.copyWith(isFavorite: isFavorite)));
    await _repository.setFavorite(symbol, isFavorite);
  }

  /// Applies [change] to the current data, if there is any.
  void _update(CatalogState Function(CatalogState) change) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(change(current));
  }
}
