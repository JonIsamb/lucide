import '../../features/catalog/domain/weekly_candle.dart';
import 'market_data_api.dart';

/// Sends each request to the provider that serves the asset's exchange.
///
/// The free Twelve Data plan covers the US markets and the cryptos, not
/// Euronext: the Paris assets go to Alpha Vantage. The repository sees one
/// [MarketDataApi] and never knows which provider answered.
class MarketDataRouter implements MarketDataApi {
  MarketDataRouter({required this.defaultApi, required this.byExchange});

  /// Provider of every exchange missing from [byExchange].
  final MarketDataApi defaultApi;

  /// Exchange name (as in catalog.json) → provider.
  final Map<String, MarketDataApi> byExchange;

  MarketDataApi _for(String? exchange) => byExchange[exchange] ?? defaultApi;

  @override
  String sourceFor(String? exchange) => _for(exchange).sourceFor(exchange);

  @override
  Future<List<WeeklyCandle>> fetchWeeklySeries(
    String symbol, {
    String? exchange,
    DateTime? startDate,
  }) =>
      _for(exchange)
          .fetchWeeklySeries(symbol, exchange: exchange, startDate: startDate);

  @override
  Future<String?> fetchLogoUrl(String symbol, {String? exchange}) =>
      _for(exchange).fetchLogoUrl(symbol, exchange: exchange);
}
