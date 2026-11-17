import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/core/network/connection.dart';

class _Probe implements ConnectionProbe {
  bool online = true;

  @override
  Future<bool> isOnline() async => online;
}

void main() {
  test('offline is detected, then the return of the network', () async {
    final probe = _Probe()..online = false;
    final container = ProviderContainer(
      overrides: [connectionProbeProvider.overrideWithValue(probe)],
    );
    addTearDown(container.dispose);
    final controller = container.read(isOfflineProvider.notifier);

    expect(container.read(isOfflineProvider), isFalse, reason: 'no flash');
    await controller.check();
    expect(container.read(isOfflineProvider), isTrue);

    probe.online = true;
    await controller.check();
    expect(container.read(isOfflineProvider), isFalse);
  });
}
