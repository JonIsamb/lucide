import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/core/network/market_data_router.dart';

import '../../helpers.dart';

void main() {
  late FakeApi us;
  late FakeApi paris;
  late MarketDataRouter router;

  setUp(() {
    us = FakeApi();
    paris = FakeApi()..sources['Euronext Paris'] = 'paris';
    router = MarketDataRouter(
      defaultApi: us,
      byExchange: {'Euronext Paris': paris},
    );
  });

  test('a listed exchange goes to its provider', () async {
    await router.fetchWeeklySeries('MC', exchange: 'Euronext Paris');
    await router.fetchLogoUrl('MC', exchange: 'Euronext Paris');

    expect(paris.seriesCalls.single.$1, 'MC');
    expect(paris.logoCalls, ['MC']);
    expect(us.seriesCalls, isEmpty);
    expect(router.sourceFor('Euronext Paris'), 'paris');
  });

  test('every other exchange, or none, goes to the default one', () async {
    await router.fetchWeeklySeries('AAPL', exchange: 'NASDAQ');
    await router.fetchWeeklySeries('BTC/EUR');

    expect(us.seriesCalls.map((c) => c.$1), ['AAPL', 'BTC/EUR']);
    expect(paris.seriesCalls, isEmpty);
    expect(router.sourceFor(null), 'fake');
  });

  test('the start date is passed on', () async {
    final start = DateTime.utc(2026, 11, 2);
    await router.fetchWeeklySeries(
      'MC',
      exchange: 'Euronext Paris',
      startDate: start,
    );
    expect(paris.seriesCalls.single.$2, start);
  });
}
