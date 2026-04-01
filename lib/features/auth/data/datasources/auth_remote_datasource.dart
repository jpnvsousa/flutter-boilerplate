import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile_model.dart';

/// Remote data source for authentication operations via Supabase Auth.
@injectable
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._supabase);

  final SupabaseClient _supabase;

  // ── Auth State ────────────────────────────────────────────────────────────

  Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;

  Session? get currentSession => _supabase.auth.currentSession;

  // ── Google Sign-In ────────────────────────────────────────────────────────

  Future<ProfileModel> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null || accessToken == null) {
      throw Exception('Missing Google auth tokens');
    }

    await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    return _fetchCurrentProfile();
  }

  // ── Apple Sign-In ─────────────────────────────────────────────────────────

  Future<ProfileModel> signInWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: credential.identityToken!,
    );

    return _fetchCurrentProfile();
  }

  // ── Magic Link ────────────────────────────────────────────────────────────

  Future<void> sendMagicLink(String email) async {
    await _supabase.auth.signInWithOtp(
      email: email,
      emailRedirectTo: 'io.supabase.flutter://login-callback',
    );
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  Future<void> signOut() => _supabase.auth.signOut();

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<ProfileModel> fetchProfile(String userId) async {
    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return ProfileModel.fromJson(data);
  }

  Future<void> updateFcmToken(String userId, String token) async {
    await _supabase
        .from('profiles')
        .update({'fcm_token': token})
        .eq('id', userId);
  }

  Future<ProfileModel> _fetchCurrentProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');
    return fetchProfile(userId);
  }
}
