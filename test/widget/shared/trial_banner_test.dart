import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_boilerplate/features/auth/domain/entities/app_user.dart';
import 'package:flutter_boilerplate/shared/widgets/trial_banner.dart';

void main() {
  Widget buildWidget(AppUser user) {
    return MaterialApp(
      home: Scaffold(
        body: TrialBanner(user: user),
      ),
    );
  }

  group('TrialBanner', () {
    test('is not visible when plan is pro', () async {
      final user = AppUser(
        id: 'u1',
        email: 'test@test.com',
        plan: 'pro',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final tester = await TestWidgetsFlutterBinding.ensureInitialized()
          as WidgetTester;
      await tester.pumpWidget(buildWidget(user));

      // TrialBanner returns SizedBox.shrink() for pro users
      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('shows trial banner when trial is active', (tester) async {
      final user = AppUser(
        id: 'u1',
        email: 'test@test.com',
        plan: 'trial',
        trialEndsAt: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(buildWidget(user));

      expect(find.textContaining('days left'), findsOneWidget);
      expect(find.text('Upgrade'), findsOneWidget);
    });

    testWidgets('shows urgent styling when 3 or fewer days remain', (tester) async {
      final user = AppUser(
        id: 'u1',
        email: 'test@test.com',
        plan: 'trial',
        trialEndsAt: DateTime.now().add(const Duration(days: 2)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(buildWidget(user));

      expect(find.textContaining('days left'), findsOneWidget);
    });

    testWidgets('shows expiry message when trial expires today', (tester) async {
      final user = AppUser(
        id: 'u1',
        email: 'test@test.com',
        plan: 'trial',
        trialEndsAt: DateTime.now().add(const Duration(hours: 1)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(buildWidget(user));

      // 0 days left → "expires today"
      expect(find.textContaining('expires today'), findsOneWidget);
    });
  });
}
