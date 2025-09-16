import 'package:cloud_firestore/cloud_firestore.dart';

class TeamModel {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? bannerUrl;
  final String sport;
  final List<String> memberIds;
  final int followerCount;
  final double winRate;
  final int totalEarnings;
  final DateTime createdAt;
  final DateTime updatedAt;

  TeamModel({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.bannerUrl,
    required this.sport,
    List<String>? memberIds,
    this.followerCount = 0,
    this.winRate = 0.0,
    this.totalEarnings = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : memberIds = memberIds ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory TeamModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TeamModel(
      id: doc.id,
      name: data['name'] ?? 'Unknown Team',
      description: data['description'],
      logoUrl: data['logoUrl'],
      bannerUrl: data['bannerUrl'],
      sport: data['sport'] ?? 'General',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      followerCount: (data['followerCount'] ?? 0).toInt(),
      winRate: (data['winRate'] ?? 0.0).toDouble(),
      totalEarnings: (data['totalEarnings'] ?? 0).toInt(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'bannerUrl': bannerUrl,
      'sport': sport,
      'memberIds': memberIds,
      'followerCount': followerCount,
      'winRate': winRate,
      'totalEarnings': totalEarnings,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  TeamModel copyWith({
    String? name,
    String? description,
    String? logoUrl,
    String? bannerUrl,
    String? sport,
    List<String>? memberIds,
    int? followerCount,
    double? winRate,
    int? totalEarnings,
  }) {
    return TeamModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      sport: sport ?? this.sport,
      memberIds: memberIds ?? this.memberIds,
      followerCount: followerCount ?? this.followerCount,
      winRate: winRate ?? this.winRate,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      createdAt: createdAt,
    );
  }
}
