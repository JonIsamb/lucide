import '../../../core/network/api_exception.dart';
import '../domain/asset_overview.dart';
import '../domain/catalog_filters.dart';
import '../domain/instrument.dart';

/// Everything the Catalogue screen shows, in one immutable object.
///
/// Immutable: the controller never edits it, it builds a new one with
/// [copyWith]. Riverpod then sees a new value and rebuilds the screen, and
/// there is no risk of a widget seeing a half-updated state.
///
/// How the 6 states of the spec map to `AsyncValue<CatalogState>`:
/// - initial and loading: `AsyncLoading`, while the local database opens
///   (skeleton rows);
/// - data: `AsyncData` with [isRefreshing] false and no [refreshError];
/// - refreshing: `AsyncData` with [isRefreshing] true (progress "12/30");
/// - error with cache: `AsyncData` with a [refreshError] (offline banner);
/// - error without data: `AsyncError`, when the refresh failed and no price
///   has ever been downloaded (message and "Réessayer").
///
/// Each row also has its own state: an asset without price yet
/// ([AssetOverview.hasPrice] false) shows a small skeleton.
class CatalogState {
  const CatalogState({
    required this.assets,
    this.query = '',
    this.typeFilter,
    this.sort = CatalogSort.changeDesc,
    this.isRefreshing = false,
    this.seriesDone = 0,
    this.seriesTotal = 0,
    this.refreshError,
  });

  /// Every asset, in catalogue order, as stored locally.
  final List<AssetOverview> assets;

  final String query;

  /// Null means "Tout".
  final InstrumentType? typeFilter;
  final CatalogSort sort;

  /// True while the repository downloads series or logos.
  final bool isRefreshing;

  /// Progress of the series download, for "Mise à jour : 12/30".
  final int seriesDone;
  final int seriesTotal;

  /// Error of the last refresh, while cached data is still shown.
  final ApiException? refreshError;

  /// The rows to display, after search, filter and sort.
  List<AssetOverview> get visibleAssets =>
      applyCatalogQuery(assets, query: query, type: typeFilter, sort: sort);

  /// True while series are still downloading (logos come after, silently).
  bool get showsProgress => isRefreshing && seriesDone < seriesTotal;

  bool get hasAnyPrice => assets.any((a) => a.hasPrice);

  /// Date of the oldest data on screen: the honest "Cours du ..." date.
  DateTime? get lastUpdate {
    DateTime? oldest;
    for (final asset in assets) {
      final fetched = asset.lastFetchedAt;
      if (!asset.hasPrice || fetched == null) continue;
      if (oldest == null || fetched.isBefore(oldest)) oldest = fetched;
    }
    return oldest;
  }

  // A sentinel lets copyWith tell "not given" apart from "set to null".
  static const _unset = Object();

  CatalogState copyWith({
    List<AssetOverview>? assets,
    String? query,
    Object? typeFilter = _unset,
    CatalogSort? sort,
    bool? isRefreshing,
    int? seriesDone,
    int? seriesTotal,
    Object? refreshError = _unset,
  }) {
    return CatalogState(
      assets: assets ?? this.assets,
      query: query ?? this.query,
      typeFilter: identical(typeFilter, _unset)
          ? this.typeFilter
          : typeFilter as InstrumentType?,
      sort: sort ?? this.sort,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      seriesDone: seriesDone ?? this.seriesDone,
      seriesTotal: seriesTotal ?? this.seriesTotal,
      refreshError: identical(refreshError, _unset)
          ? this.refreshError
          : refreshError as ApiException?,
    );
  }

  /// Replaces one asset (after a download or a favorite toggle).
  CatalogState withAsset(AssetOverview updated) => copyWith(
    assets: [
      for (final asset in assets)
        asset.symbol == updated.symbol ? updated : asset,
    ],
  );
}
