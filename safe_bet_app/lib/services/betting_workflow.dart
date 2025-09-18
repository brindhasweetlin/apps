import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/bet_model.dart';
import '../models/event_model.dart';
import 'auth_service.dart';
import 'firestore_service.dart';

class BettingWorkflow {
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
    final currentUser = _authService.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');
    final userId = currentUser.id;

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
    // final user = await _firestoreService.getUser(userId);
    // if (user.credits < amount) {
    //   throw Exception('Insufficient balance');
    // }

    // Create bet using the factory method
    final bet = BetModel.create(
      userId: userId,
      eventId: eventId,
      teamId: teamId,
      amount: amount,
      odds: odds,
      isNoLossBet: isNoLossBet,
    );

    // Use the existing placeBet method in FirestoreService
    return await _firestoreService.placeBet(bet);
  }

  // Get user's active bets
  Stream<List<BetModel>> getUserBets(String userId) {
    return _firestoreService.getUserBets(userId);
  }

  // Get event's bets
  Stream<List<BetModel>> getEventBets(String eventId) {
    return _firestoreService.getEventBets(eventId);
  }

  // Cancel a bet (only if event hasn't started)
  Future<void> cancelBet(String betId) async {
    final bet = await _firestoreService.getBet(betId);
    final event = await _firestoreService.getEvent(bet.eventId);
    
    if (event.status != EventStatus.upcoming) {
      throw Exception('Cannot cancel bet after event has started');
    }

    // In a real app, you would also refund the user's balance here
    // await _firestoreService.updateUserCredits(
    //   bet.userId,
    //   bet.amount,
    //   isRefund: true,
    // );

    await _firestoreService.updateBetStatus(betId, 'cancelled');
  }

  // Admin function to resolve bets when event ends
  Future<void> resolveEventBets(String eventId, String? winningTeamId) async {
    final event = await _firestoreService.getEvent(eventId);
    final bets = await _firestoreService.getEventBets(eventId).first;

    final batch = _firestore.batch();
    
    for (final bet in bets) {
      if (bet.status == BetStatus.pending) {
        final isWinningBet = bet.teamId == winningTeamId;
        
        batch.update(_firestore.collection('bets').doc(bet.id), {
          'status': isWinningBet ? 'won' : 'lost',
          'resolvedAt': FieldValue.serverTimestamp(),
        });

        // In a real app, you would update user balances here
        // if (isWinningBet) {
        //   await _firestoreService.updateUserCredits(
        //     bet.userId,
        //     bet.potentialWinnings,
        //   );
        // } else if (bet.isNoLossBet && winningTeamId != null) {
        //   // For no-loss bets, return the original stake if lost
        //   await _firestoreService.updateUserCredits(
        //     bet.userId,
        //     bet.amount,
        //     isRefund: true,
        //   );
        // }
      }
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
final bettingWorkflow = BettingWorkflow();
