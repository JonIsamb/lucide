import 'package:lucide/features/catalog/domain/asset_overview.dart';
import 'package:lucide/features/catalog/domain/instrument.dart';
import 'package:lucide/features/catalog/domain/weekly_candle.dart';

/// A candle where only the date and the close matter.
WeeklyCandle candle(DateTime date, double close) => WeeklyCandle(
  date: date,
  open: close,
  high: close,
  low: close,
  close: close,
);

/// [closes.length] weekly candles starting on Monday 6 October 2025.
List<WeeklyCandle> weeklySeries(List<double> closes) => [
  for (var i = 0; i < closes.length; i++)
    candle(DateTime.utc(2025, 10, 6 + 7 * i), closes[i]),
];

Instrument instrument(
  String symbol, {
  String? name,
  InstrumentType type = InstrumentType.stock,
}) => Instrument(
  symbol: symbol,
  name: name ?? symbol,
  type: type,
  currency: type == InstrumentType.crypto ? 'EUR' : 'USD',
  peaEligible: false,
  description: '',
);

AssetOverview overview(
  String symbol, {
  String? name,
  InstrumentType type = InstrumentType.stock,
  double? change,
}) => AssetOverview(
  instrument: instrument(symbol, name: name, type: type),
  isFavorite: false,
  yearlyChange: change,
);
