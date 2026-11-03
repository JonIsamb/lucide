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

  GameRepository game({int seed = 1, Future<String> Function()? earnings}) =>
      GameRepository(
        catalog: catalog,
        random: Random(seed),
        loadEarningsJson: earnings ?? () async => earningsJson,
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
        // One announcement per visible week, none from the hidden weeks.
        expect(
          [for (final h in round.hints) h.weeksAgo],
          [for (var weeks = 25; weeks >= 0; weeks--) weeks],
        );
      } else {
        expect(round.hints, isEmpty);
      }
    }
  });

  test('an unreadable announcements file only removes the hints', () async {
    api.series['AAA'] = weeklySeries([for (var i = 0; i < 200; i++) 80.0 + i]);
    api.series['BBB'] = weeklySeries([for (var i = 0; i < 200; i++) 300.0 - i]);
    await catalog.refreshSeries('AAA');
    await catalog.refreshSeries('BBB');

    for (final earnings in <Future<String> Function()>[
      () async => 'not json',
      () async => throw Exception('missing asset'),
    ]) {
      final rounds = await game(earnings: earnings).drawGame();
      expect(rounds, hasLength(10));
      expect(rounds.every((round) => round.hints.isEmpty), isTrue);
    }
  });

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
}
