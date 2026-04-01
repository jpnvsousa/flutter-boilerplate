import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/app_user.dart';

part 'profile_model.g.dart';

/// Data model for the `profiles` table in Supabase.
/// Maps raw JSON to/from domain [AppUser] entity.
@JsonSerializable(fieldRename: FieldRename.snake)
class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    required this.plan,
    this.trialEndsAt,
    this.rcCustomerId,
    this.fcmToken,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String plan;
  final DateTime? trialEndsAt;
  final String? rcCustomerId;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);

  AppUser toEntity() => AppUser(
        id: id,
        email: email,
        fullName: fullName,
        avatarUrl: avatarUrl,
        plan: plan,
        trialEndsAt: trialEndsAt,
        rcCustomerId: rcCustomerId,
        fcmToken: fcmToken,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
