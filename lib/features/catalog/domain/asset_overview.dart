import 'asset_metrics.dart';
import 'instrument.dart';
import 'weekly_candle.dart';

/// Everything one catalogue row needs, already computed.
///
/// Built by the repository from the database, so widgets never compute
/// anything themselves.
class AssetOverview {
  const AssetOverview({
    required this.instrument,
    required this.isFavorite,
    this.lastPrice,
    this.yearlyChange,
    this.sparkline = const [],
    this.logoUrl,
    this.lastFetchedAt,
  });

  /// Computes the price, change and sparkline from the stored candles
  /// (oldest first). Only the last year is used.
  factory AssetOverview.fromCandles({
    required Instrument instrument,
    required bool isFavorite,
    required List<WeeklyCandle> candles,
    String? logoUrl,
    DateTime? lastFetchedAt,
  }) {
    final year = lastYear(candles);
    return AssetOverview(
      instrument: instrument,
      isFavorite: isFavorite,
      lastPrice: year.isEmpty ? null : year.last.close,
      yearlyChange: yearlyChangePercent(year),
      sparkline: sparklinePoints(year),
      logoUrl: logoUrl,
      lastFetchedAt: lastFetchedAt,
    );
  }

  final Instrument instrument;
  final bool isFavorite;

  /// Null while the series has never been downloaded.
  final double? lastPrice;

  /// Null when unknown (see yearlyChangePercent).
  final double? yearlyChange;

  /// Closes scaled between 0 and 1.
  final List<double> sparkline;

  /// Null when unknown or when the asset has no logo.
  final String? logoUrl;

  /// When the series was last downloaded. Null if never.
  final DateTime? lastFetchedAt;

  String get symbol => instrument.symbol;

  /// False while the row must show its small price skeleton.
  bool get hasPrice => lastPrice != null;

  AssetOverview copyWith({bool? isFavorite}) => AssetOverview(
    instrument: instrument,
    isFavorite: isFavorite ?? this.isFavorite,
    lastPrice: lastPrice,
    yearlyChange: yearlyChange,
    sparkline: sparkline,
    logoUrl: logoUrl,
    lastFetchedAt: lastFetchedAt,
  );
}
