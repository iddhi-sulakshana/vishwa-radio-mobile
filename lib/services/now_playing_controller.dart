import 'dart:async';

import 'package:flutter/widgets.dart';

import '../models/now_playing.dart';
import 'admin_api_service.dart' as api;

/// Polls the console's `/api/public/now-playing` and publishes the result.
///
/// Separate from [AdminContentController] because it is the one piece of
/// admin-served content that changes while the app is open: settings, schedule
/// and podcasts are fetched once at startup, this repeats. Same failure
/// philosophy though — a failed poll keeps whatever was already there.
///
/// The console caches Streamerr for ten seconds, so polling faster than that
/// would return the same document. Polling stops entirely while the app is
/// backgrounded: a radio app is routinely left running for hours with the
/// screen off, and a timer firing through all of it would spend battery on
/// something nobody can see.
class NowPlayingController extends ChangeNotifier with WidgetsBindingObserver {
  NowPlayingController._internal({Future<NowPlaying> Function()? fetch})
      : _fetch = fetch ?? api.fetchNowPlaying;

  // TEMPORARY: the DemoContent wiring is restored in the demo-content commit.
  static final NowPlayingController instance = NowPlayingController._internal();

  /// Only for tests — the real app always uses [instance].
  @visibleForTesting
  factory NowPlayingController.forTesting({
    required Future<NowPlaying> Function() fetch,
  }) {
    return NowPlayingController._internal(fetch: fetch);
  }

  static const pollInterval = Duration(seconds: 20);

  final Future<NowPlaying> Function() _fetch;

  NowPlaying current = NowPlaying.nothing;

  Timer? _timer;
  bool _started = false;

  /// Safe to call more than once; only the first call does anything.
  void start() {
    if (_started) return;
    _started = true;

    WidgetsBinding.instance.addObserver(this);
    _resume();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh immediately on return rather than making someone stare at a
      // stale title for up to twenty seconds.
      _resume();
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _resume() {
    _timer?.cancel();
    unawaited(_poll());
    _timer = Timer.periodic(pollInterval, (_) => unawaited(_poll()));
  }

  Future<void> _poll() async {
    try {
      final next = await _fetch();
      current = next;
      notifyListeners();
    } catch (_) {
      // Deliberately silent, and deliberately non-destructive. A 503 means the
      // console can't see Streamerr; that is not the same as the station being
      // off air, and clearing `current` would flap the track on and off screen
      // as the upstream recovers.
    }
  }

  /// Runs one poll immediately. Only for tests — the real app polls on the
  /// timer set up by [start].
  @visibleForTesting
  Future<void> testPoll() => _poll();

  /// Exposed for tests; the singleton lives for the life of the process.
  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    if (_started) WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
