import 'package:http/http.dart' as http;

import '../../features/catalog/domain/weekly_candle.dart';
import 'api_exception.dart';
import 'json_http.dart';
import 'json_values.dart';
import 'market_data_api.dart';
import 'rate_limiter.dart';
import 'twelve_data_client.dart' show fullHistoryWeeks;

/// Exchange name of the Paris assets in catalog.json.
const euronextParis = 'Euronext Paris';

/// Talks to the Alpha Vantage API, for the Euronext Paris assets that the
/// free Twelve Data plan refuses. Like [TwelveDataClient], it only knows
/// HTTP and JSON: the repository decides when to call it.
///
/// One weekly series costs one request whatever its length, and the
/// catalogue only has a few Paris assets: far below the free quota.
class AlphaVantageClient implements MarketDataApi {
  AlphaVantageClient({
    required this.apiKey,
    required this.rateLimiter,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String apiKey;
  final RateLimiter rateLimiter;
  final http.Client _http;

  /// Exchange names of catalog.json → Alpha Vantage symbol suffix
  /// ("MC" on Euronext Paris is "MC.PAR").
  static const suffixes = {euronextParis: 'PAR'};

  @override
  String sourceFor(String? exchange) => 'Alpha Vantage';

  /// Weekly candles of [symbol], oldest first, each dated on the Monday of
  /// its week like the Twelve Data ones. Alpha Vantage always sends the
  /// whole history: we keep about 5 years, and only from [startDate] when
  /// given.
  @override
  Future<List<WeeklyCandle>> fetchWeeklySeries(
    String symbol, {
    String? exchange,
    DateTime? startDate,
  }) async {
    final json = await _get({
      'function': 'TIME_SERIES_WEEKLY',
      'symbol': alphaVantageSymbol(symbol, exchange),
    });
    final candles = parseWeeklySeries(json);
    final recent = candles.length > fullHistoryWeeks
        ? candles.sublist(candles.length - fullHistoryWeeks)
        : candles;
    if (startDate == null) return recent;
    return [
      for (final candle in recent)
        if (!candle.date.isBefore(startDate)) candle,
    ];
  }

  /// Alpha Vantage has no logo service: no request, no logo.
  @override
  Future<String?> fetchLogoUrl(String symbol, {String? exchange}) async => null;

  Future<Map<String, dynamic>> _get(Map<String, String> query) async {
    // No key: fail at once instead of wasting a request.
    if (apiKey.isEmpty) {
      throw const ApiException(ApiErrorKind.invalidKey, 'No API key given');
    }
    await rateLimiter.acquire();
    final body = await getJson(
      _http,
      // Alpha Vantage only accepts the key in the URL.
      Uri.https('www.alphavantage.co', '/query', {...query, 'apikey': apiKey}),
      // Its errors arrive with a 200 status, inside the body.
      checkBody: (body) {
        if (body is Map<String, dynamic>) throwIfAlphaVantageError(body);
      },
    );
    if (body is! Map<String, dynamic>) {
      throw const ApiException(ApiErrorKind.unknown, 'Unexpected JSON');
    }
    return body;
  }
}

/// "MC" + "Euronext Paris" → "MC.PAR". Other exchanges keep the symbol.
String alphaVantageSymbol(String symbol, String? exchange) {
  final suffix = AlphaVantageClient.suffixes[exchange];
  return suffix == null ? symbol : '$symbol.$suffix';
}

// --- Parsing -------------------------------------------------------------
// Top-level functions so they can be unit-tested without any HTTP call.

/// Throws an [ApiException] when the body is an error instead of data.
///
/// Seen on 15 November 2026: an unknown symbol gives
/// `{"Error Message": "Invalid API call. ..."}` and a missing key
/// `{"Error Message": "the parameter apikey is invalid or missing. ..."}`,
/// both with a 200 status. A quota message comes in `Information` or
/// `Note` (not seen ourselves: recognised by its words).
void throwIfAlphaVantageError(Map<String, dynamic> json) {
  if (json.containsKey('Weekly Time Series')) return;
  final error = json['Error Message']?.toString();
  if (error != null) {
    throw ApiException(
      error.toLowerCase().contains('apikey')
          ? ApiErrorKind.invalidKey
          : ApiErrorKind.notFound,
      error,
    );
  }
  final info = (json['Information'] ?? json['Note'])?.toString();
  if (info != null) {
    final lower = info.toLowerCase();
    throw ApiException(
      lower.contains('rate limit') ||
              lower.contains('requests per day') ||
              lower.contains('api call frequency')
          ? ApiErrorKind.rateLimit
          : lower.contains('premium')
          ? ApiErrorKind.notFound
          : ApiErrorKind.unknown,
      info,
    );
  }
}

/// Reads a TIME_SERIES_WEEKLY answer, oldest first:
/// `{"Weekly Time Series": {"2026-11-13": {"1. open": "404.55", ...}}}`.
///
/// Each week is dated on its last trading day (a Friday, or earlier when
/// the Friday is a holiday): it is moved to the Monday of that week, the
/// date Twelve Data uses, so the cache and the game see one convention. A
/// broken week is skipped instead of failing the whole series.
///
/// Some weeks come in two rows: Christmas 2024 has one dated 24 December
/// and one dated 27 December. Only the latest row of a week is kept: it
/// holds the real close of the week, and the cache allows one candle per
/// week.
List<WeeklyCandle> parseWeeklySeries(Map<String, dynamic> json) {
  throwIfAlphaVantageError(json);
  final weeks = json['Weekly Time Series'];
  if (weeks is! Map) return const [];

  // Monday → (day of the row kept, its candle).
  final byWeek = <DateTime, (DateTime, WeeklyCandle)>{};
  weeks.forEach((day, value) {
    if (value is! Map) return;
    final date = parseDate(day);
    final close = parseDouble(value['4. close']);
    if (date == null || close == null) return;
    final monday = mondayOf(date);
    final kept = byWeek[monday];
    if (kept != null && kept.$1.isAfter(date)) return;
    byWeek[monday] = (
      date,
      WeeklyCandle(
        date: monday,
        // A missing open/high/low is replaced by the close: better a flat
        // candle than no candle.
        open: parseDouble(value['1. open']) ?? close,
        high: parseDouble(value['2. high']) ?? close,
        low: parseDouble(value['3. low']) ?? close,
        close: close,
        volume: parseDouble(value['5. volume']),
      ),
    );
  });
  final candles = [for (final (_, candle) in byWeek.values) candle]
    ..sort((a, b) => a.date.compareTo(b.date));
  return candles;
}

/// The Monday of the week of [day] (a UTC date).
DateTime mondayOf(DateTime day) =>
    DateTime.utc(day.year, day.month, day.day - (day.weekday - 1));
