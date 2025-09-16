import 'package:flutter/material.dart';
import 'firestore_service.dart';
import 'models.dart';

class LeaderboardsScreen extends StatefulWidget {
  const LeaderboardsScreen({super.key});

  @override
  State<LeaderboardsScreen> createState() => _LeaderboardsScreenState();
}

class _LeaderboardsScreenState extends State<LeaderboardsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboards'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Teams'),
            Tab(text: 'Athletes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TeamsLeaderboard(),
          AthletesLeaderboard(),
        ],
      ),
    );
  }
}

class TeamsLeaderboard extends StatelessWidget {
  const TeamsLeaderboard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Team>>(
      stream: FirestoreService().streamTeams(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final teams = snapshot.data!..sort((a, b) => b.stats.earnings.compareTo(a.stats.earnings));
        return ListView.builder(
          itemCount: teams.length,
          itemBuilder: (context, i) {
            final t = teams[i];
            return ListTile(
              leading: CircleAvatar(child: Text('${i + 1}')),
              title: Text(t.name),
              subtitle: Text('Earnings: ${t.stats.earnings} | Wins: ${t.stats.wins}'),
              trailing: Text('${t.followers} followers'),
            );
          },
        );
      },
    );
  }
}

class AthletesLeaderboard extends StatelessWidget {
  const AthletesLeaderboard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Athlete>>(
      stream: FirestoreService().streamAthletes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final athletes = snapshot.data!..sort((a, b) => b.stats.earnings.compareTo(a.stats.earnings));
        return ListView.builder(
          itemCount: athletes.length,
          itemBuilder: (context, i) {
            final a = athletes[i];
            return ListTile(
              leading: CircleAvatar(child: Text('${i + 1}')),
              title: Text(a.name),
              subtitle: Text('Earnings: ${a.stats.earnings} | Wins: ${a.stats.wins}'),
              trailing: Text(a.teamId),
            );
          },
        );
      },
    );
  }
}
