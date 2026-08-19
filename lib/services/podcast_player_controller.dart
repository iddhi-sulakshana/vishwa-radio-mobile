import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/podcast_episode.dart';
import 'audio_focus.dart';

/// What one episode's play control should be showing.
enum PodcastPlaybackState { idle, loading, playing }

/// The slice of just_audio's [AudioPlayer] this controller drives. It is an
/// interface so a unit test can substitute a fake: a real [AudioPlayer]
/// reaches for platform channels that a `flutter test` process cannot answer.
abstract class PodcastAudioPlayer {
  Stream<PlayerState> get playerStateStream;
  Future<void> setUrl(String url);
  Future<void> play();
  Future<void> pause();
  Future<void> dispose();
}

/// Owns the podcast [AudioPlayer] as a process-wide singleton, the same way
/// [RadioPlayerController] owns the live stream's. They are deliberately two
/// players: an episode and the live stream are separate sources that have to
/// be paused and resumed independently.
class PodcastPlayerController extends ChangeNotifier {
  PodcastPlayerController._internal(this._player) {
    AudioFocus.instance.register(this, pause);
  }

  static final PodcastPlayerController instance =
      PodcastPlayerController._internal(_JustAudioPodcastPlayer());

  /// Only for tests — the real app always uses [instance].
  @visibleForTesting
  factory PodcastPlayerController.forTesting(PodcastAudioPlayer player) {
    return PodcastPlayerController._internal(player);
  }

  final PodcastAudioPlayer _player;
  StreamSubscription<PlayerState>? _stateSub;

  String? _loadedUrl;
  bool _isPlaying = false;
  bool _isLoading = false;

  /// Taps outrun loads on a slow connection, so every load carries a token
  /// and a superseded one stops touching the state.
  int _loadToken = 0;

  /// The audio URL currently loaded into the player, if any.
  String? get loadedUrl => _loadedUrl;

  /// Everything one episode's card needs to draw its control.
  PodcastPlaybackState stateFor(String audioUrl) {
    if (audioUrl.isEmpty || audioUrl != _loadedUrl) {
      return PodcastPlaybackState.idle;
    }
    if (_isLoading) return PodcastPlaybackState.loading;
    return _isPlaying
        ? PodcastPlaybackState.playing
        : PodcastPlaybackState.idle;
  }

  Future<void> toggle(PodcastEpisode episode) async {
    final url = episode.audioUrl;
    // An episode with no audio has no control in the UI either, so this is
    // only reachable if the admin blanks a URL mid-session.
    if (url.isEmpty) return;

    if (url != _loadedUrl) {
      await _playFromStart(url);
      return;
    }
    // The load already in flight will start it; a second tap would race it.
    if (_isLoading) return;
    if (_isPlaying) {
      await pause();
      return;
    }
    await _resume();
  }

  /// Stops playback but keeps the episode loaded, so the next tap resumes
  /// where it left off. Also what [AudioFocus] calls when the live radio
  /// takes over.
  Future<void> pause() async {
    if (!_isPlaying && !_isLoading) return;
    // Invalidates a load still in flight so it cannot start playing after
    // the user — or the live radio — has stopped us.
    _loadToken++;
    _isPlaying = false;
    _isLoading = false;
    notifyListeners();
    try {
      await _player.pause();
    } catch (_) {
      // Nothing left to do: the UI already reads as paused.
    }
  }

  Future<void> _playFromStart(String url) async {
    final token = ++_loadToken;
    _loadedUrl = url;
    _isLoading = true;
    _isPlaying = false;
    notifyListeners();

    // Two streams over each other is a real bug: taking focus pauses the
    // live radio. Claimed only after the state above is set, so that a pause
    // arriving during the handover invalidates this load rather than
    // finding nothing to stop.
    await AudioFocus.instance.claim(this);
    if (token != _loadToken) return;

    // Subscribing here rather than in the constructor keeps the real player
    // unbuilt until the first tap (see [_JustAudioPodcastPlayer]).
    _stateSub ??= _player.playerStateStream.listen(_onPlayerState);

    try {
      await _player.setUrl(url);
      if (token != _loadToken) return;
      _isLoading = false;
      _isPlaying = true;
      notifyListeners();
      await _player.play();
    } catch (_) {
      // A dead URL must not throw out of a tap, and must leave the card on a
      // play icon rather than spinning forever.
      if (token == _loadToken) _stopped();
    }
  }

  Future<void> _resume() async {
    final token = ++_loadToken;
    _isPlaying = true;
    notifyListeners();

    // Marked as playing before the handover for the same reason as
    // [_playFromStart]: a pause arriving mid-claim has to find something to
    // stop, and has to invalidate this resume rather than let it start
    // behind the player that just took over.
    await AudioFocus.instance.claim(this);
    if (token != _loadToken) return;

    try {
      await _player.play();
    } catch (_) {
      if (token == _loadToken) _stopped();
    }
  }

  void _onPlayerState(PlayerState state) {
    // Before the player is ready, [_playFromStart] owns the state; an idle
    // report during that window is not news.
    if (_loadedUrl == null || state.processingState == ProcessingState.idle) {
      return;
    }

    // An episode that ends on its own returns the card to a play icon, and
    // clearing the URL means the next tap starts it over.
    if (state.processingState == ProcessingState.completed) {
      _stopped();
      return;
    }

    final buffering = state.processingState == ProcessingState.loading ||
        state.processingState == ProcessingState.buffering;
    if (buffering != _isLoading) {
      _isLoading = buffering;
      notifyListeners();
    }
  }

  void _stopped() {
    _loadedUrl = null;
    _isLoading = false;
    _isPlaying = false;
    notifyListeners();
  }

  @override
  void dispose() {
    AudioFocus.instance.unregister(this);
    _stateSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}

/// The real, just_audio-backed player. It builds its [AudioPlayer] on first
/// playback rather than on construction, so that merely opening the Podcasts
/// page never reaches for a platform channel.
class _JustAudioPodcastPlayer implements PodcastAudioPlayer {
  AudioPlayer? _player;

  AudioPlayer get _active => _player ??= AudioPlayer();

  @override
  Stream<PlayerState> get playerStateStream => _active.playerStateStream;

  @override
  Future<void> setUrl(String url) => _active.setUrl(url);

  @override
  Future<void> play() => _active.play();

  @override
  Future<void> pause() => _active.pause();

  @override
  Future<void> dispose() async {
    await _player?.dispose();
  }
}
