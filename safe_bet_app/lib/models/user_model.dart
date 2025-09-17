import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel {
  @JsonKey(required: true)
  final String id;
  
  @JsonKey(required: true)
  final String email;
  
  final String? displayName;
  final String? photoUrl;
  final String? username;
  final String? bio;
  final int credits;
  final bool emailVerified;
  final bool isAnonymous;
  final List<String> followingTeamIds;
  final List<String> betIds;
  final bool notificationsEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.username,
    this.bio,
    this.credits = 1000,
    this.emailVerified = false,
    this.isAnonymous = false,
    this.notificationsEnabled = true,
    List<String>? followingTeamIds,
    List<String>? betIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.lastLoginAt,
  })  : followingTeamIds = followingTeamIds ?? [],
        betIds = betIds ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Creates a UserModel from a Firebase User
  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      emailVerified: user.emailVerified,
      isAnonymous: user.isAnonymous,
    );
  }

  /// Creates a UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      username: data['username'],
      bio: data['bio'],
      credits: (data['credits'] as num?)?.toInt() ?? 1000,
      emailVerified: data['emailVerified'] ?? false,
      isAnonymous: data['isAnonymous'] ?? false,
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      followingTeamIds: List<String>.from(data['followingTeamIds'] ?? []),
      betIds: List<String>.from(data['betIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
    );
  }
  
  /// Creates a UserModel from a Firestore QueryDocumentSnapshot
  factory UserModel.fromQueryDocumentSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return UserModel.fromFirestore(doc);
  }

  /// Creates a UserModel from a JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) => 
      _$UserModelFromJson(json);

  /// Converts the UserModel to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'username': username,
      'bio': bio,
      'credits': credits,
      'emailVerified': emailVerified,
      'isAnonymous': isAnonymous,
      'notificationsEnabled': notificationsEnabled,
      'followingTeamIds': followingTeamIds,
      'betIds': betIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (lastLoginAt != null) 'lastLoginAt': Timestamp.fromDate(lastLoginAt!),
    };
  }
  
  /// Converts the UserModel to a JSON map
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? email,
    String? displayName,
    String? photoUrl,
    int? credits,
    List<String>? followingTeamIds,
    List<String>? betIds,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      credits: credits ?? this.credits,
      followingTeamIds: followingTeamIds ?? this.followingTeamIds,
      betIds: betIds ?? this.betIds,
      createdAt: createdAt,
    );
  }
}
