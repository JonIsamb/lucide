import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/features/catalog/domain/instrument.dart';
import 'package:lucide/features/game/domain/window_regime.dart';

List<double> flat(double value, int weeks) => List.filled(weeks, value);

void main() {
  group('analyzeWindow', () {
    test('too short a series or a price of 0: null', () {
      expect(analyzeWindow(const [], InstrumentType.stock), isNull);
      expect(analyzeWindow(const [100], InstrumentType.stock), isNull);
      expect(analyzeWindow(const [100, 101], InstrumentType.stock), isNull);
      expect(analyzeWindow(const [0, 100, 101], InstrumentType.stock), isNull);
    });

    test('a constant series is calm and flat', () {
      final analysis = analyzeWindow(flat(100, 30), InstrumentType.stock)!;
      expect(analysis.regime, MarketRegime.calm);
      expect(analysis.trend, WindowTrend.flat);
      expect(analysis.drawdownPercent, 0);
      expect(analysis.volatilityPercent, 0);
      expect(analysis.weeks, 30);
    });

    test('a slow, steady rise is calm and up', () {
      final closes = [for (var i = 0; i < 30; i++) 100 + i * 0.3];
      final analysis = analyzeWindow(closes, InstrumentType.etf)!;
      expect(analysis.regime, MarketRegime.calm);
      expect(analysis.trend, WindowTrend.up);
      expect(analysis.changePercent, closeTo(8.7, 1e-9));
    });

    test('a fall of 20 % is a crisis, 19.9 % only lively', () {
      List<double> fall(double percent) => [
        ...flat(100, 10),
        100 * (1 - percent / 100),
        ...flat(100 * (1 - percent / 100), 19),
      ];
      expect(
        analyzeWindow(fall(20), InstrumentType.stock)!.regime,
        MarketRegime.crisis,
      );
      expect(
        analyzeWindow(fall(19.9), InstrumentType.stock)!.regime,
        MarketRegime.lively,
      );
      expect(
        analyzeWindow(fall(20), InstrumentType.stock)!.trend,
        WindowTrend.down,
      );
    });

    test('a fall of 10 % is a correction: lively', () {
      final closes = [...flat(100, 10), ...flat(90, 20)];
      expect(
        analyzeWindow(closes, InstrumentType.stock)!.regime,
        MarketRegime.lively,
      );
    });

    test('a crypto needs twice the fall to be in crisis', () {
      final closes = [...flat(100, 10), ...flat(75, 20)];
      expect(
        analyzeWindow(closes, InstrumentType.stock)!.regime,
        MarketRegime.crisis,
      );
      expect(
        analyzeWindow(closes, InstrumentType.crypto)!.regime,
        MarketRegime.lively,
      );
      final deep = [...flat(100, 10), ...flat(59, 20)];
      expect(
        analyzeWindow(deep, InstrumentType.crypto)!.regime,
        MarketRegime.crisis,
      );
    });

    test('big swings without a deep fall are lively', () {
      // Alternating +8 % and -7.4 %: no fall below 10 %, volatility high.
      final closes = <double>[100];
      for (var i = 1; i < 30; i++) {
        closes.add(closes.last * (i.isOdd ? 1.08 : 1 / 1.08));
      }
      final analysis = analyzeWindow(closes, InstrumentType.stock)!;
      expect(analysis.drawdownPercent, lessThan(10));
      expect(analysis.volatilityPercent, greaterThanOrEqualTo(30));
      expect(analysis.regime, MarketRegime.lively);
    });

    test('trend limits are +5 % and -5 %', () {
      expect(
        analyzeWindow([100, 102, 105], InstrumentType.stock)!.trend,
        WindowTrend.up,
      );
      expect(
        analyzeWindow([100, 98, 96], InstrumentType.stock)!.trend,
        WindowTrend.flat,
      );
    });
  });
}
