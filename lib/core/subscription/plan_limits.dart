/// Defines feature limits for each subscription plan.
///
/// -1 = unlimited
/// 0  = blocked
/// N  = max N items allowed
///
/// Edit the limits map below to match your product.
abstract class PlanLimits {
  static const Map<String, Map<String, int>> limits = {
    'free': {
      // ── Customize your product's limits below ─────────────────────────
      'items': 3,
      'projects': 1,
      'storage_mb': 50,
      'team_members': 0,
      'exports': 0,
    },
    'trial': {
      'items': -1,       // unlimited during trial
      'projects': -1,
      'storage_mb': -1,
      'team_members': 5,
      'exports': -1,
    },
    'pro': {
      'items': -1,
      'projects': -1,
      'storage_mb': -1,
      'team_members': -1,
      'exports': -1,
    },
  };

  /// Returns the limit for a resource on a given plan.
  /// Returns -1 if unlimited, 0 if blocked, or N if capped.
  static int getLimit(String plan, String resource) {
    return limits[plan]?[resource] ?? 0;
  }

  /// Returns true if the user can create another item of [resource].
  static bool canCreate({
    required String plan,
    required String resource,
    required int currentCount,
  }) {
    final limit = getLimit(plan, resource);
    if (limit == -1) return true;  // unlimited
    if (limit == 0) return false;  // blocked
    return currentCount < limit;
  }

  /// Returns a user-facing string describing the limit.
  static String getLimitDescription(String plan, String resource) {
    final limit = getLimit(plan, resource);
    if (limit == -1) return 'Unlimited';
    if (limit == 0) return 'Not available';
    return 'Up to $limit';
  }
}
