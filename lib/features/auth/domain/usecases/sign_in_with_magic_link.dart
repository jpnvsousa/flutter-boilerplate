import 'package:injectable/injectable.dart';

import '../repositories/auth_repository.dart';

/// Use case: Send a magic link to the user's email.
/// User taps the link in their inbox to authenticate.
@injectable
class SignInWithMagicLink {
  const SignInWithMagicLink(this._repository);

  final AuthRepository _repository;

  Future<void> call(String email) => _repository.sendMagicLink(email);
}
