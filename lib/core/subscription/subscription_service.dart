import '../../features/auth/domain/entities/app_user.dart';
import 'plan_limits.dart';

/// Extension methods on [AppUser] for subscription and trial logic.
///
/// This is the single source of truth for access checks.
/// Use [hasAccess] before gating any feature.
extension SubscriptionX on AppUser {
  // ── Trial ────────────────────────────────────────────────────────────────

  bool get isTrialActive =>
      plan == 'trial' &&
      trialEndsAt != null &&
      trialEndsAt!.isAfter(DateTime.now());

  bool get isTrialExpired =>
      plan == 'trial' &&
      (trialEndsAt == null || trialEndsAt!.isBefore(DateTime.now()));

  int get daysLeftInTrial {
    if (trialEndsAt == null) return 0;
    return trialEndsAt!.difference(DateTime.now()).inDays.clamp(0, 14);
  }

  // ── Subscription ─────────────────────────────────────────────────────────

  bool get isSubscribed => plan == 'pro';

  bool get isFree => plan == 'free';

  /// True if user has any active access (trial OR paid).
  bool get hasAccess => isTrialActive || isSubscribed;

  // ── Plan Display ─────────────────────────────────────────────────────────

  String get planDisplayName {
    switch (plan) {
      case 'trial':
        return isTrialActive ? 'Trial ($daysLeftInTrial days left)' : 'Trial (expired)';
      case 'pro':
        return 'Pro';
      case 'free':
      default:
        return 'Free';
    }
  }

  String get planBadgeLabel {
    if (isSubscribed) return 'PRO';
    if (isTrialActive) return 'TRIAL';
    return 'FREE';
  }

  // ── Usage Limit Checks ────────────────────────────────────────────────────

  bool canCreate(String resource, int currentCount) =>
      PlanLimits.canCreate(
        plan: plan,
        resource: resource,
        currentCount: currentCount,
      );

  int limitFor(String resource) => PlanLimits.getLimit(plan, resource);
}

/// Result of a usage limit check.
class UsageLimitResult {
  const UsageLimitResult({
    required this.allowed,
    required this.current,
    required this.limit,
    required this.resource,
  });

  final bool allowed;
  final int current;
  final int limit;
  final String resource;

  bool get isUnlimited => limit == -1;
  bool get isBlocked => limit == 0;

  String get description {
    if (isUnlimited) return 'Unlimited $resource';
    if (isBlocked) return '$resource not available on your plan';
    return '$current / $limit $resource used';
  }
}
