import '../entities/app_user.dart';

/// Contract for authentication operations.
/// Implemented by [AuthRepositoryImpl] in the data layer.
abstract interface class AuthRepository {
  /// Stream of the current user. Emits null when logged out.
  Stream<AppUser?> get authStateChanges;

  /// Returns the currently signed-in user, or null.
  Future<AppUser?> getCurrentUser();

  /// Sign in with Google OAuth.
  Future<AppUser> signInWithGoogle();

  /// Sign in with Apple (required for iOS App Store).
  Future<AppUser> signInWithApple();

  /// Send a magic link email. User taps link to sign in.
  Future<void> sendMagicLink(String email);

  /// Sign out the current user.
  Future<void> signOut();

  /// Update the user's FCM token for push notifications.
  Future<void> updateFcmToken(String userId, String token);

  /// Refresh the local profile from Supabase.
  Future<AppUser?> refreshProfile(String userId);
}
