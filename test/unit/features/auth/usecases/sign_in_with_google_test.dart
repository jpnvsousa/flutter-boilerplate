import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_boilerplate/features/auth/domain/entities/app_user.dart';
import 'package:flutter_boilerplate/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_boilerplate/features/auth/domain/usecases/sign_in_with_google.dart';

// ── Mocks ────────────────────────────────────────────────────────────────────
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignInWithGoogle useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInWithGoogle(mockRepository);
  });

  final tUser = AppUser(
    id: 'user-123',
    email: 'test@example.com',
    fullName: 'Test User',
    plan: 'trial',
    trialEndsAt: DateTime.now().add(const Duration(days: 14)),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('SignInWithGoogle', () {
    test('should return AppUser on successful sign in', () async {
      // Arrange
      when(() => mockRepository.signInWithGoogle())
          .thenAnswer((_) async => tUser);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, equals(tUser));
      verify(() => mockRepository.signInWithGoogle()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw when repository throws', () async {
      // Arrange
      when(() => mockRepository.signInWithGoogle())
          .thenThrow(Exception('Google sign-in failed'));

      // Act & Assert
      expect(
        () => useCase.call(),
        throwsA(isA<Exception>()),
      );
    });

    test('should call repository exactly once', () async {
      // Arrange
      when(() => mockRepository.signInWithGoogle())
          .thenAnswer((_) async => tUser);

      // Act
      await useCase.call();

      // Assert
      verify(() => mockRepository.signInWithGoogle()).called(1);
    });
  });
}
