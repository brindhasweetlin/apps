import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _pageIndex = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      title: 'Welcome to Sales Bets',
      description: 'Bet on business challenges. Win money or rewards, but never lose your credits!',
      imageAsset: Icons.emoji_events,
    ),
    _OnboardingPage(
      title: 'How It Works',
      description: 'Choose a team, stake credits, and follow live progress. If your team wins, you gain more credits!',
      imageAsset: Icons.sports_score,
    ),
    _OnboardingPage(
      title: 'No-Loss System',
      description: 'Your credits can only go up. You never lose what you stake—only win or keep playing.',
      imageAsset: Icons.shield,
    ),
    _OnboardingPage(
      title: 'Live Streams & Leaderboards',
      description: 'Watch teams compete live and climb the leaderboards. Follow your favorites for updates.',
      imageAsset: Icons.live_tv,
    ),
  ];

  void _nextPage() {
    if (_pageIndex < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade700,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _pageIndex = index),
                itemBuilder: (context, i) => _pages[i],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _pageIndex ? Colors.white : Colors.white24,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepPurple.shade700,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: _nextPage,
                  child: Text(_pageIndex == _pages.length - 1 ? 'Get Started' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData imageAsset;
  const _OnboardingPage({required this.title, required this.description, required this.imageAsset});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(imageAsset, size: 120, color: Colors.white),
          const SizedBox(height: 40),
          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
          const SizedBox(height: 18),
          Text(description, style: const TextStyle(fontSize: 18, color: Colors.white70), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
