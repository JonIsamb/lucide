import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../features/catalog/domain/weekly_candle.dart';
import 'api_exception.dart';
import 'rate_limiter.dart';

/// How many weekly candles we ask for on a full download: about 5 years.
///
/// It costs 1 credit whatever the size, and the detail screen (5-year
/// chart) and the game (random 30-week windows) need more than one year.
const fullHistoryWeeks = 261;

/// Talks to the Twelve Data API. It only knows HTTP and JSON: deciding
/// when to call it is the repository's job.
///
/// Every request first waits for the [RateLimiter], so the free plan
/// quota (8 credits per minute) is never exceeded.
class TwelveDataClient {
  TwelveDataClient({
    required this.apiKey,
    required this.rateLimiter,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String apiKey;
  final RateLimiter rateLimiter;
  final http.Client _http;

  static const _host = 'api.twelvedata.com';
  static const _timeout = Duration(seconds: 20);

  /// Weekly candles of [symbol], oldest first.
  ///
  /// With [startDate], only the candles from that date are returned
  /// (incremental update). [exchange] picks the US listing of tickers that
  /// also exist abroad.
  Future<List<WeeklyCandle>> fetchWeeklySeries(
    String symbol, {
    String? exchange,
    DateTime? startDate,
  }) async {
    final json = await _get('/time_series', {
      'symbol': symbol,
      'interval': '1week',
      'outputsize': '$fullHistoryWeeks',
      // "?" adds the entry only when exchange is not null.
      'exchange': ?exchange,
      if (startDate != null) 'start_date': _formatDate(startDate),
    });
    return parseTimeSeries(json);
  }

  /// URL of the logo of [symbol], or null if Twelve Data has none.
  Future<String?> fetchLogoUrl(String symbol, {String? exchange}) async {
    final json = await _get('/logo', {
      'symbol': symbol,
      // "?" adds the entry only when exchange is not null.
      'exchange': ?exchange,
    });
    return parseLogoUrl(json);
  }

  Future<Map<String, dynamic>> _get(
    String path,
    Map<String, String> query,
  ) async {
    // No key: fail at once instead of wasting a slot of the rate limiter.
    if (apiKey.isEmpty) {
      throw const ApiException(ApiErrorKind.invalidKey, 'No API key given');
    }
    await rateLimiter.acquire();

    final http.Response response;
    try {
      response = await _http
          .get(
            Uri.https(_host, path, query),
            // In a header rather than in the URL, so it never shows up in logs.
            headers: {'Authorization': 'apikey $apiKey'},
          )
          .timeout(_timeout);
    } on TimeoutException catch (e) {
      throw ApiException(ApiErrorKind.network, 'Timeout: $e');
    } on http.ClientException catch (e) {
      throw ApiException(ApiErrorKind.network, e.message);
    }

    Object? body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      body = null;
    }
    if (body is Map<String, dynamic>) {
      // Twelve Data often answers 200 with an error inside the body.
      throwIfError(body);
      if (response.statusCode == 200) return body;
    }
    throw ApiException(
      errorKindForCode(response.statusCode, ''),
      'HTTP ${response.statusCode}',
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

// --- Parsing -------------------------------------------------------------
// Top-level functions so they can be unit-tested without any HTTP call.

/// Throws an [ApiException] when the body is
/// `{"status": "error", "code": 429, "message": "..."}`.
void throwIfError(Map<String, dynamic> json) {
  if (json['status'] != 'error') return;
  final code = parseInt(json['code']) ?? 0;
  final message = json['message']?.toString() ?? '';
  throw ApiException(errorKindForCode(code, message), '$code $message');
}

/// Maps the error codes documented by Twelve Data to our error kinds.
ApiErrorKind errorKindForCode(int code, String message) {
  switch (code) {
    case 401:
      return ApiErrorKind.invalidKey;
    case 429:
      return ApiErrorKind.rateLimit;
    case 404:
    // 403: the symbol exists but needs a paid plan, so for us it is missing.
    case 403:
      return ApiErrorKind.notFound;
    case 400:
      // 400 is also used for "symbol not found" or "no data", among
      // other bad parameters.
      final lower = message.toLowerCase();
      return lower.contains('not found') || lower.contains('no data')
          ? ApiErrorKind.notFound
          : ApiErrorKind.unknown;
    default:
      return ApiErrorKind.unknown;
  }
}

/// Reads the `values` of a /time_series answer, oldest first.
///
/// Numbers arrive as strings ("227.40") and any field may be missing, so
/// a broken candle is skipped instead of failing the whole series.
List<WeeklyCandle> parseTimeSeries(Map<String, dynamic> json) {
  throwIfError(json);
  final values = json['values'];
  if (values is! List) return const [];

  final candles = <WeeklyCandle>[];
  for (final value in values) {
    if (value is! Map) continue;
    final date = parseDate(value['datetime']);
    final close = parseDouble(value['close']);
    if (date == null || close == null) continue;
    candles.add(
      WeeklyCandle(
        date: date,
        // A missing open/high/low is replaced by the close: better a flat
        // candle than no candle.
        open: parseDouble(value['open']) ?? close,
        high: parseDouble(value['high']) ?? close,
        low: parseDouble(value['low']) ?? close,
        close: close,
        volume: parseDouble(value['volume']),
      ),
    );
  }
  // The API sends the newest first; the rest of the app wants oldest first.
  candles.sort((a, b) => a.date.compareTo(b.date));
  return candles;
}

/// Reads a /logo answer. Stocks and ETFs use `url`; crypto pairs use
/// `logo_base` (the BTC of BTC/EUR) and `logo_quote` (the EUR).
String? parseLogoUrl(Map<String, dynamic> json) {
  throwIfError(json);
  for (final key in const ['url', 'logo_base']) {
    final value = json[key];
    if (value is String && value.trim().startsWith('http')) {
      return value.trim();
    }
  }
  return null;
}

double? parseDouble(Object? value) => switch (value) {
  num() => value.toDouble(),
  String() => double.tryParse(value.trim()),
  _ => null,
};

int? parseInt(Object? value) => switch (value) {
  int() => value,
  num() => value.toInt(),
  String() => int.tryParse(value.trim()),
  _ => null,
};

/// "2026-10-05" or "2026-10-05 00:00:00" → DateTime in UTC (date only).
/// UTC avoids a candle moving to the previous day with time zones.
DateTime? parseDate(Object? value) {
  if (value is! String || value.length < 10) return null;
  final parsed = DateTime.tryParse(value.substring(0, 10));
  if (parsed == null) return null;
  return DateTime.utc(parsed.year, parsed.month, parsed.day);
}
