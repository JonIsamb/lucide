import 'dart:convert';

import '../../catalog/domain/instrument.dart';
import '../domain/market_event.dart';

/// Reads assets/market_events.json. Throws a [FormatException] when the
/// text is not a JSON list. A row that cannot be used (missing field,
/// invalid date, no source) is skipped: an explanation without an event
/// is better than a crash.
List<MarketEvent> parseMarketEvents(String json) {
  final decoded = jsonDecode(json);
  if (decoded is! List) throw const FormatException('Expected a JSON list');
  return [
    for (final item in decoded)
      if (_fromJson(item) case final MarketEvent event) event,
  ];
}

MarketEvent? _fromJson(Object? json) {
  if (json is! Map<String, dynamic>) return null;
  final id = json['id'];
  final title = json['title'];
  final summary = json['summary'];
  final mechanism = json['mechanism'];
  if (id is! String ||
      title is! String ||
      summary is! String ||
      mechanism is! String) {
    return null;
  }

  final start = _day(json['start']);
  final end = _day(json['end']);
  if (start == null || end == null || end.isBefore(start)) return null;

  final types = json['appliesTo'];
  final sources = json['sources'];
  final rawMilestones = json['milestones'];
  if (types is! List || sources is! List || rawMilestones is! List) return null;

  final milestones = [
    for (final item in rawMilestones)
      if (_milestone(item) case final Milestone milestone) milestone,
  ]..sort((a, b) => a.day.compareTo(b.day));
  // An event with no dated fact cannot be placed before or after a round.
  if (milestones.isEmpty) return null;

  final parsedSources = [
    for (final source in sources)
      if (source is Map<String, dynamic> &&
          source['label'] is String &&
          source['url'] is String)
        EventSource(
          label: source['label'] as String,
          url: source['url'] as String,
        ),
  ];
  // An event nobody can check is not shown.
  if (parsedSources.isEmpty) return null;

  return MarketEvent(
    id: id,
    start: start,
    end: end,
    title: title,
    milestones: milestones,
    mechanism: mechanism,
    summary: summary,
    appliesTo: {
      for (final type in types)
        if (type is String) InstrumentType.fromName(type),
    },
    sources: parsedSources,
  );
}

DateTime? _day(Object? value) =>
    value is String ? DateTime.tryParse('${value}T00:00:00Z') : null;

Milestone? _milestone(Object? json) {
  if (json is! Map<String, dynamic>) return null;
  final text = json['text'];
  final day = _day(json['date']);
  if (text is! String || day == null) return null;
  return Milestone(day: day, text: text);
}
