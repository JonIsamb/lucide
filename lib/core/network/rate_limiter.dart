import 'dart:collection';

/// Lets at most [maxRequests] calls through in any [window] of time.
///
/// Usage: `await limiter.acquire();` before each request. When the quota is
/// used, `acquire` simply waits until the oldest call leaves the window.
/// It is a "sliding window": we remember the time of the recent calls.
class RateLimiter {
  RateLimiter({
    this.maxRequests = 8,
    this.window = const Duration(seconds: 60),
    DateTime Function()? now,
    Future<void> Function(Duration)? wait,
  }) : _now = now ?? DateTime.now,
       _wait = wait ?? Future<void>.delayed;

  final int maxRequests;
  final Duration window;

  // Injected so tests can control time instead of waiting a real minute.
  final DateTime Function() _now;
  final Future<void> Function(Duration) _wait;

  /// Times of the calls still inside the window, oldest first.
  final Queue<DateTime> _recentCalls = Queue();

  /// Callers queue up one after the other, so two calls made at the same
  /// time cannot both take the last free slot.
  Future<void> _queue = Future.value();

  Future<void> acquire() {
    final turn = _queue.then((_) => _waitForFreeSlot());
    _queue = turn;
    return turn;
  }

  Future<void> _waitForFreeSlot() async {
    while (true) {
      final now = _now();
      // Forget the calls that are now older than the window.
      while (_recentCalls.isNotEmpty &&
          now.difference(_recentCalls.first) >= window) {
        _recentCalls.removeFirst();
      }
      if (_recentCalls.length < maxRequests) {
        _recentCalls.addLast(now);
        return;
      }
      // Sleep until the oldest call leaves the window, then check again.
      await _wait(window - now.difference(_recentCalls.first));
    }
  }
}
