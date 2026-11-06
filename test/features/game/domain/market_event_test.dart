import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/features/catalog/domain/instrument.dart';
import 'package:lucide/features/game/domain/market_event.dart';

MarketEvent event(
  String id,
  String start,
  String end, {
  Set<InstrumentType> appliesTo = const {
    InstrumentType.stock,
    InstrumentType.etf,
    InstrumentType.crypto,
  },
}) => MarketEvent(
  id: id,
  start: DateTime.utc(
    int.parse(start.substring(0, 4)),
    int.parse(start.substring(5, 7)),
    int.parse(start.substring(8)),
  ),
  end: DateTime.utc(
    int.parse(end.substring(0, 4)),
    int.parse(end.substring(5, 7)),
    int.parse(end.substring(8)),
  ),
  title: id,
  milestones: [Milestone(day: DateTime.utc(2022, 3, 1), text: 'm')],
  mechanism: 'mécanisme',
  summary: '',
  appliesTo: appliesTo,
  sources: const [EventSource(label: 'x', url: 'https://example.org')],
);

void main() {
  final from = DateTime.utc(2022, 1, 3);
  final to = DateTime.utc(2022, 7, 25);

  List<String> ids(List<MarketEvent> events, {InstrumentType? type}) => [
    for (final e in eventsDuring(
      events,
      from: from,
      to: to,
      type: type ?? InstrumentType.stock,
    ))
      e.id,
  ];

  group('overlapDays', () {
    test('counts both ends', () {
      final e = event('a', '2022-01-03', '2022-01-05');
      expect(overlapDays(e, from, to), 3);
    });

    test('0 when the event ends the day before or starts the day after', () {
      expect(overlapDays(event('a', '2021-12-01', '2022-01-02'), from, to), 0);
      expect(overlapDays(event('a', '2022-07-26', '2022-08-01'), from, to), 0);
    });

    test('an event that ends on the first day still overlaps', () {
      expect(overlapDays(event('a', '2021-12-01', '2022-01-03'), from, to), 1);
    });
  });

  group('eventsDuring', () {
    test('keeps overlapping events, oldest first', () {
      final events = [
        event('late', '2022-05-01', '2022-05-10'),
        event('early', '2022-02-01', '2022-02-10'),
        event('outside', '2023-01-01', '2023-01-10'),
      ];
      expect(ids(events), ['early', 'late']);
    });

    test('an event may start before and end after the period', () {
      expect(ids([event('long', '2021-01-01', '2023-12-31')]), ['long']);
    });

    test('skips events about another kind of asset', () {
      final events = [
        event(
          'crypto',
          '2022-05-01',
          '2022-05-31',
          appliesTo: {InstrumentType.crypto},
        ),
        event('all', '2022-03-01', '2022-03-31'),
      ];
      expect(ids(events), ['all']);
      expect(ids(events, type: InstrumentType.crypto), ['all', 'crypto']);
    });

    test('nothing in store: empty', () {
      expect(ids(const []), isEmpty);
    });

    test('keeps the 3 events with the most days in the period', () {
      final events = [
        event('a', '2022-01-10', '2022-01-12'), // 3 days
        event('b', '2022-02-01', '2022-02-20'), // 20 days
        event('c', '2022-03-01', '2022-03-10'), // 10 days
        event('d', '2022-04-01', '2022-04-05'), // 5 days
      ];
      expect(ids(events), ['b', 'c', 'd']);
    });
  });

  group('milestonesBefore', () {
    final e = MarketEvent(
      id: 'x',
      start: DateTime.utc(2022, 3, 16),
      end: DateTime.utc(2023, 7, 26),
      title: 'x',
      milestones: [
        Milestone(day: DateTime.utc(2022, 3, 16), text: 'a'),
        Milestone(day: DateTime.utc(2022, 5, 4), text: 'b'),
        Milestone(day: DateTime.utc(2023, 7, 26), text: 'c'),
      ],
      mechanism: '',
      summary: '',
      appliesTo: const {InstrumentType.stock},
      sources: const [],
    );

    List<String> texts(DateTime cutoff) => [
      for (final m in milestonesBefore(e, cutoff)) m.text,
    ];

    test('keeps only the facts dated before the cutoff', () {
      expect(texts(DateTime.utc(2022, 6, 1)), ['a', 'b']);
      expect(texts(DateTime.utc(2024, 1, 1)), ['a', 'b', 'c']);
    });

    test('the cutoff day itself is excluded: it is a hidden week', () {
      expect(texts(DateTime.utc(2022, 5, 4)), ['a']);
      expect(texts(DateTime.utc(2022, 3, 16)), isEmpty);
    });
  });
}
