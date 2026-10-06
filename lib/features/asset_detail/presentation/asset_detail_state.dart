import '../../../core/network/api_exception.dart';
import '../../catalog/domain/asset_metrics.dart';
import '../../catalog/domain/weekly_candle.dart';
import '../domain/asset_detail.dart';
import '../domain/chart_period.dart';
import '../domain/period_stats.dart';

/// Everything the detail screen shows, in one immutable object.
///
/// How the states of the spec map to `AsyncValue<AssetDetailState>`:
/// - loading: `AsyncLoading`, while the local database answers (skeleton);
/// - data: `AsyncData` with [isRefreshing] false and no [refreshError];
/// - refreshing: `AsyncData` with [isRefreshing] true (small spinner);
/// - error with cache: `AsyncData` with a [refreshError] (offline banner);
/// - error without data: `AsyncError`, when the download failed and no
///   price is stored (message and "Réessayer").
/// The "initial" state (no symbol chosen) cannot happen here: the screen
/// is always opened for one symbol.
class AssetDetailState {
  const AssetDetailState({
    required this.detail,
    this.period = ChartPeriod.oneYear,
    this.isRefreshing = false,
    this.refreshError,
  });

  final AssetDetail detail;

  /// The period picked on the selector.
  final ChartPeriod period;

  /// True while the repository checks or downloads the series.
  final bool isRefreshing;

  /// Error of the last refresh, while cached data is still shown.
  final ApiException? refreshError;

  /// The candles drawn on the chart, oldest first.
  List<WeeklyCandle> get periodCandles => candlesFor(detail.candles, period);

  /// The indicators of the selected period.
  PeriodStats get stats => PeriodStats.compute(periodCandles);

  /// The closes of the period scaled between 0 and 1, for the chart.
  List<double> get chartPoints => sparklinePoints(periodCandles);

  /// Change of each period, shown under the labels of the selector.
  Map<ChartPeriod, double?> get changeByPeriod => {
    for (final p in ChartPeriod.values)
      p: changePercent(candlesFor(detail.candles, p)),
  };

  // A sentinel lets copyWith tell "not given" apart from "set to null".
  static const _unset = Object();

  AssetDetailState copyWith({
    AssetDetail? detail,
    ChartPeriod? period,
    bool? isRefreshing,
    Object? refreshError = _unset,
  }) {
    return AssetDetailState(
      detail: detail ?? this.detail,
      period: period ?? this.period,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      refreshError: identical(refreshError, _unset)
          ? this.refreshError
          : refreshError as ApiException?,
    );
  }
}
