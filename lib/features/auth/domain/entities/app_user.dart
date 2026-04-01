import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

/// Core user entity — maps to the `profiles` table in Supabase.
/// Immutable, equality-comparable, and serializable via Freezed.
@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String email,
    String? fullName,
    String? avatarUrl,
    @Default('trial') String plan,
    DateTime? trialEndsAt,
    String? rcCustomerId,    // RevenueCat customer ID
    String? fcmToken,        // Firebase Cloud Messaging token
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}
