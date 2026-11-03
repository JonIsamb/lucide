import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/features/catalog/domain/weekly_candle.dart';
import 'package:lucide/features/game/domain/game_verdict.dart';
import 'package:lucide/features/game/domain/round_draw.dart';

import '../../../helpers.dart';

/// [weeks] candles, one per week, with a close going 50, 51, 52...
List<WeeklyCandle> rising(int weeks) =>
    weeklySeries([for (var i = 0; i < weeks; i++) 50.0 + i]);

GameSeries series(String symbol, List<WeeklyCandle> candles) =>
    GameSeries(asset: instrument(symbol), candles: candles);

void main() {
  group('windowStarts', () {
    test('needs 30 weeks in a row', () {
      expect(windowStarts(const []), isEmpty);
      expect(windowStarts(rising(29)), isEmpty);
      expect(windowStarts(rising(30)), [0]);
      expect(windowStarts(rising(33)), [0, 1, 2, 3]);
    });

    test('a missing week cuts the series in two', () {
      // 45 weeks without the 31st: 30 weeks, a hole, then 14 weeks.
      final candles = rising(45)..removeAt(30);
      expect(windowStarts(candles), [0]);

      // Without the 6th: 5 weeks, a hole, then 39 weeks.
      final late = rising(45)..removeAt(5);
      expect(windowStarts(late), [for (var i = 5; i <= 14; i++) i]);
    });

    test('a week shifted by a bank holiday is still the next week', () {
      final candles = rising(30);
      // Tuesday instead of Monday: 8 days after the previous candle.
      candles[10] = candle(
        candles[10].date.add(const Duration(days: 1)),
        candles[10].close,
      );
      expect(windowStarts(candles), [0]);
    });

    test('a price of zero cannot be part of a window', () {
      final candles = rising(40);
      candles[20] = candle(candles[20].date, 0);
      expect(windowStarts(candles), isEmpty);

      candles[20] = candle(candles[20].date, 70);
      candles[0] = candle(candles[0].date, 0);
      expect(windowStarts(candles), [for (var i = 1; i <= 10; i++) i]);
    });
  });

  group('drawRounds', () {
    final store = [
      for (final symbol in ['A', 'B', 'C', 'D']) series(symbol, rising(260)),
    ];

    test('gives 10 rounds of 26 + 4 weeks, rebased to 100', () {
      final rounds = drawRounds(store, Random(1));

      expect(rounds, hasLength(roundsPerGame));
      for (final round in rounds) {
        expect(round.history, hasLength(visibleWeeks));
        expect(round.future, hasLength(hiddenWeeks));
        expect(round.history.first, 100);
        expect(round.end.difference(round.start).inDays, 7 * 29);
      }
    });

    test('keeps the real asset, dates and price moves', () {
      final rounds = drawRounds([series('A', rising(30))], Random(1), count: 1);
      final round = rounds.single;

      expect(round.asset.symbol, 'A');
      expect(round.start, DateTime.utc(2025, 10, 6));
      expect(round.end, DateTime.utc(2025, 10, 6 + 7 * 29));
      // 50 -> 75 on the visible weeks, 79 at the end: 150 and 158 in base 100.
      expect(round.history.last, closeTo(150, 1e-9));
      expect(round.future.last, closeTo(158, 1e-9));
    });

    test('the same seed draws the same game', () {
      String key(List<dynamic> rounds) =>
          [for (final r in rounds) '${r.asset.symbol} ${r.start}'].join('|');

      final first = drawRounds(store, Random(42));
      final again = drawRounds(store, Random(42));
      final other = drawRounds(store, Random(43));

      expect(key(again), key(first));
      expect(key(other), isNot(key(first)));
    });

    test('two rounds never share a week of the same asset', () {
      for (var seed = 0; seed < 20; seed++) {
        final rounds = drawRounds(store, Random(seed));
        for (final a in rounds) {
          for (final b in rounds) {
            if (identical(a, b) || a.asset.symbol != b.asset.symbol) continue;
            final apart = a.start.difference(b.start).inDays.abs();
            expect(apart, greaterThanOrEqualTo(7 * windowWeeks));
          }
        }
      }
    });

    test('impossible window: no game without 30 weeks in a row', () {
      expect(drawRounds(const [], Random(1)), isEmpty);
      expect(drawRounds([series('A', rising(29))], Random(1)), isEmpty);
    });

    test('no shorter game when fewer than 10 rounds can be drawn', () {
      // One window per asset: 9 assets give 9 rounds at most.
      final nine = [for (var i = 0; i < 9; i++) series('S$i', rising(30))];
      expect(drawRounds(nine, Random(1)), isEmpty);

      final ten = [...nine, series('S9', rising(30))];
      expect(drawRounds(ten, Random(1)), hasLength(10));
    });
  });
}
