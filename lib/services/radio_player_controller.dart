import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/site_settings.dart';
import 'admin_content_controller.dart';
import 'audio_focus.dart';

/// Picks the URL to stream from: whatever the admin has configured, or the
/// fallback if that's blank (matches the website's "an empty stream URL
/// must not silently break the play button" rule). The fallback is
/// [kDefaultLivestreamUrl] — the same constant [SiteSettings.defaults] uses,
/// so the two can't drift apart.
String resolveStreamUrl(String configured) =>
    configured.isNotEmpty ? configured : kDefaultLivestreamUrl;

/// The slice of just_audio's [AudioPlayer] this controller drives. It is an
/// interface so a unit test can substitute a fake, mirroring
/// [PodcastAudioPlayer].
abstract class RadioAudioPlayer {
  ProcessingState get processingState;
  Future<void> setUrl(String url);
  Future<void> play();
  Future<void> pause();
}

/// Owns the live-stream [AudioPlayer] as a process-wide singleton so
/// playback survives drawer navigation between screens (the stream keeps
/// playing while browsing the Timetable, Podcasts, etc.).
class RadioPlayerController extends ChangeNotifier {
  RadioPlayerController._internal(this._player) {
    AudioFocus.instance.register(this, pause);
  }

  static final RadioPlayerController instance =
      RadioPlayerController._internal(_JustAudioRadioPlayer());

  /// Only for tests — the real app always uses [instance].
  @visibleForTesting
  factory RadioPlayerController.forTesting(RadioAudioPlayer player) {
    return RadioPlayerController._internal(player);
  }

  final RadioAudioPlayer _player;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  /// True from the moment a tune-in starts until the stream is actually
  /// playing. Opening a live stream is a network round trip, and for that
  /// whole window there is something to stop — so [pause] has to be able to
  /// see it, or a podcast starting mid-load would fail to stop us and both
  /// would end up audible.
  bool _isStarting = false;

  /// Every tune-in carries a token that [pause] invalidates, so a load that
  /// is already in flight can never come back and start playing.
  int _startToken = 0;

  Future<void> toggle() async {
    if (_isPlaying || _isStarting) {
      await pause();
      return;
    }

    final token = ++_startToken;
    _isStarting = true;

    // Only one of the app's players may be audible: tuning in pauses any
    // podcast episode that is playing. Claimed only after the flag above is
    // set, so that a pause arriving during the handover invalidates this
    // start rather than finding nothing to stop.
    await AudioFocus.instance.claim(this);
    if (token != _startToken) return;

    try {
      if (_player.processingState == ProcessingState.idle) {
        final url = resolveStreamUrl(
          AdminContentController.instance.siteSettings.livestreamUrl,
        );
        await _player.setUrl(url);
        if (token != _startToken) return;
      }
      _isStarting = false;
      _isPlaying = true;
      notifyListeners();
      await _player.play();
    } catch (_) {
      if (token == _startToken) {
        _isStarting = false;
        _isPlaying = false;
        notifyListeners();
      }
    }
  }

  /// Stops the stream without toggling it back on — also what [AudioFocus]
  /// calls when a podcast episode takes over.
  Future<void> pause() async {
    if (!_isPlaying && !_isStarting) return;
    // Invalidates a tune-in still in flight so it cannot start playing after
    // the user — or a podcast episode — has stopped us.
    _startToken++;
    _isPlaying = false;
    _isStarting = false;
    notifyListeners();
    try {
      await _player.pause();
    } catch (_) {
      // Nothing left to do: the UI already reads as stopped.
    }
  }
}

/// The real, just_audio-backed player. It builds its [AudioPlayer] on first
/// use rather than on construction, so merely opening a screen that reads
/// [RadioPlayerController.isPlaying] never reaches for a platform channel.
class _JustAudioRadioPlayer implements RadioAudioPlayer {
  AudioPlayer? _player;

  AudioPlayer get _active => _player ??= AudioPlayer();

  @override
  ProcessingState get processingState => _active.processingState;

  @override
  Future<void> setUrl(String url) => _active.setUrl(url);

  @override
  Future<void> play() => _active.play();

  @override
  Future<void> pause() => _active.pause();
}
