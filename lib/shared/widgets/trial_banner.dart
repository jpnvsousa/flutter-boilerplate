import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/subscription/subscription_service.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/extensions/context_extensions.dart';
import '../../features/auth/domain/entities/app_user.dart';

/// Shows a top banner with trial countdown.
/// Visible only when the user is in an active trial.
/// Tapping navigates to the subscription page.
class TrialBanner extends StatelessWidget {
  const TrialBanner({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    if (!user.isTrialActive) return const SizedBox.shrink();

    final days = user.daysLeftInTrial;
    final isUrgent = days <= 3;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.subscription),
      child: AnimatedContainer(
        duration: AppTokens.durationBase,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spacing16,
          vertical: AppTokens.spacing10,
        ),
        color: isUrgent ? AppTokens.warning : AppTokens.primary,
        child: Row(
          children: [
            Icon(
              isUrgent ? Icons.timer_outlined : Icons.star_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: AppTokens.spacing8),
            Expanded(
              child: Text(
                days == 0
                    ? 'Your trial expires today!'
                    : '$days ${days == 1 ? 'day' : 'days'} left in your trial',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppTokens.fontSizeSm,
                  fontWeight: AppTokens.fontWeightSemiBold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.spacing10,
                vertical: AppTokens.spacing4,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppTokens.radiusFull),
              ),
              child: const Text(
                'Upgrade',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppTokens.fontSizeXs,
                  fontWeight: AppTokens.fontWeightBold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
