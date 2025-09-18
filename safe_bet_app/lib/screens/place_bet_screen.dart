import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../models/team_model.dart';
import '../services/betting_workflow.dart';
import '../services/firestore_service.dart';
import '../widgets/team_card.dart';

class PlaceBetScreen extends StatefulWidget {
  final String eventId;

  const PlaceBetScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  _PlaceBetScreenState createState() => _PlaceBetScreenState();
}

class _PlaceBetScreenState extends State<PlaceBetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? _selectedTeamId;
  bool _isLoading = true;
  bool _isPlacingBet = false;
  late EventModel _event;
  late Map<String, TeamModel> _teams = {};
  Map<String, double> _odds = {};
  double _potentialWinnings = 0;

  @override
  void initState() {
    super.initState();
    _loadEventData();
    _amountController.addListener(_calculateWinnings);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadEventData() async {
    try {
      // Get event details
      _event = await context.read<FirestoreService>().getEvent(widget.eventId);
      
      // Get teams data
      final teams = await Future.wait(
        _event.teamIds.map((teamId) => 
          context.read<FirestoreService>().getTeam(teamId)
        ),
      );
      
      // Get current odds
      _odds = await bettingWorkflow.getLiveOdds(widget.eventId);
      
      setState(() {
        _teams = {for (var team in teams) team.id: team};
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading event data: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  void _calculateWinnings() {
    if (_selectedTeamId == null || _amountController.text.isEmpty) {
      setState(() => _potentialWinnings = 0);
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;
    final odds = _odds[_selectedTeamId!] ?? 1.0;
    setState(() {
      _potentialWinnings = amount * odds;
    });
  }

  Future<void> _placeBet() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTeamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a team to bet on')),
      );
      return;
    }

    setState(() => _isPlacingBet = true);

    try {
      final amount = int.parse(_amountController.text);
      final odds = _odds[_selectedTeamId!] ?? 1.0;
      
      await bettingWorkflow.placeBet(
        eventId: widget.eventId,
        teamId: _selectedTeamId!,
        amount: amount,
        odds: odds,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bet placed successfully!')),
        );
        Navigator.pop(context, true); // Return success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place bet: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPlacingBet = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Place a Bet'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _event.title,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                'Select a team to bet on:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._teams.values.map((team) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: RadioListTile<String>(
                  title: TeamCard(team: team),
                  subtitle: Text('Odds: ${_odds[team.id]?.toStringAsFixed(2) ?? '1.90'}x'),
                  value: team.id,
                  groupValue: _selectedTeamId,
                  onChanged: (value) {
                    setState(() {
                      _selectedTeamId = value;
                      _calculateWinnings();
                    });
                  },
                ),
              )),
              const SizedBox(height: 24),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Bet Amount',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = int.tryParse(value);
                  if (amount == null || amount < 10 || amount > 1000) {
                    return 'Amount must be between \$10 and \$1000';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bet Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Selected Team:'),
                          Text(
                            _selectedTeamId != null 
                                ? _teams[_selectedTeamId]!.name 
                                : 'None',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Odds:'),
                          Text(
                            _selectedTeamId != null
                                ? '${_odds[_selectedTeamId]?.toStringAsFixed(2) ?? '1.90'}x'
                                : 'N/A',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Potential Winnings:'),
                          Text(
                            '\$${_potentialWinnings.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isPlacingBet ? null : _placeBet,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: _isPlacingBet
                    ? const CircularProgressIndicator()
                    : const Text('Place Bet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
