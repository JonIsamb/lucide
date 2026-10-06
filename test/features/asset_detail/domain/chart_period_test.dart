import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/features/asset_detail/domain/chart_period.dart';

import '../../../helpers.dart';

void main() {
  // 300 weeks with closes 0, 1, 2... so a close tells its position.
  final history = weeklySeries([for (var i = 0; i < 300; i++) i.toDouble()]);

  test('each period keeps its last candles, oldest first', () {
    expect(candlesFor(history, ChartPeriod.oneMonth), hasLength(5));
    expect(candlesFor(history, ChartPeriod.sixMonths), hasLength(27));
    expect(candlesFor(history, ChartPeriod.oneYear), hasLength(53));

    final month = candlesFor(history, ChartPeriod.oneMonth);
    expect(month.first.close, 295);
    expect(month.last.close, 299);
  });

  test('5 years is the whole stored history', () {
    expect(candlesFor(history, ChartPeriod.fiveYears), hasLength(300));
  });

  test('a history shorter than the period is returned whole', () {
    final short = weeklySeries([1, 2, 3]);
    expect(candlesFor(short, ChartPeriod.oneYear), hasLength(3));
    expect(candlesFor(short, ChartPeriod.oneMonth), hasLength(3));
  });

  test('empty history', () {
    expect(candlesFor(const [], ChartPeriod.oneYear), isEmpty);
  });
}
