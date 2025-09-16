import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../widgets/team_card.dart';
import '../models/team_model.dart';
import '../constants/app_constants.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({Key? key}) : super(key: key);

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? _buildSearchField()
            : const Text('Teams'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Popular'),
            Tab(text: 'Following'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Popular Teams Tab
          _buildTeamsList(
            context,
            stream: context.watch<FirestoreService>().getPopularTeams(),
            emptyMessage: 'No teams available',
          ),
          // Following Tab
          _buildFollowingTeamsList(context),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search teams...',
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      style: const TextStyle(color: Colors.white),
      onChanged: (value) {
        setState(() {
          _searchQuery = value.toLowerCase();
        });
      },
    );
  }

  Widget _buildTeamsList(
    BuildContext context, {
    required Stream<List<TeamModel>> stream,
    required String emptyMessage,
  }) {
    return StreamBuilder<List<TeamModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        var teams = snapshot.data ?? [];
        
        // Filter teams based on search query
        if (_searchQuery.isNotEmpty) {
          teams = teams.where((team) =>
              team.name.toLowerCase().contains(_searchQuery) ||
              team.sport.toLowerCase().contains(_searchQuery) ||
              (team.description?.toLowerCase().contains(_searchQuery) ?? false)).toList();
        }

        if (teams.isEmpty) {
          return _buildEmptyState(context, emptyMessage);
        }

        return GridView.builder(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: teams.length,
          itemBuilder: (context, index) {
            final team = teams[index];
            return TeamCard(
              team: team,
              onTap: () {
                // Navigate to team details
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => TeamDetailsScreen(teamId: team.id),
                //   ),
                // );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFollowingTeamsList(BuildContext context) {
    // In a real app, you would fetch the user's followed teams
    // For now, we'll show a placeholder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Teams you follow will appear here',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Switch to popular tab
              _tabController.animateTo(0);
            },
            child: const Text('Browse Teams'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_off_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
