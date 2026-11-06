import 'dart:convert';
import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/core/database/app_database.dart';
import 'package:lucide/features/catalog/data/catalog_repository.dart';
import 'package:lucide/features/game/data/game_repository.dart';
import 'package:lucide/features/game/domain/round_draw.dart';

import '../../../helpers.dart';

const catalogJson = '''
[
  {"symbol": "AAA", "name": "Alpha", "type": "stock", "description": "Une entreprise."},
  {"symbol": "BBB", "name": "Beta", "type": "etf", "description": "Un panier."}
]
''';

void main() {
  late AppDatabase db;
  late FakeApi api;
  late CatalogRepository catalog;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    api = FakeApi();
    catalog = CatalogRepository(
      database: db,
      api: api,
      loadCatalogJson: () async => catalogJson,
    );
    await catalog.seedCatalog();
  });

  tearDown(() => db.close());

  // Alpha publishes its results every Thursday; Beta (an ETF) never does.
  final earningsJson = jsonEncode([
    for (var i = 0; i < 200; i++)
      {
        'symbol': 'AAA',
        'date': DateTime.utc(
          2025,
          10,
          9 + 7 * i,
        ).toIso8601String().substring(0, 10),
        'surprise_prc': 2.5,
      },
  ]);

  // One event in the winter 2025-2026, for stocks and ETFs only.
  const eventsJson = '''
[{"id":"winter","start":"2026-01-01","end":"2026-02-01","title":"T","summary":"S",
  "mechanism":"M","milestones":[{"date":"2026-01-01","text":"t"}],
  "appliesTo":["stock","etf"],
  "sources":[{"label":"x","url":"https://example.org"}]}]''';

  GameRepository game({
    int seed = 1,
    Future<String> Function()? earnings,
    Future<String> Function()? events,
  }) => GameRepository(
    catalog: catalog,
    random: Random(seed),
    loadEarningsJson: earnings ?? () async => earningsJson,
    loadEventsJson: events ?? () async => eventsJson,
  );

  test('no price stored: no game', () async {
    expect(await game().drawGame(), isEmpty);
  });

  test(
    'rounds are cut out of the stored prices, without the network',
    () async {
      api.series['AAA'] = weeklySeries([
        for (var i = 0; i < 200; i++) 80.0 + i,
      ]);
      api.series['BBB'] = weeklySeries([
        for (var i = 0; i < 200; i++) 300.0 - i,
      ]);
      await catalog.refreshSeries('AAA');
      await catalog.refreshSeries('BBB');
      final callsBefore = api.seriesCalls.length;

      final rounds = await game().drawGame();

      expect(rounds, hasLength(10));
      expect(api.seriesCalls, hasLength(callsBefore));
      for (final round in rounds) {
        expect(['Alpha', 'Beta'], contains(round.asset.name));
        expect(round.asset.description, isNotEmpty);
        // AAA only rises and BBB only falls: the curve matches its asset.
        final rises = round.future.last > round.history.last;
        expect(rises, round.asset.symbol == 'AAA');
      }
    },
  );

  test('the current, unfinished week is never part of a round', () async {
    // A flat price, except the last stored week (the current one).
    final closes = [for (var i = 0; i < 200; i++) 100.0]..last = 500;
    api.series['AAA'] = weeklySeries(closes);
    await catalog.refreshSeries('AAA');

    for (var seed = 0; seed < 30; seed++) {
      // 199 completed weeks give 6 windows that do not overlap at most.
      final rounds = drawRounds(
        await game().loadSeries(),
        Random(seed),
        count: 3,
      );
      expect(rounds, hasLength(3));
      for (final round in rounds) {
        expect(round.future.last, 100);
      }
    }
  });

  test('rounds carry the announcements of their own asset', () async {
    api.series['AAA'] = weeklySeries([for (var i = 0; i < 200; i++) 80.0 + i]);
    api.series['BBB'] = weeklySeries([for (var i = 0; i < 200; i++) 300.0 - i]);
    await catalog.refreshSeries('AAA');
    await catalog.refreshSeries('BBB');

    for (final round in await game().drawGame()) {
      if (round.asset.symbol == 'AAA') {
        // One announcement per week: 30 in the round, 26 known before the bet.
        expect(round.earnings, hasLength(30));
        expect(round.visibleEarnings, hasLength(26));
        for (final announcement in round.visibleEarnings) {
          expect(announcement.day.isBefore(round.hiddenStart), isTrue);
        }
      } else {
        expect(round.earnings, isEmpty);
        expect(round.visibleEarnings, isEmpty);
      }
    }
  });

  test(
    'an unreadable announcements file only removes the announcements',
    () async {
      api.series['AAA'] = weeklySeries([
        for (var i = 0; i < 200; i++) 80.0 + i,
      ]);
      api.series['BBB'] = weeklySeries([
        for (var i = 0; i < 200; i++) 300.0 - i,
      ]);
      await catalog.refreshSeries('AAA');
      await catalog.refreshSeries('BBB');

      for (final earnings in <Future<String> Function()>[
        () async => 'not json',
        () async => throw Exception('missing asset'),
      ]) {
        final rounds = await game(earnings: earnings).drawGame();
        expect(rounds, hasLength(10));
        expect(rounds.every((round) => round.earnings.isEmpty), isTrue);
      }
    },
  );

  test('the same seed draws the same game', () async {
    api.series['AAA'] = weeklySeries([for (var i = 0; i < 200; i++) 80.0 + i]);
    api.series['BBB'] = weeklySeries([for (var i = 0; i < 200; i++) 300.0 - i]);
    await catalog.refreshSeries('AAA');
    await catalog.refreshSeries('BBB');

    final first = await game(seed: 7).drawGame();
    final again = await game(seed: 7).drawGame();

    expect(
      [for (final r in again) '${r.asset.symbol} ${r.start}'],
      [for (final r in first) '${r.asset.symbol} ${r.start}'],
    );
  });

  test('rounds carry the events that overlap them, and all earnings', () async {
    api.series['AAA'] = weeklySeries([for (var i = 0; i < 200; i++) 80.0 + i]);
    await catalog.refreshSeries('AAA');
    final event = DateTime.utc(2026, 1, 1);

    for (final round in await game().drawGame()) {
      final overlaps =
          !round.end.isBefore(event) &&
          !round.start.isAfter(DateTime.utc(2026, 2, 1));
      expect(round.events.map((e) => e.id), overlaps ? ['winter'] : isEmpty);
      // Earnings every week: the 30 weeks of the round, hidden ones too.
      expect(round.earnings, hasLength(30));
    }
  });

  test('an unreadable events file only removes the explanation', () async {
    api.series['AAA'] = weeklySeries([for (var i = 0; i < 200; i++) 80.0 + i]);
    api.series['BBB'] = weeklySeries([for (var i = 0; i < 200; i++) 300.0 - i]);
    await catalog.refreshSeries('AAA');
    await catalog.refreshSeries('BBB');

    for (final events in <Future<String> Function()>[
      () async => 'not json',
      () async => throw Exception('missing asset'),
      () async => throw StateError('asset bundle error'),
    ]) {
      final rounds = await game(events: events).drawGame();
      expect(rounds, hasLength(10));
      expect(rounds.every((r) => r.events.isEmpty), isTrue);
    }
  });
}
