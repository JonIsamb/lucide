import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lucide/core/network/alpha_vantage_client.dart';
import 'package:lucide/core/network/api_exception.dart';
import 'package:lucide/core/network/rate_limiter.dart';
import 'package:lucide/core/network/twelve_data_client.dart'
    show fullHistoryWeeks;

/// A week as Alpha Vantage sends it: every number in a string.
Map<String, String> week(double close) => {
  '1. open': '${close - 1}',
  '2. high': '${close + 2}',
  '3. low': '${close - 2}',
  '4. close': '$close',
  '5. volume': '1000',
};

Matcher throwsKind(ApiErrorKind kind) =>
    throwsA(isA<ApiException>().having((e) => e.kind, 'kind', kind));

void main() {
  group('mondayOf', () {
    test('any day of a week gives its Monday', () {
      expect(mondayOf(DateTime.utc(2026, 11, 13)), DateTime.utc(2026, 11, 9));
      expect(mondayOf(DateTime.utc(2026, 11, 9)), DateTime.utc(2026, 11, 9));
      expect(mondayOf(DateTime.utc(2026, 11, 15)), DateTime.utc(2026, 11, 9));
    });

    test('across a month and a year', () {
      expect(mondayOf(DateTime.utc(2026, 10, 2)), DateTime.utc(2026, 9, 28));
      expect(mondayOf(DateTime.utc(2027, 1, 1)), DateTime.utc(2026, 12, 28));
    });
  });

  group('parseWeeklySeries', () {
    test('weeks dated on their Monday, oldest first, numbers read', () {
      final candles = parseWeeklySeries({
        'Meta Data': {'2. Symbol': 'MC.PAR'},
        'Weekly Time Series': {
          '2026-11-13': week(403.45), // Friday
          '2026-11-06': week(408.75),
        },
      });

      expect(candles.map((c) => c.date), [
        DateTime.utc(2026, 11, 2),
        DateTime.utc(2026, 11, 9),
      ]);
      final last = candles.last;
      expect(last.close, 403.45);
      expect(last.open, closeTo(402.45, 1e-9));
      expect(last.volume, 1000);
    });

    test('a week ending on a Thursday (holiday) gets the same Monday', () {
      final candles = parseWeeklySeries({
        'Weekly Time Series': {'2026-04-02': week(10)}, // Thursday
      });
      expect(candles.single.date, DateTime.utc(2026, 3, 30));
    });

    test('a week in two rows keeps its latest one (Christmas 2024)', () {
      // As sent for MC.PAR, CW8.PAR and PSP5.PAR on 15 November 2026.
      for (final order in [
        ['2024-12-24', '2024-12-27'],
        ['2024-12-27', '2024-12-24'],
      ]) {
        final candles = parseWeeklySeries({
          'Weekly Time Series': {
            for (final day in order)
              day: week(day == '2024-12-27' ? 635.6 : 630.8),
            '2025-01-03': week(640),
          },
        });
        expect(candles.map((c) => c.date), [
          DateTime.utc(2024, 12, 23),
          DateTime.utc(2024, 12, 30),
        ]);
        expect(candles.first.close, 635.6, reason: 'order $order');
      }
    });

    test('a broken week is skipped, not the series', () {
      final candles = parseWeeklySeries({
        'Weekly Time Series': {
          '2026-11-13': week(10),
          '2026-11-06': {'1. open': '9'}, // no close
          'not a date': week(11),
          '2026-10-30': 'garbage',
        },
      });
      expect(candles, hasLength(1));
    });

    test('a missing open, high or low takes the close', () {
      final candle = parseWeeklySeries({
        'Weekly Time Series': {
          '2026-11-13': {'4. close': '10.5'},
        },
      }).single;
      expect([candle.open, candle.high, candle.low], [10.5, 10.5, 10.5]);
      expect(candle.volume, isNull);
    });

    test('no series field: no candle', () {
      expect(parseWeeklySeries({'Meta Data': {}}), isEmpty);
    });
  });

  group('throwIfAlphaVantageError', () {
    test('unknown symbol (message seen on the real API)', () {
      expect(
        () => throwIfAlphaVantageError({
          'Error Message':
              'Invalid API call. Please retry or visit the documentation '
              '(https://www.alphavantage.co/documentation/) for '
              'TIME_SERIES_WEEKLY.',
        }),
        throwsKind(ApiErrorKind.notFound),
      );
    });

    test('missing key (message seen on the real API)', () {
      expect(
        () => throwIfAlphaVantageError({
          'Error Message':
              'the parameter apikey is invalid or missing. Please claim your '
              'free API key on (https://www.alphavantage.co/support/#api-key).',
        }),
        throwsKind(ApiErrorKind.invalidKey),
      );
    });

    test('quota and premium messages', () {
      expect(
        () => throwIfAlphaVantageError({
          'Information':
              'We have detected your API key and our standard API '
              'rate limit is 25 requests per day.',
        }),
        throwsKind(ApiErrorKind.rateLimit),
      );
      expect(
        () => throwIfAlphaVantageError({
          'Note':
              'Thank you for using Alpha Vantage! Our standard API call '
              'frequency is 5 calls per minute.',
        }),
        throwsKind(ApiErrorKind.rateLimit),
      );
      expect(
        () => throwIfAlphaVantageError({
          'Information': 'This is a premium endpoint.',
        }),
        throwsKind(ApiErrorKind.notFound),
      );
      expect(
        () => throwIfAlphaVantageError({'Information': 'Something else.'}),
        throwsKind(ApiErrorKind.unknown),
      );
    });

    test('an answer with data is not an error', () {
      expect(
        () => throwIfAlphaVantageError({
          'Weekly Time Series': <String, Object>{},
          'Information': 'not an error here',
        }),
        returnsNormally,
      );
    });
  });

  test('alphaVantageSymbol adds the suffix of the exchange', () {
    expect(alphaVantageSymbol('MC', euronextParis), 'MC.PAR');
    expect(alphaVantageSymbol('IBM', null), 'IBM');
    expect(alphaVantageSymbol('IBM', 'NYSE'), 'IBM');
  });

  group('AlphaVantageClient', () {
    AlphaVantageClient clientWith(MockClient http, {String key = 'k'}) =>
        AlphaVantageClient(
          apiKey: key,
          rateLimiter: RateLimiter(),
          httpClient: http,
        );

    /// [count] consecutive Friday weeks, the last on 13 November 2026.
    String series(int count) => jsonEncode({
      'Weekly Time Series': {
        for (var i = 0; i < count; i++)
          DateTime.utc(2026, 11, 13 - 7 * i).toIso8601String().substring(0, 10):
              week(100.0 + i),
      },
    });

    test('asks for the weekly series of the Paris symbol', () async {
      late http.Request sent;
      final client = clientWith(
        MockClient((request) async {
          sent = request;
          return http.Response(series(2), 200);
        }),
      );

      final candles = await client.fetchWeeklySeries(
        'MC',
        exchange: euronextParis,
      );

      expect(sent.url.host, 'www.alphavantage.co');
      expect(sent.url.queryParameters, {
        'function': 'TIME_SERIES_WEEKLY',
        'symbol': 'MC.PAR',
        'apikey': 'k',
      });
      expect(candles, hasLength(2));
    });

    test('keeps about 5 years, like the Twelve Data downloads', () async {
      final client = clientWith(
        MockClient((_) async => http.Response(series(400), 200)),
      );
      final candles = await client.fetchWeeklySeries('MC');
      expect(candles, hasLength(fullHistoryWeeks));
      expect(candles.last.date, DateTime.utc(2026, 11, 9));
    });

    test('with a start date, only the weeks from it', () async {
      final client = clientWith(
        MockClient((_) async => http.Response(series(10), 200)),
      );
      final candles = await client.fetchWeeklySeries(
        'MC',
        startDate: DateTime.utc(2026, 11, 2),
      );
      expect(candles.map((c) => c.date), [
        DateTime.utc(2026, 11, 2),
        DateTime.utc(2026, 11, 9),
      ]);
    });

    test('an error in a 200 answer is thrown with its kind', () async {
      final client = clientWith(
        MockClient(
          (_) async => http.Response(
            jsonEncode({'Error Message': 'Invalid API call.'}),
            200,
          ),
        ),
      );
      expect(
        client.fetchWeeklySeries('ZZZ'),
        throwsKind(ApiErrorKind.notFound),
      );
    });

    test('no key: invalid key at once, without any request', () async {
      var calls = 0;
      final client = clientWith(
        MockClient((_) async {
          calls++;
          return http.Response('{}', 200);
        }),
        key: '',
      );
      await expectLater(
        client.fetchWeeklySeries('MC'),
        throwsKind(ApiErrorKind.invalidKey),
      );
      expect(calls, 0);
    });

    test('no logo service: null, without any request', () async {
      var calls = 0;
      final client = clientWith(
        MockClient((_) async {
          calls++;
          return http.Response('{}', 200);
        }),
      );
      expect(await client.fetchLogoUrl('MC', exchange: euronextParis), isNull);
      expect(calls, 0);
    });
  });
}
