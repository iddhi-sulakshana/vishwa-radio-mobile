import 'package:flutter_test/flutter_test.dart';
import 'package:vishwa_radio/models/now_playing.dart';
import 'package:vishwa_radio/services/admin_api_service.dart';
import 'package:vishwa_radio/services/now_playing_controller.dart';

const _track = NowPlaying(
  onAir: true,
  nowPlaying: 'ABBA Fernando',
  coverArt: 'https://covers.example/a.jpg',
  listeners: 2,
);

void main() {
  // The controller registers a lifecycle observer on start(), which needs a
  // binding even in a non-widget test.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('parseNowPlaying', () {
    test('reads a well-formed payload', () {
      final now = parseNowPlaying({
        'onAir': true,
        'nowPlaying': 'ABBA Fernando',
        'coverArt': 'https://covers.example/a.jpg',
        'listeners': 2,
      });

      expect(now.onAir, isTrue);
      expect(now.nowPlaying, 'ABBA Fernando');
      expect(now.coverArt, 'https://covers.example/a.jpg');
      expect(now.listeners, 2);
      expect(now.hasTrack, isTrue);
    });

    test('does not crash on a missing or malformed payload', () {
      final now = parseNowPlaying({});

      expect(now.onAir, isFalse);
      expect(now.nowPlaying, '');
      expect(now.coverArt, '');
      expect(now.listeners, 0);
      expect(now.hasTrack, isFalse);
    });

    test('treats a truthy non-true onAir as off air', () {
      // A pulsing ON AIR badge over a dead stream is worse than none.
      expect(parseNowPlaying({'onAir': 'yes'}).onAir, isFalse);
      expect(parseNowPlaying({'onAir': 1}).onAir, isFalse);
    });

    test('never reports a negative or non-integer listener count', () {
      expect(parseNowPlaying({'listeners': -4}).listeners, 0);
      expect(parseNowPlaying({'listeners': '12'}).listeners, 0);
      expect(parseNowPlaying({'listeners': null}).listeners, 0);
    });
  });

  group('NowPlayingController', () {
    test('publishes the first successful poll and notifies listeners', () async {
      final controller =
          NowPlayingController.forTesting(fetch: () async => _track);
      addTearDown(controller.dispose);

      var notified = 0;
      controller.addListener(() => notified++);

      expect(controller.current.hasTrack, isFalse);

      controller.start();
      await Future<void>.delayed(Duration.zero);

      expect(controller.current.nowPlaying, 'ABBA Fernando');
      expect(controller.current.listeners, 2);
      expect(notified, greaterThan(0));
    });

    test('keeps the last known track when a poll fails', () async {
      var shouldFail = false;
      final controller = NowPlayingController.forTesting(fetch: () async {
        if (shouldFail) throw Exception('503 unavailable');
        return _track;
      });
      addTearDown(controller.dispose);

      controller.start();
      await Future<void>.delayed(Duration.zero);
      expect(controller.current.nowPlaying, 'ABBA Fernando');

      // A console that cannot reach Streamerr is not evidence the station is
      // off air — the card must not blank out and flap back on.
      shouldFail = true;
      await controller.testPoll();

      expect(controller.current.nowPlaying, 'ABBA Fernando');
      expect(controller.current.onAir, isTrue);
    });

    test('start() is idempotent', () async {
      var calls = 0;
      final controller = NowPlayingController.forTesting(fetch: () async {
        calls++;
        return _track;
      });
      addTearDown(controller.dispose);

      controller.start();
      controller.start();
      controller.start();
      await Future<void>.delayed(Duration.zero);

      expect(calls, 1);
    });
  });
}
