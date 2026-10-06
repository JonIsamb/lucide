import '../../features/catalog/domain/weekly_candle.dart';

/// What the repository needs from a price provider.
///
/// TwelveDataClient implements it; tests use a fake that counts calls,
/// without network and without waiting for the rate limiter.
abstract interface class MarketDataApi {
  /// Weekly candles, oldest first. With [startDate], only from that date.
  Future<List<WeeklyCandle>> fetchWeeklySeries(
    String symbol, {
    String? exchange,
    DateTime? startDate,
  });

  /// Logo URL, or null when there is none.
  Future<String?> fetchLogoUrl(String symbol, {String? exchange});
}
