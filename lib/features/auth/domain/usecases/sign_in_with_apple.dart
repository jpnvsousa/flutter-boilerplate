import 'package:injectable/injectable.dart';

import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Use case: Sign in with Apple.
/// Required by Apple App Store guidelines for apps with social login.
@injectable
class SignInWithApple {
  const SignInWithApple(this._repository);

  final AuthRepository _repository;

  Future<AppUser> call() => _repository.signInWithApple();
}
