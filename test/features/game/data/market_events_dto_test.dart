import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/features/catalog/domain/instrument.dart';
import 'package:lucide/features/game/data/market_events_dto.dart';

const valid = '''
{"id":"a","start":"2022-03-16","end":"2023-07-26","title":"T","summary":"S",
 "appliesTo":["stock","crypto"],
 "milestones":[{"date":"2022-03-16","text":"Premier fait"},
               {"date":"2022-05-04","text":"Second fait"}],
 "mechanism":"M",
 "sources":[{"label":"Fed","url":"https://www.federalreserve.gov/"}]}''';

void main() {
  group('parseMarketEvents', () {
    test('reads a complete event', () {
      final events = parseMarketEvents('[$valid]');
      expect(events, hasLength(1));
      expect(events.single.id, 'a');
      expect(events.single.start, DateTime.utc(2022, 3, 16));
      expect(events.single.appliesTo, {
        InstrumentType.stock,
        InstrumentType.crypto,
      });
      expect(events.single.sources.single.label, 'Fed');
      expect(events.single.mechanism, 'M');
      expect(events.single.milestones.map((m) => m.text), [
        'Premier fait',
        'Second fait',
      ]);
      expect(events.single.milestones.first.day, DateTime.utc(2022, 3, 16));
    });

    test('skips rows that cannot be used, keeps the others', () {
      final events = parseMarketEvents('''[
        $valid,
        {"id":"b","start":"nope","end":"2023-01-01","title":"T","summary":"S","mechanism":"M",
         "milestones":[{"date":"2023-01-01","text":"t"}],
         "appliesTo":["stock"],"sources":[{"label":"x","url":"u"}]},
        {"id":"c","start":"2023-02-01","end":"2023-01-01","title":"T",
         "summary":"S","mechanism":"M",
         "milestones":[{"date":"2023-01-01","text":"t"}],"appliesTo":["stock"],"sources":[{"label":"x","url":"u"}]},
        {"id":"d","start":"2023-01-01","end":"2023-02-01","title":"T",
         "summary":"S","mechanism":"M",
         "milestones":[{"date":"2023-01-01","text":"t"}],
         "appliesTo":["stock"],"sources":[]},
        {"id":"e","start":"2023-01-01","end":"2023-02-01","title":"T",
         "summary":"S","mechanism":"M","milestones":[{"date":"bad","text":"t"}],
         "appliesTo":["stock"],"sources":[{"label":"x","url":"u"}]},
        {"id":"f","start":"2023-01-01","end":"2023-02-01","title":"T",
         "summary":"S","appliesTo":["stock"],
         "sources":[{"label":"x","url":"u"}],
         "milestones":[{"date":"2023-01-01","text":"t"}]},
        {"title":"no id"},
        42
      ]''');
      expect(events.map((e) => e.id), ['a']);
    });

    test('a file that is not a list: format error', () {
      expect(() => parseMarketEvents('{}'), throwsFormatException);
      expect(() => parseMarketEvents('oops'), throwsFormatException);
    });
  });

  test('the file shipped with the app is complete', () {
    final json = File('assets/market_events.json').readAsStringSync();
    final events = parseMarketEvents(json);
    // No row was dropped for a missing field.
    expect(events.length, '"id"'.allMatches(json).length);
    expect(events, isNotEmpty);
    for (final event in events) {
      expect(event.summary, isNotEmpty, reason: event.id);
      expect(event.appliesTo, isNotEmpty, reason: event.id);
      expect(event.mechanism, isNotEmpty, reason: event.id);
      // The event begins with its first fact, and no fact is out of it.
      expect(event.milestones.first.day, event.start, reason: event.id);
      for (final milestone in event.milestones) {
        expect(milestone.text, isNotEmpty, reason: event.id);
        expect(milestone.day.isBefore(event.start), isFalse, reason: event.id);
        expect(milestone.day.isAfter(event.end), isFalse, reason: event.id);
      }
      for (final source in event.sources) {
        expect(Uri.parse(source.url).scheme, 'https', reason: event.id);
      }
    }
    expect(events.map((e) => e.id).toSet(), hasLength(events.length));
  });
}
