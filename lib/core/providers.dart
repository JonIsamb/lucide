// App-wide objects, created once and shared through Riverpod.
// Tests replace them with fakes using ProviderScope(overrides: [...]).

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/app_database.dart';
import 'network/alpha_vantage_client.dart';
import 'network/market_data_api.dart';
import 'network/market_data_router.dart';
import 'network/rate_limiter.dart';
import 'network/twelve_data_client.dart';

/// Given at build time: `--dart-define=TWELVE_DATA_API_KEY=...`.
/// Empty when missing; the client then reports an invalid-key error.
const twelveDataApiKey = String.fromEnvironment('TWELVE_DATA_API_KEY');

/// Same, `ALPHA_VANTAGE_API_KEY` (Euronext Paris assets only).
const alphaVantageApiKey = String.fromEnvironment('ALPHA_VANTAGE_API_KEY');

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

/// One limiter for the whole app: every screen shares the same quota.
///
/// 61 s instead of 60 s gives a small safety margin, because Twelve Data
/// counts on its own clock and requests take time to arrive.
final rateLimiterProvider = Provider<RateLimiter>(
  (ref) => RateLimiter(maxRequests: 8, window: const Duration(seconds: 61)),
);

final twelveDataClientProvider = Provider<TwelveDataClient>(
  (ref) => TwelveDataClient(
    apiKey: twelveDataApiKey,
    rateLimiter: ref.watch(rateLimiterProvider),
  ),
);

/// Alpha Vantage does not publish its free limits on its documentation
/// page; other sources give about 5 requests per minute and 25 per day.
/// 5 per 61 s stays under the first; the catalogue's few Paris assets,
/// refreshed at most every 6 hours, stay far under the second.
final alphaVantageClientProvider = Provider<AlphaVantageClient>(
  (ref) => AlphaVantageClient(
    apiKey: alphaVantageApiKey,
    rateLimiter: RateLimiter(
      maxRequests: 5,
      window: const Duration(seconds: 61),
    ),
  ),
);

/// The prices of every asset: Twelve Data, except Euronext Paris.
final marketDataApiProvider = Provider<MarketDataApi>(
  (ref) => MarketDataRouter(
    defaultApi: ref.watch(twelveDataClientProvider),
    byExchange: {euronextParis: ref.watch(alphaVantageClientProvider)},
  ),
);
