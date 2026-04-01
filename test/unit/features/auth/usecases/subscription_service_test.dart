import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_boilerplate/core/subscription/subscription_service.dart';
import 'package:flutter_boilerplate/features/auth/domain/entities/app_user.dart';

AppUser makeUser({
  required String plan,
  DateTime? trialEndsAt,
}) =>
    AppUser(
      id: 'user-123',
      email: 'test@example.com',
      plan: plan,
      trialEndsAt: trialEndsAt,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

void main() {
  group('SubscriptionX', () {
    // ── isTrialActive ──────────────────────────────────────────────────────
    group('isTrialActive', () {
      test('returns true when plan=trial and trialEndsAt is in the future', () {
        final user = makeUser(
          plan: 'trial',
          trialEndsAt: DateTime.now().add(const Duration(days: 5)),
        );
        expect(user.isTrialActive, isTrue);
      });

      test('returns false when plan=trial but trialEndsAt is in the past', () {
        final user = makeUser(
          plan: 'trial',
          trialEndsAt: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(user.isTrialActive, isFalse);
      });

      test('returns false when plan=pro', () {
        final user = makeUser(plan: 'pro');
        expect(user.isTrialActive, isFalse);
      });

      test('returns false when plan=free', () {
        final user = makeUser(plan: 'free');
        expect(user.isTrialActive, isFalse);
      });
    });

    // ── isSubscribed ───────────────────────────────────────────────────────
    group('isSubscribed', () {
      test('returns true when plan=pro', () {
        final user = makeUser(plan: 'pro');
        expect(user.isSubscribed, isTrue);
      });

      test('returns false when plan=trial', () {
        final user = makeUser(plan: 'trial');
        expect(user.isSubscribed, isFalse);
      });

      test('returns false when plan=free', () {
        final user = makeUser(plan: 'free');
        expect(user.isSubscribed, isFalse);
      });
    });

    // ── hasAccess ──────────────────────────────────────────────────────────
    group('hasAccess', () {
      test('returns true when trial is active', () {
        final user = makeUser(
          plan: 'trial',
          trialEndsAt: DateTime.now().add(const Duration(days: 5)),
        );
        expect(user.hasAccess, isTrue);
      });

      test('returns true when plan=pro', () {
        final user = makeUser(plan: 'pro');
        expect(user.hasAccess, isTrue);
      });

      test('returns false when trial expired and plan=trial', () {
        final user = makeUser(
          plan: 'trial',
          trialEndsAt: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(user.hasAccess, isFalse);
      });

      test('returns false when plan=free', () {
        final user = makeUser(plan: 'free');
        expect(user.hasAccess, isFalse);
      });
    });

    // ── daysLeftInTrial ────────────────────────────────────────────────────
    group('daysLeftInTrial', () {
      test('returns correct days remaining', () {
        final user = makeUser(
          plan: 'trial',
          trialEndsAt: DateTime.now().add(const Duration(days: 7)),
        );
        expect(user.daysLeftInTrial, equals(7));
      });

      test('returns 0 when trial has expired', () {
        final user = makeUser(
          plan: 'trial',
          trialEndsAt: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(user.daysLeftInTrial, equals(0));
      });

      test('returns 0 when trialEndsAt is null', () {
        final user = makeUser(plan: 'free');
        expect(user.daysLeftInTrial, equals(0));
      });

      test('clamps to maximum of 14 days', () {
        final user = makeUser(
          plan: 'trial',
          trialEndsAt: DateTime.now().add(const Duration(days: 30)),
        );
        expect(user.daysLeftInTrial, equals(14));
      });
    });
  });
}
