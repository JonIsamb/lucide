import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/features/game/data/earnings_dto.dart';

void main() {
  group('EarningsDto.fromJson', () {
    test('reads a complete row', () {
      final dto = EarningsDto.fromJson(<String, dynamic>{
        'symbol': 'AAPL',
        'date': '2026-07-30',
        'surprise_prc': 6.88,
      })!;

      expect(dto.symbol, 'AAPL');
      expect(dto.day, DateTime.utc(2026, 7, 30));
      expect(dto.surprisePercent, 6.88);
    });

    test('a number written as a string is converted', () {
      final dto = EarningsDto.fromJson(<String, dynamic>{
        'symbol': 'AAPL',
        'date': '2023-02-01',
        'surprise_prc': '-3.09',
      })!;
      expect(dto.surprisePercent, -3.09);
    });

    test('a missing or invalid surprise is unknown, the row is kept', () {
      for (final surprise in [null, 'n/a', true]) {
        final dto = EarningsDto.fromJson(<String, dynamic>{
          'symbol': 'AAPL',
          'date': '2023-02-01',
          'surprise_prc': surprise,
        })!;
        expect(dto.surprisePercent, isNull);
      }
      final withoutField = EarningsDto.fromJson(<String, dynamic>{
        'symbol': 'AAPL',
        'date': '2023-02-01',
      })!;
      expect(withoutField.surprisePercent, isNull);
    });

    test('a row without symbol or without a valid date is skipped', () {
      expect(
        EarningsDto.fromJson(<String, dynamic>{'date': '2023-02-01'}),
        isNull,
      );
      expect(
        EarningsDto.fromJson(<String, dynamic>{
          'symbol': '',
          'date': '2023-02-01',
        }),
        isNull,
      );
      expect(EarningsDto.fromJson(<String, dynamic>{'symbol': 'AAPL'}), isNull);
      expect(
        EarningsDto.fromJson(<String, dynamic>{
          'symbol': 'AAPL',
          'date': 'soon',
        }),
        isNull,
      );
      expect(
        EarningsDto.fromJson(<String, dynamic>{
          'symbol': 'AAPL',
          'date': 20230201,
        }),
        isNull,
      );
      expect(EarningsDto.fromJson('AAPL'), isNull);
    });
  });

  group('parseEarnings', () {
    test('groups the valid rows by symbol', () {
      final bySymbol = parseEarnings('''
        [
          {"symbol": "AAPL", "date": "2026-07-30", "surprise_prc": 6.88},
          {"symbol": "KO", "date": "2026-07-21", "surprise_prc": "1.5"},
          {"symbol": "AAPL", "date": "oops"},
          42,
          {"symbol": "AAPL", "date": "2026-04-30"}
        ]
      ''');

      expect(bySymbol.keys, ['AAPL', 'KO']);
      expect(bySymbol['AAPL'], hasLength(2));
      expect(bySymbol['KO']!.single.surprisePercent, 1.5);
    });

    test('refuses a text that is not a JSON list', () {
      expect(() => parseEarnings('{}'), throwsFormatException);
      expect(() => parseEarnings('not json'), throwsFormatException);
    });

    test('the file shipped in the app is readable', () {
      final bySymbol = parseEarnings(
        File('assets/earnings.json').readAsStringSync(),
      );
      expect(bySymbol, isNotEmpty);
      for (final announcements in bySymbol.values) {
        expect(announcements, isNotEmpty);
      }
    });

    test('every stock of the catalogue has its announcements', () {
      final bySymbol = parseEarnings(
        File('assets/earnings.json').readAsStringSync(),
      );
      final catalog =
          jsonDecode(File('assets/catalog.json').readAsStringSync()) as List;
      final stocks = [
        for (final item in catalog)
          if ((item as Map)['type'] == 'stock') item['symbol'] as String,
      ];
      expect(stocks, hasLength(17));
      for (final symbol in stocks) {
        expect(bySymbol[symbol], isNotEmpty, reason: symbol);
      }
      // No ETF nor crypto: they publish no quarterly results.
      expect(bySymbol.keys.toSet().difference(stocks.toSet()), isEmpty);
    });

    test('no row of the file was dropped as unreadable', () {
      final json = File('assets/earnings.json').readAsStringSync();
      final parsed = parseEarnings(json).values.fold(0, (n, l) => n + l.length);
      expect(parsed, (jsonDecode(json) as List).length);
    });
  });
}
