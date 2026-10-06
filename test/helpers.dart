import 'package:lucide/core/network/api_exception.dart';
import 'package:lucide/core/network/market_data_api.dart';
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

/// Fake API: serves prepared series and remembers every call.
class FakeApi implements MarketDataApi {
  final Map<String, List<WeeklyCandle>> series = {};
  final Map<String, String?> logos = {};
  final Map<String, ApiException> errors = {};

  /// (symbol, startDate) of each /time_series call.
  final List<(String, DateTime?)> seriesCalls = [];
  final List<String> logoCalls = [];

  @override
  Future<List<WeeklyCandle>> fetchWeeklySeries(
    String symbol, {
    String? exchange,
    DateTime? startDate,
  }) async {
    seriesCalls.add((symbol, startDate));
    if (errors[symbol] case final error?) throw error;
    final all = series[symbol] ?? const [];
    if (startDate == null) return all;
    return all.where((c) => !c.date.isBefore(startDate)).toList();
  }

  @override
  Future<String?> fetchLogoUrl(String symbol, {String? exchange}) async {
    logoCalls.add(symbol);
    if (errors[symbol] case final error?) throw error;
    return logos[symbol];
  }
}
