import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lucide/core/network/api_exception.dart';
import 'package:lucide/core/network/rate_limiter.dart';
import 'package:lucide/core/network/twelve_data_client.dart';

Matcher throwsApi(ApiErrorKind kind) =>
    throwsA(isA<ApiException>().having((e) => e.kind, 'kind', kind));

void main() {
  group('parseTimeSeries', () {
    test('reads numbers sent as strings, oldest first', () {
      final candles = parseTimeSeries({
        'meta': {'symbol': 'AAPL', 'currency': 'USD'},
        'values': [
          {
            'datetime': '2026-10-05',
            'open': '225.1',
            'high': '230',
            'low': '224.5',
            'close': '227.40',
            'volume': '1234567',
          },
          {
            'datetime': '2026-09-28',
            'open': '220',
            'high': '226',
            'low': '219',
            'close': '225.10',
            'volume': '2000000',
          },
        ],
        'status': 'ok',
      });

      expect(candles.length, 2);
      expect(candles.first.date, DateTime.utc(2026, 9, 28));
      expect(candles.last.close, 227.40);
      expect(candles.last.high, 230);
      expect(candles.last.volume, 1234567);
    });

    test('missing fields: no volume is fine, no close skips the candle', () {
      final candles = parseTimeSeries({
        'values': [
          {'datetime': '2026-10-05', 'close': '54210.5'},
          {'datetime': '2026-09-28', 'open': '1', 'close': null},
          {'close': '3'},
          'garbage',
        ],
      });

      expect(candles.length, 1);
      expect(candles.single.open, 54210.5);
      expect(candles.single.volume, isNull);
    });

    test('no values gives an empty list', () {
      expect(parseTimeSeries({'status': 'ok'}), isEmpty);
    });

    test('error body inside a 200 is turned into ApiException', () {
      expect(
        () => parseTimeSeries({
          'code': 429,
          'message': 'You have run out of API credits for the current minute.',
          'status': 'error',
        }),
        throwsApi(ApiErrorKind.rateLimit),
      );
      expect(
        () => parseTimeSeries({
          'code': '401',
          'message': '**apikey** parameter is incorrect',
          'status': 'error',
        }),
        throwsApi(ApiErrorKind.invalidKey),
      );
      expect(
        () => parseTimeSeries({
          'code': 400,
          'message': '**symbol** not found: FOO.',
          'status': 'error',
        }),
        throwsApi(ApiErrorKind.notFound),
      );
    });
  });

  group('parseLogoUrl', () {
    test('stock answer uses url', () {
      expect(
        parseLogoUrl({
          'meta': {'symbol': 'AAPL', 'exchange': 'NASDAQ'},
          'url': 'https://api.twelvedata.com/logo/apple.com',
        }),
        'https://api.twelvedata.com/logo/apple.com',
      );
    });

    test('crypto answer uses logo_base', () {
      expect(
        parseLogoUrl({
          'meta': {'symbol': 'BTC/EUR', 'exchange': 'Binance'},
          'logo_base': 'https://logo.twelvedata.com/crypto/btc.png',
          'logo_quote': 'https://logo.twelvedata.com/crypto/eur.png',
        }),
        'https://logo.twelvedata.com/crypto/btc.png',
      );
    });

    test('empty or missing url gives null', () {
      expect(parseLogoUrl({'url': ''}), isNull);
      expect(parseLogoUrl({'meta': {}}), isNull);
      expect(parseLogoUrl({'url': 42}), isNull);
    });

    test('error body throws', () {
      expect(
        () => parseLogoUrl({'status': 'error', 'code': 404, 'message': 'x'}),
        throwsApi(ApiErrorKind.notFound),
      );
    });
  });

  group('TwelveDataClient', () {
    TwelveDataClient clientWith(MockClient http, {String key = 'k'}) =>
        TwelveDataClient(
          apiKey: key,
          rateLimiter: RateLimiter(),
          httpClient: http,
        );

    test('sends the key in the header and the query parameters', () async {
      late http.Request sent;
      final client = clientWith(
        MockClient((request) async {
          sent = request;
          return http.Response(jsonEncode({'values': [], 'status': 'ok'}), 200);
        }),
      );

      await client.fetchWeeklySeries(
        'SPY',
        exchange: 'NYSE',
        startDate: DateTime.utc(2026, 9, 28),
      );

      expect(sent.headers['Authorization'], 'apikey k');
      expect(sent.url.queryParameters, {
        'symbol': 'SPY',
        'interval': '1week',
        'outputsize': '$fullHistoryWeeks',
        'exchange': 'NYSE',
        'start_date': '2026-09-28',
      });
      expect(sent.url.queryParameters.containsKey('apikey'), isFalse);
    });

    test('missing key fails without any call', () async {
      var calls = 0;
      final client = clientWith(
        MockClient((_) async {
          calls++;
          return http.Response('{}', 200);
        }),
        key: '',
      );
      await expectLater(
        client.fetchLogoUrl('AAPL'),
        throwsApi(ApiErrorKind.invalidKey),
      );
      expect(calls, 0);
    });

    test('network failure becomes ApiErrorKind.network', () async {
      final client = clientWith(
        MockClient((_) async => throw http.ClientException('no network')),
      );
      await expectLater(
        client.fetchWeeklySeries('AAPL'),
        throwsApi(ApiErrorKind.network),
      );
    });

    test('HTTP error with unreadable body', () async {
      final client = clientWith(
        MockClient((_) async => http.Response('<html>oops</html>', 500)),
      );
      await expectLater(
        client.fetchWeeklySeries('AAPL'),
        throwsApi(ApiErrorKind.unknown),
      );
    });
  });
}
