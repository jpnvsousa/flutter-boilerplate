/// Environment configuration loaded via --dart-define-from-file
///
/// NEVER commit real values. Use .env.local for development.
/// See .env.example for required variables.
///
/// Run with:
/// flutter run --dart-define-from-file=.env.local
abstract class Env {
  // ── Supabase ──────────────────────────────────────────────────────────────
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // ── RevenueCat ────────────────────────────────────────────────────────────
  static const revenuecatAppleKey = String.fromEnvironment(
    'RC_APPLE_KEY',
    defaultValue: '',
  );

  static const revenuecatGoogleKey = String.fromEnvironment(
    'RC_GOOGLE_KEY',
    defaultValue: '',
  );

  // ── Sentry ────────────────────────────────────────────────────────────────
  static const sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  // ── App ───────────────────────────────────────────────────────────────────
  static const environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';

  /// Validates all required env vars are set. Call on startup.
  static void validate() {
    final missing = <String>[];
    if (supabaseUrl.isEmpty) missing.add('SUPABASE_URL');
    if (supabaseAnonKey.isEmpty) missing.add('SUPABASE_ANON_KEY');
    if (revenuecatAppleKey.isEmpty) missing.add('RC_APPLE_KEY');
    if (revenuecatGoogleKey.isEmpty) missing.add('RC_GOOGLE_KEY');
    if (sentryDsn.isEmpty) missing.add('SENTRY_DSN');

    if (missing.isNotEmpty) {
      throw Exception(
        'Missing required environment variables: ${missing.join(', ')}\n'
        'Run: flutter run --dart-define-from-file=.env.local',
      );
    }
  }
}
