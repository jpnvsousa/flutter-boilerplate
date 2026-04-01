import 'package:injectable/injectable.dart';

import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Use case: Sign in with Google OAuth.
///
/// Single Responsibility: Only handles the Google sign-in flow.
/// All error handling bubbles up to the presentation layer.
@injectable
class SignInWithGoogle {
  const SignInWithGoogle(this._repository);

  final AuthRepository _repository;

  Future<AppUser> call() => _repository.signInWithGoogle();
}
