/// What the stream is playing right now, and how many people are hearing it.
///
/// Served by the admin console at `/api/public/now-playing`, which relays
/// Streamerr server-side — the app never talks to the streaming host directly
/// for this, and never learns its address.
class NowPlaying {
  /// True only while the stream is actually up. False also covers "the console
  /// couldn't reach Streamerr", so nothing should read it as proof of silence.
  final bool onAir;

  /// Track title as the playout software reports it. Empty when unknown, and
  /// occasionally a bare filename — that is a station metadata issue, not
  /// something the app papers over.
  final String nowPlaying;

  /// Cover image URL, already filtered to https by the console. May be empty.
  final String coverArt;

  final int listeners;

  const NowPlaying({
    required this.onAir,
    required this.nowPlaying,
    required this.coverArt,
    required this.listeners,
  });

  /// Nothing to show: no endpoint configured, or nothing has arrived yet.
  static const NowPlaying nothing = NowPlaying(
    onAir: false,
    nowPlaying: '',
    coverArt: '',
    listeners: 0,
  );

  /// True when there is a track worth putting on screen.
  bool get hasTrack => nowPlaying.isNotEmpty;
}
