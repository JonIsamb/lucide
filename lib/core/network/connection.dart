import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tells whether the data providers can be reached.
abstract interface class ConnectionProbe {
  Future<bool> isOnline();
}

/// Looks the price provider's host up: no extra package, and it is the
/// host the app needs. A failure or a slow answer means offline.
class DnsConnectionProbe implements ConnectionProbe {
  const DnsConnectionProbe({
    this.host = 'api.twelvedata.com',
    this.timeout = const Duration(seconds: 3),
  });

  final String host;
  final Duration timeout;

  @override
  Future<bool> isOnline() async {
    try {
      final found = await InternetAddress.lookup(host).timeout(timeout);
      return found.isNotEmpty && found.first.rawAddress.isNotEmpty;
    } on Object {
      return false;
    }
  }
}

final connectionProbeProvider = Provider<ConnectionProbe>(
  (ref) => const DnsConnectionProbe(),
);

/// How often the connection is checked again.
const connectionCheckEvery = Duration(seconds: 15);

/// True while the phone cannot reach the providers. Starts as online (no
/// banner flash at launch) and corrects itself after the first check.
final isOfflineProvider = NotifierProvider<ConnectionController, bool>(
  ConnectionController.new,
);

class ConnectionController extends Notifier<bool> {
  @override
  bool build() {
    final timer = Timer.periodic(connectionCheckEvery, (_) => check());
    ref.onDispose(timer.cancel);
    Future.microtask(check);
    return false;
  }

  /// Asks the probe now and updates the state.
  Future<void> check() async {
    final online = await ref.read(connectionProbeProvider).isOnline();
    if (ref.mounted) state = !online;
  }
}
