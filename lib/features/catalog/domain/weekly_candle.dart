/// One week of prices for an asset (a "candle").
///
/// The same weekly series feeds the catalogue, the detail screen and the
/// game, so we keep every field even if the catalogue only needs `close`.
class WeeklyCandle {
  const WeeklyCandle({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.volume,
  });

  /// First trading day of the week, as sent by Twelve Data (date only).
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;

  /// Null when the API does not send it (often the case for cryptos).
  final double? volume;

  @override
  bool operator ==(Object other) =>
      other is WeeklyCandle &&
      other.date == date &&
      other.open == open &&
      other.high == high &&
      other.low == low &&
      other.close == close &&
      other.volume == volume;

  @override
  int get hashCode => Object.hash(date, open, high, low, close, volume);

  @override
  String toString() => 'WeeklyCandle(${date.toIso8601String()}, close: $close)';
}
