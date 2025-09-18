import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/bet_model.dart';
import '../models/event_model.dart';
import 'auth_service.dart';
import 'firestore_service.dart';

class BettingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  // Place a new bet
  Future<BetModel> placeBet({
    required String eventId,
    required String teamId,
    required int amount,
    required double odds,
    bool isNoLossBet = true,
  }) async {
    final userId = _authService.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Validate bet amount (minimum 10, maximum 1000)
    if (amount < 10 || amount > 1000) {
      throw Exception('Bet amount must be between 10 and 1000');
    }

    // Get event to validate
    final event = await _firestoreService.getEvent(eventId);
    
    // Check if event is still open for betting
    if (event.status != EventStatus.upcoming) {
      throw Exception('Betting is closed for this event');
    }

    // Check if team is valid for this event
    if (!event.teamIds.contains(teamId)) {
      throw Exception('Invalid team for this event');
    }

    // In a real app, you would also check user balance here
    // await _checkUserBalance(userId, amount);

    final betId = const Uuid().v4();
    final potentialWinnings = (amount * odds).toInt();

    final bet = BetModel(
      id: betId,
      userId: userId,
      eventId: eventId,
      teamId: teamId,
      amount: amount,
      odds: odds,
      potentialWinnings: potentialWinnings,
      isNoLossBet: isNoLossBet,
    );

    // Start a batch write for atomic operations
    final batch = _firestore.batch();
    
    // Add the bet
    final betRef = _firestore.collection('bets').doc(betId);
    batch.set(betRef, bet.toMap());

    // Update event's total pot
    final eventRef = _firestore.collection('events').doc(eventId);
    batch.update(eventRef, {
      'totalPot': FieldValue.increment(amount),
      'participantCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // In a real app, you would also deduct from user's balance here
    // await _deductUserBalance(userId, amount);

    // Commit the batch
    await batch.commit();

    return bet;
  }

  // Get user's active bets
  Stream<List<BetModel>> getUserBets(String userId) {
    return _firestore
        .collection('bets')
        .where('userId', isEqualTo: userId)
        .orderBy('placedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BetModel.fromFirestore(doc))
            .toList());
  }

  // Get event bets
  Stream<List<BetModel>> getEventBets(String eventId) {
    return _firestore
        .collection('bets')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BetModel.fromFirestore(doc))
            .toList());
  }

  // Cancel a bet (only if event hasn't started)
  Future<void> cancelBet(String betId) async {
    final betDoc = await _firestore.collection('bets').doc(betId).get();
    if (!betDoc.exists) throw Exception('Bet not found');
    
    final bet = BetModel.fromFirestore(betDoc);
    final event = await _firestoreService.getEvent(bet.eventId);
    
    if (event.status != EventStatus.upcoming) {
      throw Exception('Cannot cancel bet after event has started');
    }

    final batch = _firestore.batch();
    
    // Update bet status
    batch.update(betDoc.reference, {
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update event's total pot
    batch.update(
      _firestore.collection('events').doc(bet.eventId),
      {
        'totalPot': FieldValue.increment(-bet.amount),
        'participantCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );

    // In a real app, you would also refund the user's balance here
    // await _refundUserBalance(bet.userId, bet.amount);

    await batch.commit();
  }

  // Admin function to resolve bets when event ends
  Future<void> resolveEventBets(String eventId, String? winningTeamId) async {
    final event = await _firestoreService.getEvent(eventId);
    final bets = await _firestore
        .collection('bets')
        .where('eventId', isEqualTo: eventId)
        .where('status', isEqualTo: 'pending')
        .get();

    final batch = _firestore.batch();
    
    for (final doc in bets.docs) {
      final bet = BetModel.fromFirestore(doc);
      final isWinningBet = bet.teamId == winningTeamId;
      
      batch.update(doc.reference, {
        'status': isWinningBet ? 'won' : 'lost',
        'resolvedAt': FieldValue.serverTimestamp(),
      });

      // In a real app, you would also update user balances here
      // if (isWinningBet) {
      //   await _awardWinnings(bet.userId, bet.potentialWinnings);
      // } else if (bet.isNoLossBet && winningTeamId != null) {
      //   // For no-loss bets, return the original stake if lost
      //   await _refundUserBalance(bet.userId, bet.amount);
      // }
    }

    // Update event status
    batch.update(
      _firestore.collection('events').doc(eventId),
      {
        'status': 'completed',
        'winningTeamId': winningTeamId,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );

    await batch.commit();
  }

  // Get live odds for an event
  Future<Map<String, double>> getLiveOdds(String eventId) async {
    final event = await _firestoreService.getEvent(eventId);
    
    // In a real app, you would calculate odds based on:
    // 1. Total amount bet on each team
    // 2. House edge
    // 3. Other factors like team performance, etc.
    
    // For now, return the stored odds or default to 1.9 for each team
    if (event.odds.isNotEmpty) {
      return event.odds;
    }
    
    return {for (var teamId in event.teamIds) teamId: 1.9};
  }
}

// Singleton instance
final bettingService = BettingService();
