import 'package:flutter/material.dart';
import 'firestore_service.dart';
import 'models.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeamsScreen extends StatelessWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.leaderboard),
              label: const Text('View Leaderboards'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LeaderboardsScreen()),
                );
              },
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Team>>(
            stream: FirestoreService().streamTeams(),
            builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No teams found.'));
        }
        final teams = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: teams.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final t = teams[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.shade100,
                child: Text(t.name.isNotEmpty ? t.name[0] : '?'),
              ),
              title: Text(t.name),
              subtitle: Text('${t.members.length} athletes · ${t.followers} followers'),
              trailing: Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TeamProfileScreen(team: t),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class TeamProfileScreen extends StatelessWidget {
  final Team team;
  const TeamProfileScreen({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(team.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.deepPurple.shade100,
                  child: Text(team.name.isNotEmpty ? team.name[0] : '?', style: const TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(team.name, style: Theme.of(context).textTheme.headlineSmall),
                      Text(team.description),
                    ],
                  ),
                ),
                FollowButton(teamId: team.id),
              ],
            ),
            const SizedBox(height: 16),
            Text('Stats', style: Theme.of(context).textTheme.titleMedium),
            Text('Wins: ${team.stats.wins}, Losses: ${team.stats.losses}, Earnings: ${team.stats.earnings}'),
            const SizedBox(height: 16),
            Text('Athletes', style: Theme.of(context).textTheme.titleMedium),
            Expanded(child: AthletesList(teamId: team.id)),
          ],
        ),
      ),
    );
  }
}

class AthletesList extends StatelessWidget {
  final String teamId;
  const AthletesList({super.key, required this.teamId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Athlete>>(
      stream: FirestoreService().streamAthletes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final athletes = snapshot.data!.where((a) => a.teamId == teamId).toList();
        if (athletes.isEmpty) return const Center(child: Text('No athletes.'));
        return ListView.separated(
          itemCount: athletes.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, i) {
            final a = athletes[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.shade200,
                child: Text(a.name.isNotEmpty ? a.name[0] : '?'),
              ),
              title: Text(a.name),
              subtitle: Text(a.bio),
              trailing: Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AthleteProfileScreen(athlete: a),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class AthleteProfileScreen extends StatelessWidget {
  final Athlete athlete;
  const AthleteProfileScreen({super.key, required this.athlete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(athlete.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.deepPurple.shade200,
                  child: Text(athlete.name.isNotEmpty ? athlete.name[0] : '?', style: const TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(athlete.name, style: Theme.of(context).textTheme.headlineSmall),
                      Text(athlete.bio),
                    ],
                  ),
                ),
                FollowButton(athleteId: athlete.id),
              ],
            ),
            const SizedBox(height: 16),
            Text('Stats', style: Theme.of(context).textTheme.titleMedium),
            Text('Wins: ${athlete.stats.wins}, Losses: ${athlete.stats.losses}, Earnings: ${athlete.stats.earnings}'),
          ],
        ),
      ),
    );
  }
}

class FollowButton extends StatefulWidget {
  final String? teamId;
  final String? athleteId;
  const FollowButton({this.teamId, this.athleteId, super.key});

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool _following = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _checkFollowing();
  }

  Future<void> _checkFollowing() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snap = await FirestoreService()._db.collection('users').doc(user.uid).get();
    final data = snap.data() ?? {};
    if (widget.teamId != null) {
      setState(() {
        _following = (data['followedTeams'] ?? []).contains(widget.teamId);
      });
    } else if (widget.athleteId != null) {
      setState(() {
        _following = (data['followedAthletes'] ?? []).contains(widget.athleteId);
      });
    }
  }

  Future<void> _toggleFollow() async {
    setState(() => _loading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final ref = FirestoreService()._db.collection('users').doc(user.uid);
    if (widget.teamId != null) {
      await ref.update({
        'followedTeams': _following
            ? FieldValue.arrayRemove([widget.teamId])
            : FieldValue.arrayUnion([widget.teamId]),
      });
    } else if (widget.athleteId != null) {
      await ref.update({
        'followedAthletes': _following
            ? FieldValue.arrayRemove([widget.athleteId])
            : FieldValue.arrayUnion([widget.athleteId]),
      });
    }
    await _checkFollowing();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _loading ? null : _toggleFollow,
      child: _loading
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : Text(_following ? 'Unfollow' : 'Follow'),
    );
  }
}
