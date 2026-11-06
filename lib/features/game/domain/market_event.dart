// The real events that can explain why the market moved during a round.
// Pure Dart. The list ships with the app (assets/market_events.json), so
// the explanation works offline. Every event carries its sources.

import '../../catalog/domain/instrument.dart';

/// A page that backs an event.
class EventSource {
  const EventSource({required this.label, required this.url});

  final String label;
  final String url;
}

/// A dated fact of an event: what was known on [day].
class Milestone {
  const Milestone({required this.day, required this.text});

  final DateTime day;
  final String text;
}

/// A dated event that moved, or is commonly said to have moved, markets.
class MarketEvent {
  const MarketEvent({
    required this.id,
    required this.start,
    required this.end,
    required this.title,
    required this.milestones,
    required this.mechanism,
    required this.summary,
    required this.appliesTo,
    required this.sources,
  });

  final String id;

  /// First and last day during which the event is relevant, included.
  final DateTime start;
  final DateTime end;

  final String title;

  /// The dated facts, oldest first. Before the player answers, only those
  /// dated before the hidden weeks are shown: later ones would give the
  /// answer away.
  final List<Milestone> milestones;

  /// How markets usually read this kind of event. Says nothing about what
  /// the price did afterwards, so it can be shown before the answer.
  final String mechanism;

  /// The whole story for a beginner, facts and reading. Shown only once
  /// the player has answered and asks for the explanation.
  final String summary;

  /// The kinds of assets concerned: a crypto failure says nothing about a
  /// bank stock, a rate decision concerns everything.
  final Set<InstrumentType> appliesTo;
  final List<EventSource> sources;
}

/// The most events shown for one round: more would bury the explanation.
const maxEventsPerRound = 3;

/// Days of [event] that fall inside the period [from]..[to] (included).
/// 0 when they do not overlap.
int overlapDays(MarketEvent event, DateTime from, DateTime to) {
  final start = event.start.isAfter(from) ? event.start : from;
  final end = event.end.isBefore(to) ? event.end : to;
  if (end.isBefore(start)) return 0;
  return end.difference(start).inDays + 1;
}

/// The events of [events] that concern [type] and overlap the period
/// [from]..[to], oldest first.
///
/// When more than [maxEventsPerRound] qualify, the ones that cover the
/// most days of the period are kept.
List<MarketEvent> eventsDuring(
  List<MarketEvent> events, {
  required DateTime from,
  required DateTime to,
  required InstrumentType type,
}) {
  final matching = [
    for (final event in events)
      if (event.appliesTo.contains(type) && overlapDays(event, from, to) > 0)
        event,
  ];
  matching.sort(
    (a, b) => overlapDays(b, from, to).compareTo(overlapDays(a, from, to)),
  );
  final kept = matching.take(maxEventsPerRound).toList()
    ..sort((a, b) => a.start.compareTo(b.start));
  return kept;
}

/// The milestones of [event] dated before [cutoff] (excluded).
List<Milestone> milestonesBefore(MarketEvent event, DateTime cutoff) => [
  for (final milestone in event.milestones)
    if (milestone.day.isBefore(cutoff)) milestone,
];
