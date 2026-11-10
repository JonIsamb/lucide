import 'dart:convert';

import '../domain/earnings_announcement.dart';

/// One row of assets/earnings.json. The field names are those of the
/// Twelve Data `/earnings` answer, so new rows can be pasted as they are.
class EarningsDto {
  const EarningsDto({
    required this.symbol,
    required this.day,
    this.surprisePercent,
  });

  final String symbol;
  final DateTime day;
  final double? surprisePercent;

  /// Null when the row cannot be used (no symbol or no valid date): it is
  /// skipped instead of crashing the game.
  static EarningsDto? fromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final symbol = json['symbol'];
    final date = json['date'];
    if (symbol is! String || symbol.isEmpty || date is! String) return null;
    final day = DateTime.tryParse('${date}T00:00:00Z');
    if (day == null) return null;
    return EarningsDto(
      symbol: symbol,
      day: day,
      surprisePercent: _toDouble(json['surprise_prc']),
    );
  }

  /// Numbers sometimes arrive as strings ("6.88"). Anything else is null.
  static double? _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  EarningsAnnouncement toEntity() =>
      EarningsAnnouncement(day: day, surprisePercent: surprisePercent);
}

/// Reads assets/earnings.json: the announcements of each symbol.
/// Throws a [FormatException] when the text is not a JSON list.
Map<String, List<EarningsAnnouncement>> parseEarnings(String json) {
  final decoded = jsonDecode(json);
  if (decoded is! List) throw const FormatException('Expected a JSON list');

  final bySymbol = <String, List<EarningsAnnouncement>>{};
  for (final item in decoded) {
    final dto = EarningsDto.fromJson(item);
    if (dto == null) continue;
    bySymbol.putIfAbsent(dto.symbol, () => []).add(dto.toEntity());
  }
  return bySymbol;
}
