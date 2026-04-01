import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_with_apple.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_in_with_magic_link.dart';
import '../../domain/usecases/sign_out.dart';

part 'auth_provider.g.dart';

// ── Auth State Stream ─────────────────────────────────────────────────────────

/// Watches Supabase auth state changes — emits null when logged out.
@riverpod
Stream<AppUser?> authState(Ref ref) {
  final repository = getIt<AuthRepository>();
  return repository.authStateChanges;
}

/// Returns the currently authenticated user profile, or null.
@riverpod
Future<AppUser?> currentUser(Ref ref) {
  final repository = getIt<AuthRepository>();
  return repository.getCurrentUser();
}

// ── Auth Notifier ─────────────────────────────────────────────────────────────

enum AuthStatus { idle, loading, success, error }

class AuthState {
  const AuthState({
    this.status = AuthStatus.idle,
    this.error,
    this.user,
  });

  final AuthStatus status;
  final String? error;
  final AppUser? user;

  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error;

  AuthState copyWith({
    AuthStatus? status,
    String? error,
    AppUser? user,
  }) =>
      AuthState(
        status: status ?? this.status,
        error: error,
        user: user ?? this.user,
      );
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() => const AuthState();

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await getIt<SignInWithGoogle>().call();
      state = state.copyWith(status: AuthStatus.success, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await getIt<SignInWithApple>().call();
      state = state.copyWith(status: AuthStatus.success, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> sendMagicLink(String email) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await getIt<SignInWithMagicLink>().call(email);
      state = state.copyWith(status: AuthStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await getIt<SignOut>().call();
      state = const AuthState(status: AuthStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  void clearError() => state = state.copyWith(status: AuthStatus.idle);
}
