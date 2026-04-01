import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Concrete implementation of [AuthRepository].
/// Bridges the domain layer with Supabase auth.
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);

  final AuthRemoteDataSource _dataSource;

  @override
  Stream<AppUser?> get authStateChanges =>
      _dataSource.authStateChanges.map((event) {
        final session = event.session;
        if (session == null) return null;
        // Profile will be fetched separately — here we emit basic user
        return AppUser(
          id: session.user.id,
          email: session.user.email ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });

  @override
  Future<AppUser?> getCurrentUser() async {
    final session = _dataSource.currentSession;
    if (session == null) return null;

    try {
      final profile = await _dataSource.fetchProfile(session.user.id);
      return profile.toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    final model = await _dataSource.signInWithGoogle();
    return model.toEntity();
  }

  @override
  Future<AppUser> signInWithApple() async {
    final model = await _dataSource.signInWithApple();
    return model.toEntity();
  }

  @override
  Future<void> sendMagicLink(String email) =>
      _dataSource.sendMagicLink(email);

  @override
  Future<void> signOut() => _dataSource.signOut();

  @override
  Future<void> updateFcmToken(String userId, String token) =>
      _dataSource.updateFcmToken(userId, token);

  @override
  Future<AppUser?> refreshProfile(String userId) async {
    try {
      final model = await _dataSource.fetchProfile(userId);
      return model.toEntity();
    } catch (_) {
      return null;
    }
  }
}
