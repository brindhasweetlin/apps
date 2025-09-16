import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';
import 'models.dart';

class BettingWidget extends StatefulWidget {
  final List<Challenge> challenges;
  final List<Team> teams;
  const BettingWidget({super.key, required this.challenges, required this.teams});

  @override
  State<BettingWidget> createState() => _BettingWidgetState();
}

class _BettingWidgetState extends State<BettingWidget> {
  Challenge? _selectedChallenge;
  Team? _selectedTeam;
  int _credits = 10;
  bool _loading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    if (widget.challenges.isNotEmpty) {
      _selectedChallenge = widget.challenges.first;
    }
    if (widget.teams.isNotEmpty) {
      _selectedTeam = widget.teams.first;
    }
  }

  void _placeBet() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedChallenge == null || _selectedTeam == null) {
      setState(() {
        _loading = false;
        _message = 'Please sign in and select a challenge/team.';
      });
      return;
    }
    final bet = Bet(
      id: DateTime.now().millisecondsSinceEpoch.toString() + user.uid,
      userId: user.uid,
      challengeId: _selectedChallenge!.id,
      teamId: _selectedTeam!.id,
      amount: _credits,
      status: 'pending',
      reward: 0,
      placedAt: DateTime.now(),
      resolvedAt: null,
    );
    try {
      await FirestoreService().placeBet(bet);
      setState(() {
        _message = 'Bet placed! If your team wins, you gain credits.';
      });
    } catch (e) {
      setState(() {
        _message = 'Error placing bet.';
      });
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.deepPurple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Place a No-Loss Bet', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<Challenge>(
              value: _selectedChallenge,
              isExpanded: true,
              hint: const Text('Select Challenge'),
              items: widget.challenges.map((c) => DropdownMenuItem(
                value: c,
                child: Text(c.title),
              )).toList(),
              onChanged: (val) => setState(() => _selectedChallenge = val),
            ),
            const SizedBox(height: 8),
            DropdownButton<Team>(
              value: _selectedTeam,
              isExpanded: true,
              hint: const Text('Select Team'),
              items: widget.teams.map((t) => DropdownMenuItem(
                value: t,
                child: Text(t.name),
              )).toList(),
              onChanged: (val) => setState(() => _selectedTeam = val),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Credits:'),
                Expanded(
                  child: Slider(
                    value: _credits.toDouble(),
                    min: 10,
                    max: 100,
                    divisions: 9,
                    label: _credits.toString(),
                    onChanged: (val) => setState(() => _credits = val.toInt()),
                  ),
                ),
                Text('$_credits'),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _placeBet,
                child: _loading ? const CircularProgressIndicator() : const Text('Place Bet'),
              ),
            ),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(_message!, style: const TextStyle(color: Colors.green)),
              ),
          ],
        ),
      ),
    );
  }
}
