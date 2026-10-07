import '../../catalog/domain/instrument.dart';
import '../../catalog/domain/weekly_candle.dart';

/// Everything the detail screen knows about one asset, as stored locally.
class AssetDetail {
  const AssetDetail({
    required this.instrument,
    required this.candles,
    this.logoUrl,
    this.lastFetchedAt,
  });

  final Instrument instrument;

  /// The whole stored history, oldest first. Empty if never downloaded.
  final List<WeeklyCandle> candles;

  /// Null when unknown or when the asset has no logo.
  final String? logoUrl;

  /// When the series was last downloaded. Null if never.
  final DateTime? lastFetchedAt;

  bool get hasPrices => candles.isNotEmpty;

  double? get lastPrice => candles.isEmpty ? null : candles.last.close;
}
