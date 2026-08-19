/// A one-slot audio focus shared by the app's players: the live radio and the
/// podcast player each own their own `AudioPlayer`, and only one of them may
/// be audible at a time.
///
/// The two controllers coordinate through this registry rather than calling
/// each other directly, so neither has to import the other — a mutual import
/// would drag each controller's just_audio player into the other's tests, and
/// would split the "starting one pauses the other" rule across two files.
class AudioFocus {
  AudioFocus._internal();

  static final AudioFocus instance = AudioFocus._internal();

  final Map<Object, Future<void> Function()> _pausers = {};

  /// Controllers register from their constructor. That is early enough: a
  /// player can only be audible once its controller exists, so anything not
  /// yet registered is by definition already silent.
  void register(Object owner, Future<void> Function() pause) {
    _pausers[owner] = pause;
  }

  void unregister(Object owner) {
    _pausers.remove(owner);
  }

  /// Pauses every registered player except [owner], which is about to start.
  Future<void> claim(Object owner) async {
    for (final entry in _pausers.entries.toList()) {
      if (entry.key == owner) continue;
      try {
        await entry.value();
      } catch (_) {
        // One player failing to pause must not stop the other from starting.
      }
    }
  }
}
