import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/event_model.dart';
import '../widgets/event_card.dart';
import '../constants/app_constants.dart';

class UpcomingEventsScreen extends StatefulWidget {
  const UpcomingEventsScreen({Key? key}) : super(key: key);

  @override
  State<UpcomingEventsScreen> createState() => _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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

  bool _matchesSearchQuery(EventModel event) {
    if (_searchQuery.isEmpty) return true;
    
    final query = _searchQuery.toLowerCase();
    return event.teamIds.any((teamId) => teamId.toLowerCase().contains(query)) ||
           (event.sport?.toLowerCase().contains(query) ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Events'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Upcoming'),
            Tab(text: 'My Teams'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: EdgeInsets.zero,
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 60,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All Upcoming Tab
                _buildEventsList(
                  context,
                  stream: context.watch<FirestoreService>().getUpcomingEvents(),
                  emptyMessage: 'No upcoming events scheduled',
                ),
                // My Teams Tab
                _buildEventsList(
                  context,
                  stream: context.watch<FirestoreService>().getUpcomingEvents(),
                  emptyMessage: 'No upcoming events for your teams',
                  filterMyTeams: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(
    BuildContext context, {
    required Stream<List<EventModel>> stream,
    required String emptyMessage,
    bool filterMyTeams = false,
  }) {
    return StreamBuilder<List<EventModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
          );
        }

        final events = snapshot.data ?? [];
        
        // Apply search filter
        final filteredEvents = events.where(_matchesSearchQuery).toList();
        
        // Apply my teams filter if needed
        final displayEvents = filterMyTeams
            ? filteredEvents // TODO: Filter events for user's followed teams
            : filteredEvents;

        if (displayEvents.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                emptyMessage,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Force refresh the stream
            // The actual refresh is handled by Firestore's real-time updates
            return Future.delayed(const Duration(seconds: 1));
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: displayEvents.length,
            itemBuilder: (context, index) {
              final event = displayEvents[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                  vertical: 8.0,
                ),
                child: EventCard(
                  event: event,
                  onTap: () {
                    // Navigate to event details
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => EventDetailsScreen(event: event),
                    //   ),
                    // );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
