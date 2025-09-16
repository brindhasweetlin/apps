class UserProfile {
  final String id;
  final String displayName;
  final String email;
  final String photoUrl;
  final int credits;
  final List<String> followedTeams;
  final List<String> followedAthletes;
  final List<String> achievements;
  final DateTime createdAt;
  final DateTime lastActive;

  UserProfile({
    required this.id,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.credits,
    required this.followedTeams,
    required this.followedAthletes,
    required this.achievements,
    required this.createdAt,
    required this.lastActive,
  });

  factory UserProfile.fromJson(String id, Map<String, dynamic> json) {
    return UserProfile(
      id: id,
      displayName: json['displayName'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      credits: json['credits'] ?? 0,
      followedTeams: List<String>.from(json['followedTeams'] ?? []),
      followedAthletes: List<String>.from(json['followedAthletes'] ?? []),
      achievements: List<String>.from(json['achievements'] ?? []),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      lastActive: (json['lastActive'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'email': email,
        'photoUrl': photoUrl,
        'credits': credits,
        'followedTeams': followedTeams,
        'followedAthletes': followedAthletes,
        'achievements': achievements,
        'createdAt': createdAt,
        'lastActive': lastActive,
      };
}

class Team {
  final String id;
  final String name;
  final String description;
  final String logoUrl;
  final List<String> members;
  final TeamStats stats;
  final int followers;
  final double trendingScore;
  final DateTime createdAt;

  Team({
    required this.id,
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.members,
    required this.stats,
    required this.followers,
    required this.trendingScore,
    required this.createdAt,
  });

  factory Team.fromJson(String id, Map<String, dynamic> json) {
    return Team(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
      members: List<String>.from(json['members'] ?? []),
      stats: TeamStats.fromJson(json['stats'] ?? {}),
      followers: json['followers'] ?? 0,
      trendingScore: (json['trendingScore'] ?? 0).toDouble(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'logoUrl': logoUrl,
        'members': members,
        'stats': stats.toJson(),
        'followers': followers,
        'trendingScore': trendingScore,
        'createdAt': createdAt,
      };
}

class TeamStats {
  final int wins;
  final int losses;
  final int totalBets;
  final int earnings;

  TeamStats({
    required this.wins,
    required this.losses,
    required this.totalBets,
    required this.earnings,
  });

  factory TeamStats.fromJson(Map<String, dynamic> json) {
    return TeamStats(
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      totalBets: json['totalBets'] ?? 0,
      earnings: json['earnings'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'wins': wins,
        'losses': losses,
        'totalBets': totalBets,
        'earnings': earnings,
      };
}

class Athlete {
  final String id;
  final String name;
  final String bio;
  final String photoUrl;
  final String teamId;
  final TeamStats stats;
  final int followers;
  final double trendingScore;
  final DateTime createdAt;

  Athlete({
    required this.id,
    required this.name,
    required this.bio,
    required this.photoUrl,
    required this.teamId,
    required this.stats,
    required this.followers,
    required this.trendingScore,
    required this.createdAt,
  });

  factory Athlete.fromJson(String id, Map<String, dynamic> json) {
    return Athlete(
      id: id,
      name: json['name'] ?? '',
      bio: json['bio'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      teamId: json['teamId'] ?? '',
      stats: TeamStats.fromJson(json['stats'] ?? {}),
      followers: json['followers'] ?? 0,
      trendingScore: (json['trendingScore'] ?? 0).toDouble(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'bio': bio,
        'photoUrl': photoUrl,
        'teamId': teamId,
        'stats': stats.toJson(),
        'followers': followers,
        'trendingScore': trendingScore,
        'createdAt': createdAt,
      };
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final String teamId;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String liveStreamUrl;
  final int totalBets;
  final int totalParticipants;
  final String? result;
  final DateTime createdAt;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.teamId,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.liveStreamUrl,
    required this.totalBets,
    required this.totalParticipants,
    required this.result,
    required this.createdAt,
  });

  factory Challenge.fromJson(String id, Map<String, dynamic> json) {
    return Challenge(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      teamId: json['teamId'] ?? '',
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: (json['endTime'] as Timestamp).toDate(),
      status: json['status'] ?? 'ongoing',
      liveStreamUrl: json['liveStreamUrl'] ?? '',
      totalBets: json['totalBets'] ?? 0,
      totalParticipants: json['totalParticipants'] ?? 0,
      result: json['result'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'teamId': teamId,
        'startTime': startTime,
        'endTime': endTime,
        'status': status,
        'liveStreamUrl': liveStreamUrl,
        'totalBets': totalBets,
        'totalParticipants': totalParticipants,
        'result': result,
        'createdAt': createdAt,
      };
}

class Bet {
  final String id;
  final String userId;
  final String challengeId;
  final String teamId;
  final int amount;
  final String status;
  final int reward;
  final DateTime placedAt;
  final DateTime? resolvedAt;

  Bet({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.teamId,
    required this.amount,
    required this.status,
    required this.reward,
    required this.placedAt,
    this.resolvedAt,
  });

  factory Bet.fromJson(String id, Map<String, dynamic> json) {
    return Bet(
      id: id,
      userId: json['userId'] ?? '',
      challengeId: json['challengeId'] ?? '',
      teamId: json['teamId'] ?? '',
      amount: json['amount'] ?? 0,
      status: json['status'] ?? 'pending',
      reward: json['reward'] ?? 0,
      placedAt: (json['placedAt'] as Timestamp).toDate(),
      resolvedAt: json['resolvedAt'] != null ? (json['resolvedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'challengeId': challengeId,
        'teamId': teamId,
        'amount': amount,
        'status': status,
        'reward': reward,
        'placedAt': placedAt,
        'resolvedAt': resolvedAt,
      };
}
