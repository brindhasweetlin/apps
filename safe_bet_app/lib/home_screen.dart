import 'firestore_service.dart';
import 'models.dart';
import 'live_streams_tab.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          'Ongoing Business Challenges',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: StreamBuilder<List<Challenge>>(
            stream: firestore.streamOngoingChallenges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No ongoing challenges.'));
              }
              final challenges = snapshot.data!;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: challenges.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final c = challenges[i];
                  return Card(
                    elevation: 2,
                    child: Container(
                      width: 220,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.title, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 6),
                          Text(c.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Team: ${c.teamId}', style: const TextStyle(fontSize: 12)),
                              Text('${c.totalBets} bets', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Trending Teams & Athletes',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: StreamBuilder<List<Team>>(
            stream: firestore.streamTrendingTeams(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No trending teams.'));
              }
              final teams = snapshot.data!;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: teams.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final t = teams[i];
                  return Card(
                    color: Colors.deepPurple.shade100,
                    child: Container(
                      width: 120,
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.name, style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 4),
                          Text('${t.followers} followers', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Place a No-Loss Bet',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<Challenge>>(
          stream: firestore.streamOngoingChallenges(),
          builder: (context, challengeSnap) {
            if (!challengeSnap.hasData || challengeSnap.data!.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No challenges available for betting.'),
                ),
              );
            }
            return StreamBuilder<List<Team>>(
              stream: firestore.streamTeams(),
              builder: (context, teamSnap) {
                if (!teamSnap.hasData || teamSnap.data!.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No teams available.'),
                    ),
                  );
                }
                return BettingWidget(
                  challenges: challengeSnap.data!,
                  teams: teamSnap.data!,
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  final String title;
  const PlaceholderWidget({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
