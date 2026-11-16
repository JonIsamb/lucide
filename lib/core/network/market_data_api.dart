import '../../features/catalog/domain/weekly_candle.dart';

/// What the repository needs from a price provider.
///
/// TwelveDataClient and AlphaVantageClient implement it, and
/// MarketDataRouter picks one of them per exchange. Tests use a fake that
/// counts calls, without network and without waiting for a rate limiter.
abstract interface class MarketDataApi {
  /// Name of the provider that serves [exchange]. A key or quota error of
  /// one provider must not stop the downloads of another.
  String sourceFor(String? exchange);

  /// Weekly candles, oldest first. With [startDate], only from that date.
  Future<List<WeeklyCandle>> fetchWeeklySeries(
    String symbol, {
    String? exchange,
    DateTime? startDate,
  });

  /// Logo URL, or null when there is none.
  Future<String?> fetchLogoUrl(String symbol, {String? exchange});
}
