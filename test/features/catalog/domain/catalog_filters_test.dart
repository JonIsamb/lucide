import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/features/catalog/domain/catalog_filters.dart';
import 'package:lucide/features/catalog/domain/instrument.dart';

import '../../../helpers.dart';

void main() {
  final assets = [
    overview('AAPL', name: 'Apple', change: 22.3),
    overview('SPY', name: 'S&P 500', type: InstrumentType.etf, change: 31.5),
    overview(
      'BTC/EUR',
      name: 'Bitcoin',
      type: InstrumentType.crypto,
      change: 62.1,
    ),
    overview('INTC', name: 'Intel', change: -45.6),
    overview('SOC', name: 'Société Test'),
  ];

  List<String> symbols(Iterable<dynamic> list) => [
    for (final a in list) a.symbol as String,
  ];

  group('search', () {
    test('matches the name ignoring case', () {
      expect(symbols(applyCatalogQuery(assets, query: 'aPPle')), ['AAPL']);
    });

    test('matches the symbol', () {
      expect(symbols(applyCatalogQuery(assets, query: 'spy')), ['SPY']);
      expect(symbols(applyCatalogQuery(assets, query: 'btc')), ['BTC/EUR']);
    });

    test('ignores accents on both sides', () {
      expect(symbols(applyCatalogQuery(assets, query: 'societe')), ['SOC']);
      expect(symbols(applyCatalogQuery(assets, query: 'BITCÖIN')), ['BTC/EUR']);
    });

    test('empty or blank query keeps everything', () {
      expect(applyCatalogQuery(assets, query: '  ').length, assets.length);
    });

    test('no match gives an empty list', () {
      expect(applyCatalogQuery(assets, query: 'zzz'), isEmpty);
    });
  });

  test('type filter', () {
    expect(symbols(applyCatalogQuery(assets, type: InstrumentType.etf)), [
      'SPY',
    ]);
    expect(symbols(applyCatalogQuery(assets, type: InstrumentType.crypto)), [
      'BTC/EUR',
    ]);
    expect(applyCatalogQuery(assets, type: null).length, assets.length);
  });

  test('filter and search combine', () {
    expect(
      applyCatalogQuery(assets, query: 'apple', type: InstrumentType.etf),
      isEmpty,
    );
  });

  group('sort', () {
    test('change descending, unknown change last', () {
      expect(symbols(applyCatalogQuery(assets, sort: CatalogSort.changeDesc)), [
        'BTC/EUR',
        'SPY',
        'AAPL',
        'INTC',
        'SOC',
      ]);
    });

    test('change ascending, unknown change still last', () {
      expect(symbols(applyCatalogQuery(assets, sort: CatalogSort.changeAsc)), [
        'INTC',
        'AAPL',
        'SPY',
        'BTC/EUR',
        'SOC',
      ]);
    });

    test('name from A to Z', () {
      expect(symbols(applyCatalogQuery(assets, sort: CatalogSort.nameAsc)), [
        'AAPL',
        'BTC/EUR',
        'INTC',
        'SPY',
        'SOC',
      ]);
    });
  });
}
