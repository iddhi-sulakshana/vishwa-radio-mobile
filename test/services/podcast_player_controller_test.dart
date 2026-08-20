import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vishwa_radio/models/podcast_episode.dart';
import 'package:vishwa_radio/services/audio_focus.dart';
import 'package:vishwa_radio/services/podcast_player_controller.dart';

/// Stands in for just_audio, which needs platform channels a `flutter test`
/// process cannot answer. Records the calls so the tests can assert that a
/// resume did not reload the episode.
class _FakePlayer implements PodcastAudioPlayer {
  final _states = StreamController<PlayerState>.broadcast();
  final calls = <String>[];
  bool failOnSetUrl = false;

  /// When set, [setUrl] hangs until it is completed, so a test can interleave
  /// something with a load that is still in flight.
  Completer<void>? loadGate;

  @override
  Stream<PlayerState> get playerStateStream => _states.stream;

  @override
  Future<void> setUrl(String url) async {
    calls.add('setUrl:$url');
    await loadGate?.future;
    if (failOnSetUrl) throw Exception('dead url');
  }

  @override
  Future<void> play() async => calls.add('play');

  @override
  Future<void> pause() async => calls.add('pause');

  @override
  Future<void> dispose() async => _states.close();

  void emit(ProcessingState state, {bool playing = true}) =>
      _states.add(PlayerState(playing, state));
}

PodcastEpisode _episode(String audioUrl) => PodcastEpisode(
      title: 'Ep',
      description: '',
      audioUrl: audioUrl,
      imageUrl: '',
    );

void main() {
  final epA = _episode('https://halo.streamerr.co/a.mp3');
  final epB = _episode('https://halo.streamerr.co/b.mp3');

  late _FakePlayer player;
  late PodcastPlayerController controller;

  setUp(() {
    player = _FakePlayer();
    controller = PodcastPlayerController.forTesting(player);
    addTearDown(controller.dispose);
  });

  test('toggling an episode loads and plays it', () async {
    await controller.toggle(epA);

    expect(controller.stateFor(epA.audioUrl), PodcastPlaybackState.playing);
    expect(player.calls, ['setUrl:${epA.audioUrl}', 'play']);
  });

  test('toggling the same episode again pauses it', () async {
    await controller.toggle(epA);
    await controller.toggle(epA);

    expect(controller.stateFor(epA.audioUrl), PodcastPlaybackState.idle);
    expect(player.calls.last, 'pause');
  });

  test('toggling a paused episode resumes it without reloading', () async {
    await controller.toggle(epA);
    await controller.toggle(epA);
    await controller.toggle(epA);

    expect(controller.stateFor(epA.audioUrl), PodcastPlaybackState.playing);
    expect(player.calls.where((c) => c.startsWith('setUrl')), hasLength(1));
  });

  test('toggling a different episode switches to it', () async {
    await controller.toggle(epA);
    await controller.toggle(epB);

    expect(controller.stateFor(epB.audioUrl), PodcastPlaybackState.playing);
    expect(controller.stateFor(epA.audioUrl), PodcastPlaybackState.idle);
    expect(player.calls.last, 'play');
    expect(controller.loadedUrl, epB.audioUrl);
  });

  test('an episode with an empty audio url is a no-op', () async {
    await controller.toggle(_episode(''));

    expect(controller.stateFor(''), PodcastPlaybackState.idle);
    expect(controller.loadedUrl, isNull);
    expect(player.calls, isEmpty);
  });

  test('a url that fails to load lands on idle, not a stuck spinner',
      () async {
    player.failOnSetUrl = true;

    await controller.toggle(epA);

    expect(controller.stateFor(epA.audioUrl), PodcastPlaybackState.idle);
  });

  test('buffering mid-episode shows the loading state', () async {
    await controller.toggle(epA);

    player.emit(ProcessingState.buffering);
    await pumpEventQueue();

    expect(controller.stateFor(epA.audioUrl), PodcastPlaybackState.loading);
  });

  test('an episode that ends on its own returns to idle', () async {
    await controller.toggle(epA);

    player.emit(ProcessingState.completed, playing: false);
    await pumpEventQueue();

    expect(controller.stateFor(epA.audioUrl), PodcastPlaybackState.idle);
    expect(controller.loadedUrl, isNull);
  });

  test('starting an episode pauses whatever else holds audio focus', () async {
    var otherPaused = false;
    final other = Object();
    AudioFocus.instance.register(other, () async => otherPaused = true);
    addTearDown(() => AudioFocus.instance.unregister(other));

    await controller.toggle(epA);

    expect(otherPaused, isTrue);
  });

  // Both tests below are the live radio taking over while an episode is
  // still opening — the load must not come back and start playing over it.
  test('a pause during the focus handover stops the load', () async {
    final pending = controller.toggle(epA);

    await controller.pause();
    await pending;

    expect(controller.stateFor(epA.audioUrl), PodcastPlaybackState.idle);
    expect(player.calls, isNot(contains('play')));
  });

  test('a pause mid-load stops the episode starting behind it', () async {
    player.loadGate = Completer<void>();
    final pending = controller.toggle(epA);
    await pumpEventQueue();

    await controller.pause();
    player.loadGate!.complete();
    await pending;

    expect(controller.stateFor(epA.audioUrl), PodcastPlaybackState.idle);
    expect(player.calls, isNot(contains('play')));
  });

  test('another player claiming focus pauses the episode', () async {
    await controller.toggle(epA);

    await AudioFocus.instance.claim(Object());

    expect(controller.stateFor(epA.audioUrl), PodcastPlaybackState.idle);
    expect(player.calls.last, 'pause');
  });

  // Resuming a paused episode goes through the same focus handover as a
  // fresh load, and has to survive it the same way.
  test('a claim during a resume handover stops the episode', () async {
    await controller.toggle(epA);
    await controller.pause();

    final pending = controller.toggle(epA);
    await AudioFocus.instance.claim(Object());
    await pending;

    expect(controller.stateFor(epA.audioUrl), PodcastPlaybackState.idle);
    expect(player.calls.where((c) => c == 'play'), hasLength(1));
  });
}
