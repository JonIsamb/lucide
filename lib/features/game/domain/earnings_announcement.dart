// A company's quarterly earnings announcement. Pure Dart.

/// A quarterly earnings announcement of a company.
class EarningsAnnouncement {
  const EarningsAnnouncement({required this.day, this.surprisePercent});

  /// Day of the announcement (date only).
  final DateTime day;

  /// Gap between the published earnings per share and what analysts
  /// expected, in %. Positive: better than expected. Null when unknown
  /// (the free source of the dates gives no expectations).
  final double? surprisePercent;
}
