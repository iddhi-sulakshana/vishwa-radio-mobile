/// Admin console base URL and shared API key.
///
/// The key is not a secret: it ships inside this binary, where anyone can
/// extract it. It is a revocation handle — rotate it in the console and old
/// callers stop working, which for the app means shipping a release. Nothing
/// is served from /api/public that is not already published on the website.
///
/// It comes from `--dart-define=ADMIN_API_KEY=...` rather than a source
/// literal. That does not make it secret — it still ends up in the binary —
/// but this repository is public, and a literal here would be committed to it.
/// An empty key means every fetch 401s and the app falls back to
/// [SiteSettings.defaults], which is the right outcome for a misconfigured
/// build: visibly stale content rather than a crash.
///
///   flutter build apk --release --dart-define=ADMIN_API_KEY=`your-key`
class AdminConfig {
  AdminConfig._();

  static const baseUrl = String.fromEnvironment(
    'ADMIN_BASE_URL',
    defaultValue: 'https://vishwa-radio.vercel.app',
  );

  static const apiKey = String.fromEnvironment('ADMIN_API_KEY');
}
