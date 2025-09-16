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

  factory BetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Convert status string to enum
    BetStatus status;
    switch ((data['status'] as String?)?.toLowerCase()) {
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

    return BetModel(
      id: doc.id,
      userId: data['userId'],
      eventId: data['eventId'],
      teamId: data['teamId'],
      amount: (data['amount'] ?? 0).toInt(),
      odds: (data['odds'] ?? 1.0).toDouble(),
      potentialWinnings: (data['potentialWinnings'] ?? 0).toInt(),
      status: status,
      placedAt: (data['placedAt'] as Timestamp).toDate(),
      resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
      isNoLossBet: data['isNoLossBet'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
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

    return {
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

  BetModel copyWith({
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
      id: id,
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
