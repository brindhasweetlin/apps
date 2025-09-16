// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'email']);
  return UserModel(
    id: json['id'] as String,
    email: json['email'] as String,
    displayName: json['displayName'] as String?,
    photoUrl: json['photoUrl'] as String?,
    username: json['username'] as String?,
    bio: json['bio'] as String?,
    credits: (json['credits'] as num?)?.toInt() ?? 1000,
    emailVerified: json['emailVerified'] as bool? ?? false,
    isAnonymous: json['isAnonymous'] as bool? ?? false,
    notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    followingTeamIds: (json['followingTeamIds'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    betIds: (json['betIds'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] == null
        ? null
        : DateTime.parse(json['updatedAt'] as String),
    lastLoginAt: json['lastLoginAt'] == null
        ? null
        : DateTime.parse(json['lastLoginAt'] as String),
  );
}

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'displayName': instance.displayName,
  'photoUrl': instance.photoUrl,
  'username': instance.username,
  'bio': instance.bio,
  'credits': instance.credits,
  'emailVerified': instance.emailVerified,
  'isAnonymous': instance.isAnonymous,
  'followingTeamIds': instance.followingTeamIds,
  'betIds': instance.betIds,
  'notificationsEnabled': instance.notificationsEnabled,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
};
