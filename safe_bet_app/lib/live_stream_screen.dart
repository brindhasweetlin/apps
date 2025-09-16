import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LiveStreamScreen extends StatelessWidget {
  final String challengeId;
  final String? streamUrl; // e.g., YouTube, Vimeo, or RTMP URL
  const LiveStreamScreen({super.key, required this.challengeId, this.streamUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Stream')),
      body: Column(
        children: [
          // Placeholder for video player (replace with actual player integration)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: streamUrl != null && streamUrl!.isNotEmpty
                ? Center(child: Text('Embed video player for: $streamUrl'))
                : const Center(child: Text('No live stream available.')),
          ),
          const Divider(),
          Expanded(
            child: ChatOverlay(challengeId: challengeId),
          ),
        ],
      ),
    );
  }
}

class ChatOverlay extends StatelessWidget {
  final String challengeId;
  const ChatOverlay({super.key, required this.challengeId});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Live Chat', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('challenges')
                .doc(challengeId)
                .collection('chat')
                .orderBy('sentAt', descending: true)
                .limit(50)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              return ListView.builder(
                reverse: true,
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final data = docs[i].data() as Map<String, dynamic>;
                  return ListTile(
                    leading: CircleAvatar(child: Text(data['userId']?[0] ?? '?')),
                    title: Text(data['message'] ?? ''),
                    subtitle: Text(data['userId'] ?? ''),
                  );
                },
              );
            },
          ),
        ),
        if (user != null)
          ChatInputField(challengeId: challengeId, userId: user.uid),
      ],
    );
  }
}

class ChatInputField extends StatefulWidget {
  final String challengeId;
  final String userId;
  const ChatInputField({super.key, required this.challengeId, required this.userId});

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;

  Future<void> _sendMessage() async {
    final msg = _controller.text.trim();
    if (msg.isEmpty) return;
    setState(() => _sending = true);
    await FirebaseFirestore.instance
        .collection('challenges')
        .doc(widget.challengeId)
        .collection('chat')
        .add({
      'userId': widget.userId,
      'message': msg,
      'sentAt': Timestamp.now(),
    });
    _controller.clear();
    setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Type a message...'),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: _sending ? const CircularProgressIndicator() : const Icon(Icons.send),
            onPressed: _sending ? null : _sendMessage,
          ),
        ],
      ),
    );
  }
}
