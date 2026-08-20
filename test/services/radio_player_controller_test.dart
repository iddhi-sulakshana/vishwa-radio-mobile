import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vishwa_radio/models/site_settings.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vishwa_radio/services/audio_focus.dart';
import 'package:vishwa_radio/services/radio_player_controller.dart';

/// Stands in for just_audio so the tune-in path can be driven without a
/// network or a platform channel.
class _FakePlayer implements RadioAudioPlayer {
  final calls = <String>[];

  @override
  ProcessingState processingState = ProcessingState.idle;

  /// When set, [setUrl] hangs until it is completed, so a test can interleave
  /// something with a tune-in that is still in flight.
  Completer<void>? loadGate;

  @override
  Future<void> setUrl(String url) async {
    calls.add('setUrl:$url');
    await loadGate?.future;
  }

  @override
  Future<void> play() async => calls.add('play');

  @override
  Future<void> pause() async => calls.add('pause');
}

void main() {
  group('resolveStreamUrl', () {
    test('uses the configured url when present', () {
      expect(
        resolveStreamUrl('https://example.com/live'),
        'https://example.com/live',
      );
    });

    test('falls back to the correct default when empty', () {
      expect(
        resolveStreamUrl(''),
        kDefaultLivestreamUrl,
      );
    });
  });

  group('toggle', () {
    late _FakePlayer player;
    late RadioPlayerController controller;

    setUp(() {
      player = _FakePlayer();
      controller = RadioPlayerController.forTesting(player);
      addTearDown(controller.dispose);
    });

    test('tuning in loads and plays the stream', () async {
      await controller.toggle();

      expect(controller.isPlaying, isTrue);
      expect(player.calls.last, 'play');
    });

    test('toggling again pauses', () async {
      await controller.toggle();
      await controller.toggle();

      expect(controller.isPlaying, isFalse);
      expect(player.calls.last, 'pause');
    });

    test('starting the stream pauses whatever else holds audio focus',
        () async {
      var otherPaused = false;
      final other = Object();
      AudioFocus.instance.register(other, () async => otherPaused = true);
      addTearDown(() => AudioFocus.instance.unregister(other));

      await controller.toggle();

      expect(otherPaused, isTrue);
    });

    // The two below are a podcast episode taking over while the live stream
    // is still opening. The stream must not come back and start playing on
    // top of it — that is the one bug that makes the app audibly broken.
    test('a pause during the focus handover stops the tune-in', () async {
      final pending = controller.toggle();

      await controller.pause();
      await pending;

      expect(controller.isPlaying, isFalse);
      expect(player.calls, isNot(contains('play')));
    });

    test('a pause mid-load stops the stream starting behind it', () async {
      player.loadGate = Completer<void>();
      final pending = controller.toggle();
      await pumpEventQueue();

      await controller.pause();
      player.loadGate!.complete();
      await pending;

      expect(controller.isPlaying, isFalse);
      expect(player.calls, isNot(contains('play')));
    });

    test('another player claiming focus stops a tune-in already in flight',
        () async {
      player.loadGate = Completer<void>();
      final pending = controller.toggle();
      await pumpEventQueue();

      // Exactly what PodcastPlayerController does when an episode starts.
      await AudioFocus.instance.claim(Object());
      player.loadGate!.complete();
      await pending;

      expect(controller.isPlaying, isFalse);
      expect(player.calls, isNot(contains('play')));
    });
  });
}
