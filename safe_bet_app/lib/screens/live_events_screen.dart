import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/event_model.dart';
import '../widgets/event_card.dart';
import '../constants/app_constants.dart';

class LiveEventsScreen extends StatefulWidget {
  const LiveEventsScreen({Key? key}) : super(key: key);

  @override
  State<LiveEventsScreen> createState() => _LiveEventsScreenState();
}

class _LiveEventsScreenState extends State<LiveEventsScreen>
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Events'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Live Now'),
            Tab(text: 'Upcoming'),
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
                // Live Tab
                _buildEventsList(
                  context,
                  stream: context.watch<FirestoreService>().getLiveEvents(),
                  emptyMessage: 'No live events at the moment',
                ),
                // Upcoming Tab
                _buildEventsList(
                  context,
                  stream: context.watch<FirestoreService>().getUpcomingEvents(),
                  emptyMessage: 'No upcoming events scheduled',
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
  }) {
    return StreamBuilder<List<EventModel>>(
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

        final events = snapshot.data ?? [];
        
        // Filter events based on search query
        final filteredEvents = _searchQuery.isEmpty
            ? events
            : events.where((event) =>
                    event.title.toLowerCase().contains(_searchQuery) ||
                    event.description.toLowerCase().contains(_searchQuery) ||
                    event.teamIds.any((team) =>
                        team.toLowerCase().contains(_searchQuery))).toList();

        if (filteredEvents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  emptyMessage,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: 8,
          ),
          itemCount: filteredEvents.length,
          itemBuilder: (context, index) {
            final event = filteredEvents[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: EventCard(event: event),
            );
          },
        );
      },
    );
  }
}
