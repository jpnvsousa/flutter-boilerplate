import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/subscription/plan_limits.dart';
import '../../core/subscription/subscription_service.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/extensions/context_extensions.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

/// Feature gate widget.
///
/// Usage:
/// ```dart
/// PaywallGate(
///   resource: 'items',
///   currentCount: myItems.length,
///   child: CreateItemButton(),
/// )
/// ```
///
/// - If user has access → shows [child]
/// - If limit reached → shows upgrade prompt with CTA
class PaywallGate extends ConsumerWidget {
  const PaywallGate({
    super.key,
    required this.resource,
    required this.currentCount,
    required this.child,
    this.lockedMessage,
  });

  final String resource;
  final int currentCount;
  final Widget child;
  final String? lockedMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => child,
      error: (_, __) => child,
      data: (user) {
        if (user == null) return child;

        final canCreate = user.canCreate(resource, currentCount);
        if (canCreate) return child;

        return _UpgradePrompt(
          resource: resource,
          limit: user.limitFor(resource),
          message: lockedMessage,
        );
      },
    );
  }
}

/// Inline upgrade prompt shown when a limit is hit.
class _UpgradePrompt extends StatelessWidget {
  const _UpgradePrompt({
    required this.resource,
    required this.limit,
    this.message,
  });

  final String resource;
  final int limit;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppTokens.spacing16),
      padding: const EdgeInsets.all(AppTokens.spacing20),
      decoration: BoxDecoration(
        color: AppTokens.primary.withOpacity(0.05),
        border: Border.all(color: AppTokens.primary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(AppTokens.radiusL),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: AppTokens.primary,
            size: 40,
          ),
          const SizedBox(height: AppTokens.spacing12),
          Text(
            message ?? 'Upgrade to unlock more',
            style: context.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTokens.spacing8),
          Text(
            limit > 0
                ? 'You\'ve reached the $limit $resource limit on the free plan.'
                : 'This feature is not available on the free plan.',
            style: context.textTheme.bodySmall?.copyWith(
              color: AppTokens.grey500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTokens.spacing16),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.subscription),
            icon: const Icon(Icons.star_outline_rounded, size: 18),
            label: const Text('View Pro plans'),
          ),
        ],
      ),
    );
  }
}
