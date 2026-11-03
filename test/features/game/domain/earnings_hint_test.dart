import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/features/game/domain/earnings_hint.dart';
import 'package:lucide/features/game/domain/round_draw.dart';

import '../../../helpers.dart';

/// 30 Mondays from 6 October 2025: 26 visible weeks, then 4 hidden ones.
final weekStarts = [
  for (var i = 0; i < 30; i++) DateTime.utc(2025, 10, 6 + 7 * i),
];

List<EarningsHint> hintsFor(List<EarningsAnnouncement> announcements) =>
    earningsHints(
      weekStarts: weekStarts,
      visibleWeeks: 26,
      announcements: announcements,
    );

EarningsAnnouncement on(DateTime day, [double? surprise]) =>
    EarningsAnnouncement(day: day, surprisePercent: surprise);

void main() {
  group('earningsHints', () {
    test('no announcement, no hint', () {
      expect(hintsFor(const []), isEmpty);
    });

    test('counts the weeks back from the last visible week', () {
      // Week 25 (the last visible one) starts on 30 March 2026.
      final lastWeek = hintsFor([on(DateTime.utc(2026, 4, 1), 6.88)]);
      expect(lastWeek.single.weeksAgo, 0);
      expect(lastWeek.single.surprisePercent, 6.88);

      // Thursday of the first visible week.
      final firstWeek = hintsFor([on(DateTime.utc(2025, 10, 9))]);
      expect(firstWeek.single.weeksAgo, 25);
    });

    test('the first and last days of a week belong to that week', () {
      // Monday 3 November 2025 opens week 4; Sunday 9 closes it.
      expect(hintsFor([on(DateTime.utc(2025, 11, 3))]).single.weeksAgo, 21);
      expect(hintsFor([on(DateTime.utc(2025, 11, 9))]).single.weeksAgo, 21);
      expect(hintsFor([on(DateTime.utc(2025, 11, 10))]).single.weeksAgo, 20);
    });

    test('announcements outside the visible weeks are left out', () {
      final hints = hintsFor([
        on(DateTime.utc(2025, 10, 5)), // the day before the first week
        on(DateTime.utc(2026, 4, 6)), // first hidden week
        on(DateTime.utc(2026, 4, 27)), // last hidden week
        on(DateTime.utc(2026, 6, 1)), // after the round
      ]);
      expect(hints, isEmpty);
    });

    test('several announcements come oldest first', () {
      final hints = hintsFor([
        on(DateTime.utc(2026, 1, 29), 6.37),
        on(DateTime.utc(2025, 10, 30), -4.5),
      ]);
      expect([for (final h in hints) h.weeksAgo], [22, 9]);
      expect([for (final h in hints) h.surprisePercent], [-4.5, 6.37]);
    });

    test('too few weeks: no hint', () {
      final hints = earningsHints(
        weekStarts: weekStarts.sublist(0, 10),
        visibleWeeks: 26,
        announcements: [on(DateTime.utc(2025, 10, 9))],
      );
      expect(hints, isEmpty);
    });
  });

  test('surprise: above, below, in line, unknown', () {
    EarningsSurprise of(double? value) =>
        EarningsHint(weeksAgo: 0, surprisePercent: value).surprise;

    expect(of(6.88), EarningsSurprise.above);
    expect(of(-3.09), EarningsSurprise.below);
    expect(of(0), EarningsSurprise.inLine);
    expect(of(null), EarningsSurprise.unknown);
  });

  test('a drawn round carries the hints of its own weeks only', () {
    final series = GameSeries(
      asset: instrument('A'),
      candles: weeklySeries([for (var i = 0; i < 30; i++) 50.0 + i]),
      announcements: [
        on(DateTime.utc(2025, 10, 30), 4.52),
        on(DateTime.utc(2026, 4, 30), 3.61), // hidden weeks
      ],
    );
    final round = drawRounds([series], Random(1), count: 1).single;

    expect(round.hints, hasLength(1));
    expect(round.hints.single.weeksAgo, 22);
    expect(round.hints.single.surprisePercent, 4.52);
  });
}
