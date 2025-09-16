import 'package:flutter/material.dart';
import 'firestore_service.dart';
import 'models.dart';
import 'live_stream_screen.dart';

class LiveStreamsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Challenge>>(
      stream: FirestoreService().streamOngoingChallenges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No live events right now.'));
        }
        final challenges = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: challenges.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final c = challenges[i];
            return Card(
              child: ListTile(
                title: Text(c.title),
                subtitle: Text(c.description),
                trailing: ElevatedButton.icon(
                  icon: const Icon(Icons.live_tv),
                  label: const Text('Watch Live'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LiveStreamScreen(
                          challengeId: c.id,
                          streamUrl: c.liveStreamUrl,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
