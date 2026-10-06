import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/core/network/rate_limiter.dart';

void main() {
  test('the 9th call within a minute waits for the window to free up', () {
    // FakeAsync lets us move time forward instantly.
    fakeAsync((fake) {
      final start = DateTime(2026, 10, 6, 12);
      final limiter = RateLimiter(now: () => start.add(fake.elapsed));

      var done = 0;
      for (var i = 0; i < 9; i++) {
        limiter.acquire().then((_) => done++);
      }

      fake.flushMicrotasks();
      expect(done, 8, reason: '8 calls go through at once');

      fake.elapse(const Duration(seconds: 59));
      expect(done, 8, reason: 'the 9th is still waiting after 59 s');

      fake.elapse(const Duration(seconds: 1));
      expect(done, 9, reason: 'the 9th goes through after 60 s');
    });
  });

  test('calls spread over time are never blocked', () {
    fakeAsync((fake) {
      final start = DateTime(2026, 10, 6, 12);
      final limiter = RateLimiter(now: () => start.add(fake.elapsed));

      var done = 0;
      for (var i = 0; i < 20; i++) {
        limiter.acquire().then((_) => done++);
        fake.elapse(const Duration(seconds: 8));
      }
      expect(done, 20);
    });
  });
}
