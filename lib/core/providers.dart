// App-wide objects, created once and shared through Riverpod.
// Tests replace them with fakes using ProviderScope(overrides: [...]).

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/app_database.dart';
import 'network/rate_limiter.dart';
import 'network/twelve_data_client.dart';

/// Given at build time: `--dart-define=TWELVE_DATA_API_KEY=...`.
/// Empty when missing; the client then reports an invalid-key error.
const twelveDataApiKey = String.fromEnvironment('TWELVE_DATA_API_KEY');

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
