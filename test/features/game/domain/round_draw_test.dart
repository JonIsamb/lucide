import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/features/catalog/domain/instrument.dart';
import 'package:lucide/features/catalog/domain/weekly_candle.dart';
import 'package:lucide/features/game/domain/earnings_announcement.dart';
import 'package:lucide/features/game/domain/game_verdict.dart';
import 'package:lucide/features/game/domain/market_event.dart';
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

  group('what the player may see before the bet', () {
    // 30 weeks from Monday 6 October 2025. The 26 visible weeks end on
    // Sunday 5 April 2026 (week 25 starts on 30 March); week 26 starts on
    // 6 April and is the first hidden one.
    MarketEvent event(String id, DateTime start, DateTime end) => MarketEvent(
      id: id,
      start: start,
      end: end,
      title: id,
      milestones: [Milestone(day: start, text: 'fait')],
      mechanism: 'mécanisme',
      summary: 'suite',
      appliesTo: const {InstrumentType.stock},
      sources: const [EventSource(label: 'x', url: 'https://example.org')],
    );

    final early = event(
      'early',
      DateTime.utc(2025, 12, 15),
      DateTime.utc(2026, 1, 15),
    );
    final lastVisibleDay = event(
      'last-visible-day',
      DateTime.utc(2026, 4, 5),
      DateTime.utc(2026, 4, 30),
    );
    final hidden = event(
      'hidden',
      DateTime.utc(2026, 4, 6),
      DateTime.utc(2026, 5, 15),
    );

    GameSeries withAnnouncements(List<EarningsAnnouncement> list) => GameSeries(
      asset: instrument('A'),
      candles: rising(30),
      announcements: list,
    );

    test('an event that starts in the hidden weeks is not in the context', () {
      final round = drawRounds(
        [series('A', rising(30))],
        Random(1),
        count: 1,
        events: [early, lastVisibleDay, hidden],
      ).single;

      // The explanation, after the answer, has all of them.
      expect(round.events.map((e) => e.id), [
        'early',
        'last-visible-day',
        'hidden',
      ]);
      // The context, before the answer, stops at the last visible day.
      expect(round.contextEvents.map((e) => e.id), [
        'early',
        'last-visible-day',
      ]);
    });

    test('the visible weeks end the day before the first hidden week', () {
      final round = drawRounds(
        [series('A', rising(30))],
        Random(1),
        count: 1,
      ).single;
      expect(round.visibleEnd, DateTime.utc(2026, 3, 30));
      expect(round.hiddenStart, DateTime.utc(2026, 4, 6));
    });

    test('announcements: those of the hidden weeks wait for the answer', () {
      final round = drawRounds(
        [
          withAnnouncements([
            EarningsAnnouncement(day: DateTime.utc(2025, 10, 5)), // before
            EarningsAnnouncement(day: DateTime.utc(2025, 10, 30)),
            EarningsAnnouncement(day: DateTime.utc(2026, 4, 5)), // last visible
            EarningsAnnouncement(day: DateTime.utc(2026, 4, 6)), // hidden
            EarningsAnnouncement(day: DateTime.utc(2026, 4, 30)),
            EarningsAnnouncement(day: DateTime.utc(2026, 5, 4)), // after
          ]),
        ],
        Random(1),
        count: 1,
      ).single;

      expect(
        [for (final a in round.earnings) a.day],
        [
          DateTime.utc(2025, 10, 30),
          DateTime.utc(2026, 4, 5),
          DateTime.utc(2026, 4, 6),
          DateTime.utc(2026, 4, 30),
        ],
      );
      expect(
        [for (final a in round.visibleEarnings) a.day],
        [DateTime.utc(2025, 10, 30), DateTime.utc(2026, 4, 5)],
      );
    });
  });
}
