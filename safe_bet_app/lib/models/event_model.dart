import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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

  // Helper method to parse dates safely
  static DateTime? _parseDate(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is DateTime) return timestamp;
    return null;
  }

  // Helper method to parse status
  static EventStatus _parseStatus(String? statusStr) {
    try {
      final status = statusStr?.toLowerCase() ?? 'upcoming';
      return EventStatus.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == status,
        orElse: () => EventStatus.upcoming,
      );
    } catch (e) {
      // Using print instead of debugPrint since this is a static method
      print('Error parsing status: $statusStr, defaulting to upcoming');
      return EventStatus.upcoming;
    }
  }

  // Helper method to parse odds map
  static Map<String, double> _parseOdds(Map<String, dynamic>? oddsMap) {
    final result = <String, double>{};
    if (oddsMap != null) {
      try {
        oddsMap.forEach((key, value) {
          if (value is num) {
            result[key] = value.toDouble();
          }
        });
      } catch (e) {
        // Using print instead of debugPrint since this is a static method
        print('Error parsing odds: $e');
      }
    }
    return result;
  }

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      
      return EventModel(
        id: doc.id,
        title: (data['title'] ?? 'Untitled Event').toString(),
        description: (data['description'] ?? '').toString(),
        imageUrl: data['imageUrl']?.toString(),
        streamUrl: data['streamUrl']?.toString(),
        sport: (data['sport'] ?? 'General').toString(),
        teamIds: data['teamIds'] is List 
            ? List<String>.from(
                (data['teamIds'] as List).map((e) => e.toString()),
              )
            : <String>[],
        odds: _parseOdds(data['odds'] as Map<String, dynamic>?),
        startTime: _parseDate(data['startTime']) ?? DateTime.now(),
        endTime: _parseDate(data['endTime']),
        status: _parseStatus(data['status'] as String?),
        winningTeamId: data['winningTeamId']?.toString(),
        totalPot: (data['totalPot'] is int) 
            ? data['totalPot'] as int 
            : (data['totalPot'] as num?)?.toInt() ?? 0,
        participantCount: (data['participantCount'] is int)
            ? data['participantCount'] as int
            : (data['participantCount'] as num?)?.toInt() ?? 0,
        createdAt: _parseDate(data['createdAt']) ?? DateTime.now(),
        updatedAt: _parseDate(data['updatedAt']) ?? DateTime.now(),
      );
    } catch (e, stackTrace) {
      // Using print instead of debugPrint since this is a factory constructor
      print('Error in EventModel.fromFirestore: $e');
      print('Stack trace: $stackTrace');
      print('Document ID: ${doc.id}');
      
      // Return a default event with error information
      return EventModel(
        id: doc.id,
        title: 'Error Loading Event',
        description: 'Failed to load event data',
        sport: 'Error',
        teamIds: [],
        odds: {},
        startTime: DateTime.now(),
        status: EventStatus.upcoming,
      );
    }
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
      teamIds: teamIds ?? List<String>.from(this.teamIds),
      odds: odds ?? Map<String, double>.from(this.odds),
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      winningTeamId: winningTeamId ?? this.winningTeamId,
      totalPot: totalPot ?? this.totalPot,
      participantCount: participantCount ?? this.participantCount,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  bool get isUpcoming => status == EventStatus.upcoming;
  bool get isOngoing => status == EventStatus.ongoing;
  bool get isCompleted => status == EventStatus.completed;
  bool get isCancelled => status == EventStatus.cancelled;
}
