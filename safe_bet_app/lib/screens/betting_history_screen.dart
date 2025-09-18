import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/bet_model.dart';
import '../models/event_model.dart';
import '../models/team_model.dart';
import '../services/firestore_service.dart';
import '../widgets/team_card.dart';

class BettingHistoryScreen extends StatelessWidget {
  const BettingHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view your betting history')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Betting History'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<BetModel>>(
        stream: context.read<FirestoreService>().getUserBets(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final bets = snapshot.data ?? [];
          
          if (bets.isEmpty) {
            return const Center(
              child: Text('No bets placed yet. Start betting on events!'),
            );
          }

          return ListView.builder(
            itemCount: bets.length,
            padding: const EdgeInsets.all(8.0),
            itemBuilder: (context, index) {
              final bet = bets[index];
              return _BetCard(bet: bet);
            },
          );
        },
      ),
    );
  }
}

class _BetCard extends StatelessWidget {
  final BetModel bet;

  const _BetCard({Key? key, required this.bet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadBetDetails(context, bet),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Card(
            child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Loading bet details...'),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.error, color: Colors.red),
              title: const Text('Error loading bet'),
              subtitle: Text(snapshot.error.toString()),
            ),
          );
        }

        final details = snapshot.data!;
        final event = details['event'] as EventModel;
        final team = details['team'] as TeamModel?;
        final isWon = bet.status == BetStatus.won;
        final isLost = bet.status == BetStatus.lost;
        final isPending = bet.status == BetStatus.pending;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          elevation: 2.0,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildStatusChip(bet.status),
                  ],
                ),
                const SizedBox(height: 12),
                if (team != null) TeamCard(team: team),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn(
                      context,
                      'Stake',
                      '\$${bet.amount.toStringAsFixed(2)}',
                    ),
                    _buildInfoColumn(
                      context,
                      'Odds',
                      '${bet.odds.toStringAsFixed(2)}x',
                    ),
                    _buildInfoColumn(
                      context,
                      'Potential Win',
                      '\$${bet.potentialWinnings.toStringAsFixed(2)}',
                      isHighlighted: true,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Placed on ${DateFormat('MMM d, y • h:mm a').format(bet.placedAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (isWon || isLost)
                      Text(
                        isWon
                            ? 'Won: \$${bet.potentialWinnings.toStringAsFixed(2)}'
                            : 'Lost: -\$${bet.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: isWon ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(BetStatus status) {
    Color color;
    String label;

    switch (status) {
      case BetStatus.won:
        color = Colors.green.shade100;
        label = 'Won';
        break;
      case BetStatus.lost:
        color = Colors.red.shade100;
        label = 'Lost';
        break;
      case BetStatus.pending:
        color = Colors.blue.shade100;
        label = 'Pending';
        break;
      case BetStatus.cancelled:
        color = Colors.grey.shade300;
        label = 'Cancelled';
        break;
      case BetStatus.refunded:
        color = Colors.orange.shade100;
        label = 'Refunded';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: status == BetStatus.won
              ? Colors.green.shade800
              : status == BetStatus.lost
                  ? Colors.red.shade800
                  : Colors.grey.shade800,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoColumn(
    BuildContext context, 
    String label, 
    String value, {
    bool isHighlighted = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                color: isHighlighted ? Theme.of(context).primaryColor : null,
              ),
        ),
      ],
    );
  }

  Future<Map<String, dynamic>> _loadBetDetails(
      BuildContext context, BetModel bet) async {
    try {
      final firestoreService = context.read<FirestoreService>();
      
      // Get event data
      final eventDoc = await firestoreService.eventsCollection.doc(bet.eventId).get();
      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }
      final event = eventDoc.data()!;
      
      // Get team data if teamId exists
      TeamModel? team;
      if (bet.teamId != null && bet.teamId!.isNotEmpty) {
        try {
          final teamDoc = await firestoreService.teamsCollection.doc(bet.teamId).get();
          if (teamDoc.exists) {
            team = teamDoc.data();
          }
        } catch (e) {
          debugPrint('Error loading team: $e');
        }
      }
      
      return {
        'event': event,
        'team': team,
      };
    } catch (e) {
      debugPrint('Error loading bet details: $e');
      rethrow;
    }
  }
}
