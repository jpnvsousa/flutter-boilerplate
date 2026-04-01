import 'package:injectable/injectable.dart';

import '../repositories/auth_repository.dart';

/// Use case: Sign out the currently authenticated user.
@injectable
class SignOut {
  const SignOut(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.signOut();
}
