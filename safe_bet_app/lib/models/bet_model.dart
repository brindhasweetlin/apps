import 'package:cloud_firestore/cloud_firestore.dart';

enum BetStatus {
  pending,
  won,
  lost,
  refunded,
  cancelled,
}

class BetModel {
  final String id;
  final String userId;
  final String eventId;
  final String teamId;
  final int amount;
  final double odds;
  final int potentialWinnings;
  final BetStatus status;
  final DateTime placedAt;
  final DateTime? resolvedAt;
  final bool isNoLossBet;

  BetModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.teamId,
    required this.amount,
    required this.odds,
    required this.potentialWinnings,
    BetStatus? status,
    DateTime? placedAt,
    this.resolvedAt,
    this.isNoLossBet = true, // Default to true for our no-loss betting model
  })  : status = status ?? BetStatus.pending,
        placedAt = placedAt ?? DateTime.now();

  factory BetModel.fromFirestore(dynamic doc) {
    try {
      // Handle both DocumentSnapshot and QueryDocumentSnapshot
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Document data is null');
      }
      
      // Convert status string to enum
      BetStatus status;
      final statusStr = (data['status'] as String?)?.toLowerCase();
      switch (statusStr) {
        case 'won':
          status = BetStatus.won;
          break;
        case 'lost':
          status = BetStatus.lost;
          break;
        case 'refunded':
          status = BetStatus.refunded;
          break;
        case 'cancelled':
          status = BetStatus.cancelled;
          break;
        case 'pending':
        default:
          status = BetStatus.pending;
      }

      // Safely parse dates
      DateTime? parseDate(dynamic timestamp) {
        if (timestamp == null) return null;
        if (timestamp is Timestamp) return timestamp.toDate();
        if (timestamp is DateTime) return timestamp;
        return null;
      }

      return BetModel(
        id: doc.id,
        userId: data['userId']?.toString() ?? '',
        eventId: data['eventId']?.toString() ?? '',
        teamId: data['teamId']?.toString() ?? '',
        amount: (data['amount'] is int) ? data['amount'] as int : (data['amount'] as num?)?.toInt() ?? 0,
        odds: (data['odds'] is double) ? data['odds'] as double : (data['odds'] as num?)?.toDouble() ?? 1.0,
        potentialWinnings: (data['potentialWinnings'] is int) ? data['potentialWinnings'] as int : (data['potentialWinnings'] as num?)?.toInt() ?? 0,
        status: status,
        placedAt: parseDate(data['placedAt']) ?? DateTime.now(),
        resolvedAt: parseDate(data['resolvedAt']),
        isNoLossBet: data['isNoLossBet'] == true,
      );
    } catch (e, stackTrace) {
      print('Error in BetModel.fromFirestore: $e');
      print('Stack trace: $stackTrace');
      print('Document ID: ${doc.id}');
      print('Document data: ${doc.data()}');
      rethrow;
    }
  }

  // Convert BetModel to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    String statusString;
    switch (status) {
      case BetStatus.won:
        statusString = 'won';
        break;
      case BetStatus.lost:
        statusString = 'lost';
        break;
      case BetStatus.refunded:
        statusString = 'refunded';
        break;
      case BetStatus.cancelled:
        statusString = 'cancelled';
        break;
      case BetStatus.pending:
      default:
        statusString = 'pending';
    }

    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'eventId': eventId,
      'teamId': teamId,
      'amount': amount,
      'odds': odds,
      'potentialWinnings': potentialWinnings,
      'status': statusString,
      'placedAt': Timestamp.fromDate(placedAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'isNoLossBet': isNoLossBet,
    };
  }

  // For backward compatibility
  Map<String, dynamic> toMap() => toFirestore();

  BetModel copyWith({
    String? id,
    String? userId,
    String? eventId,
    String? teamId,
    int? amount,
    double? odds,
    int? potentialWinnings,
    BetStatus? status,
    DateTime? placedAt,
    DateTime? resolvedAt,
    bool? isNoLossBet,
  }) {
    return BetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      teamId: teamId ?? this.teamId,
      amount: amount ?? this.amount,
      odds: odds ?? this.odds,
      potentialWinnings: potentialWinnings ?? this.potentialWinnings,
      status: status ?? this.status,
      placedAt: placedAt ?? this.placedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      isNoLossBet: isNoLossBet ?? this.isNoLossBet,
    );
  }

  // Helper getters
  bool get isPending => status == BetStatus.pending;
  bool get isWon => status == BetStatus.won;
  bool get isLost => status == BetStatus.lost;
  bool get isRefunded => status == BetStatus.refunded;
  bool get isCancelled => status == BetStatus.cancelled;
  
  // Calculate potential winnings based on amount and odds
  static int calculatePotentialWinnings(int amount, double odds) {
    return (amount * odds).round();
  }
  
  // Create a new bet with calculated potential winnings
  factory BetModel.create({
    required String userId,
    required String eventId,
    required String teamId,
    required int amount,
    required double odds,
    bool isNoLossBet = true,
  }) {
    final potentialWinnings = calculatePotentialWinnings(amount, odds);
    final now = DateTime.now();
    
    return BetModel(
      id: '', // Will be set when saved to Firestore
      userId: userId,
      eventId: eventId,
      teamId: teamId,
      amount: amount,
      odds: odds,
      potentialWinnings: potentialWinnings,
      isNoLossBet: isNoLossBet,
    );
  }
}
