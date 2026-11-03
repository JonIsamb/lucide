// The hint mode: what a company announced during the visible weeks.
// Pure Dart. The hint never gives the asset's name nor a date, only how
// long ago the announcement was and how it compared with expectations.

/// A quarterly earnings announcement of a company.
class EarningsAnnouncement {
  const EarningsAnnouncement({required this.day, this.surprisePercent});

  /// Day of the announcement (date only).
  final DateTime day;

  /// Gap between the published earnings per share and what analysts
  /// expected, in %. Positive: better than expected. Null when unknown.
  final double? surprisePercent;
}

/// How the published earnings compared with what analysts expected.
enum EarningsSurprise { above, inLine, below, unknown }

/// One announcement, placed on the curve the player sees.
class EarningsHint {
  const EarningsHint({required this.weeksAgo, this.surprisePercent});

  /// Weeks between the announcement and the last visible week.
  /// 0: during the last visible week.
  final int weeksAgo;

  final double? surprisePercent;

  EarningsSurprise get surprise {
    final value = surprisePercent;
    if (value == null) return EarningsSurprise.unknown;
    if (value > 0) return EarningsSurprise.above;
    if (value < 0) return EarningsSurprise.below;
    return EarningsSurprise.inLine;
  }
}

/// The announcements published during the visible weeks, oldest first.
///
/// [weekStarts] is the first day of every week of the round, visible then
/// hidden. An announcement belongs to the last week that started on or
/// before its day. Those of the hidden weeks are left out: the player
/// must not learn anything about the weeks to guess.
List<EarningsHint> earningsHints({
  required List<DateTime> weekStarts,
  required int visibleWeeks,
  required List<EarningsAnnouncement> announcements,
}) {
  if (weekStarts.length < visibleWeeks || visibleWeeks == 0) return const [];

  final hints = <EarningsHint>[];
  for (final announcement in announcements) {
    final day = announcement.day;
    if (day.isBefore(weekStarts.first)) continue;
    // Without hidden weeks, the visible ones are assumed to last 7 days.
    final hiddenStart = weekStarts.length > visibleWeeks
        ? weekStarts[visibleWeeks]
        : weekStarts[visibleWeeks - 1].add(const Duration(days: 7));
    if (!day.isBefore(hiddenStart)) continue;

    var week = 0;
    while (week + 1 < visibleWeeks && !day.isBefore(weekStarts[week + 1])) {
      week++;
    }
    hints.add(
      EarningsHint(
        weeksAgo: visibleWeeks - 1 - week,
        surprisePercent: announcement.surprisePercent,
      ),
    );
  }
  // Oldest first: the highest "weeks ago" comes first.
  hints.sort((a, b) => b.weeksAgo.compareTo(a.weeksAgo));
  return hints;
}
