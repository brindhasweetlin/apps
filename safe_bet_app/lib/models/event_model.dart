import 'package:cloud_firestore/cloud_firestore.dart';

enum EventStatus {
  upcoming,
  ongoing,
  completed,
  cancelled,
}

class EventModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? streamUrl;
  final String sport;
  final List<String> teamIds;
  final Map<String, double> odds; // teamId -> odds
  final DateTime startTime;
  final DateTime? endTime;
  final EventStatus status;
  final String? winningTeamId;
  final int totalPot;
  final int participantCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.streamUrl,
    required this.sport,
    required this.teamIds,
    required this.odds,
    required this.startTime,
    this.endTime,
    EventStatus? status,
    this.winningTeamId,
    this.totalPot = 0,
    this.participantCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : status = status ?? EventStatus.upcoming,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Convert status string to enum
    EventStatus status;
    switch ((data['status'] as String?)?.toLowerCase()) {
      case 'ongoing':
        status = EventStatus.ongoing;
        break;
      case 'completed':
        status = EventStatus.completed;
        break;
      case 'cancelled':
        status = EventStatus.cancelled;
        break;
      case 'upcoming':
      default:
        status = EventStatus.upcoming;
    }
    
    // Convert odds map
    final oddsMap = <String, double>{};
    if (data['odds'] != null) {
      (data['odds'] as Map<String, dynamic>).forEach((key, value) {
        if (value is num) {
          oddsMap[key] = value.toDouble();
        }
      });
    }

    return EventModel(
      id: doc.id,
      title: data['title'] ?? 'Untitled Event',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      streamUrl: data['streamUrl'],
      sport: data['sport'] ?? 'General',
      teamIds: List<String>.from(data['teamIds'] ?? []),
      odds: oddsMap,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp?)?.toDate(),
      status: status,
      winningTeamId: data['winningTeamId'],
      totalPot: (data['totalPot'] ?? 0).toInt(),
      participantCount: (data['participantCount'] ?? 0).toInt(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    String statusString;
    switch (status) {
      case EventStatus.ongoing:
        statusString = 'ongoing';
        break;
      case EventStatus.completed:
        statusString = 'completed';
        break;
      case EventStatus.cancelled:
        statusString = 'cancelled';
        break;
      case EventStatus.upcoming:
      default:
        statusString = 'upcoming';
    }

    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'streamUrl': streamUrl,
      'sport': sport,
      'teamIds': teamIds,
      'odds': odds,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'status': statusString,
      'winningTeamId': winningTeamId,
      'totalPot': totalPot,
      'participantCount': participantCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  EventModel copyWith({
    String? title,
    String? description,
    String? imageUrl,
    String? streamUrl,
    String? sport,
    List<String>? teamIds,
    Map<String, double>? odds,
    DateTime? startTime,
    DateTime? endTime,
    EventStatus? status,
    String? winningTeamId,
    int? totalPot,
    int? participantCount,
  }) {
    return EventModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      streamUrl: streamUrl ?? this.streamUrl,
      sport: sport ?? this.sport,
      teamIds: teamIds ?? this.teamIds,
      odds: odds ?? this.odds,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      winningTeamId: winningTeamId ?? this.winningTeamId,
      totalPot: totalPot ?? this.totalPot,
      participantCount: participantCount ?? this.participantCount,
      createdAt: createdAt,
    );
  }

  bool get isUpcoming => status == EventStatus.upcoming;
  bool get isOngoing => status == EventStatus.ongoing;
  bool get isCompleted => status == EventStatus.completed;
  bool get isCancelled => status == EventStatus.cancelled;
}
