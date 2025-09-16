import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutterfire_ui/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.child});
  final Widget child;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _showOnboarding = false;
  bool _checkedPrefs = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('onboarding_complete') ?? false;
    setState(() {
      _showOnboarding = !completed;
      _checkedPrefs = true;
    });
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || !_checkedPrefs) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData) {
          return SignInScreen(
            providerConfigs: const [
              EmailProviderConfiguration(),
              GoogleProviderConfiguration(
                clientId: 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com',
              ),
            ],
            headerBuilder: (context, constraints, _) {
              return const Padding(
                padding: EdgeInsets.only(top: 32.0),
                child: Text(
                  'Welcome to Sales Bets',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              );
            },
            subtitleBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Win but never lose! Bet on business challenges and earn rewards.',
                  textAlign: TextAlign.center,
                ),
              );
            },
          );
        }
        if (_showOnboarding) {
          return OnboardingScreen(onFinish: _finishOnboarding);
        }
        return widget.child;
      },
    );
  }
}
