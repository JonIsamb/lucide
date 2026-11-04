import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/network/api_exception.dart';
import '../domain/simulation_result.dart';

/// What the simulator needs from the free public data sources.
/// Tests use a fake; the app uses [HttpRatesClient].
abstract interface class RatesApi {
  /// EUR/USD rates from [from] (included) to today, oldest first.
  Future<List<FxRate>> fetchFxRates({required DateTime from});

  /// Yearly inflation in France in %, from [fromYear] on.
  Future<Map<int, double>> fetchInflation({required int fromYear});
}

/// Frankfurter (euro rates) and World Bank (indicator FP.CPI.TOTL.ZG).
/// Neither needs a key or has a documented quota we depend on.
class HttpRatesClient implements RatesApi {
  HttpRatesClient({http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  final http.Client _http;
  static const _timeout = Duration(seconds: 20);

  @override
  Future<List<FxRate>> fetchFxRates({required DateTime from}) async {
    final json = await _get(
      Uri.https('api.frankfurter.dev', '/v1/${_isoDay(from)}..', {
        'base': 'EUR',
        'symbols': 'USD',
      }),
    );
    return parseFxRates(json);
  }

  @override
  Future<Map<int, double>> fetchInflation({required int fromYear}) async {
    final json = await _get(
      Uri.https(
        'api.worldbank.org',
        '/v2/country/FRA/indicator/FP.CPI.TOTL.ZG',
        {
          'format': 'json',
          'per_page': '100',
          'date': '$fromYear:${DateTime.now().year}',
        },
      ),
    );
    return parseInflation(json);
  }

  Future<Object?> _get(Uri uri) async {
    final http.Response response;
    try {
      response = await _http.get(uri).timeout(_timeout);
    } on TimeoutException {
      throw const ApiException(ApiErrorKind.network, 'Timeout');
    } on http.ClientException catch (e) {
      throw ApiException(ApiErrorKind.network, e.message);
    } on Exception catch (e) {
      // Socket and TLS errors.
      throw ApiException(ApiErrorKind.network, '$e');
    }
    if (response.statusCode == 404) {
      throw ApiException(ApiErrorKind.notFound, uri.toString());
    }
    if (response.statusCode != 200) {
      throw ApiException(ApiErrorKind.unknown, 'HTTP ${response.statusCode}');
    }
    try {
      return jsonDecode(response.body);
    } on FormatException catch (e) {
      throw ApiException(ApiErrorKind.unknown, 'Unreadable JSON: $e');
    }
  }
}

/// Frankfurter range answer: `{"rates": {"2026-10-05": {"USD": 1.12}}}`.
/// A day with a missing or invalid rate is skipped, never a crash.
List<FxRate> parseFxRates(Object? json) {
  final rates = json is Map ? json['rates'] : null;
  if (rates is! Map) {
    throw const ApiException(ApiErrorKind.unknown, 'No "rates" field');
  }
  final result = <FxRate>[];
  rates.forEach((day, value) {
    final date = DateTime.tryParse('${day}T00:00:00Z');
    final rate = value is Map ? _toDouble(value['USD']) : null;
    if (date != null && rate != null && rate > 0) {
      result.add(FxRate(date, rate));
    }
  });
  result.sort((a, b) => a.day.compareTo(b.day));
  return result;
}

/// World Bank answer: `[meta, [{"date": "2024", "value": 1.99}, ...]]`.
/// A year with a null or invalid value is skipped (recent years are often
/// not published yet).
Map<int, double> parseInflation(Object? json) {
  final rows = json is List && json.length > 1 ? json[1] : null;
  if (rows is! List) {
    throw const ApiException(ApiErrorKind.unknown, 'No data list');
  }
  final result = <int, double>{};
  for (final row in rows) {
    if (row is! Map) continue;
    final year = int.tryParse('${row['date']}');
    final value = _toDouble(row['value']);
    if (year != null && value != null) result[year] = value;
  }
  return result;
}

/// Numbers sometimes arrive as strings: convert, or null if unusable.
double? _toDouble(Object? value) {
  final number = switch (value) {
    final num n => n.toDouble(),
    final String s => double.tryParse(s),
    _ => null,
  };
  return number != null && number.isFinite ? number : null;
}

String _isoDay(DateTime d) => d.toIso8601String().substring(0, 10);
