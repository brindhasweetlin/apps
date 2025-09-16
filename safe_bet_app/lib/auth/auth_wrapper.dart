import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/main_navigation.dart';
import '../services/firestore_service.dart';
import 'profile_setup_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const SignInScreen();
        }

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return ProfileSetupScreen(user: user);
            }

            return const MainNavigation();
          },
        );
      },
    );
  }
}

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      providers: [
        EmailAuthProvider(),
        GoogleProvider(
          clientId: 'YOUR_GOOGLE_CLIENT_ID',
          style: GoogleProvider.Style(
            iconSize: 24,
            buttonType: ButtonStyle.filled,
          ),
        ),
      ],
      headerBuilder: (context, constraints, _) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to SalesBets',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
      actions: [
        AuthStateChangeAction<SignedIn>((context, state) async {
          final user = state.user!;
          final isNewUser = state.credential == null || state.credential!.isNewUser;
          
          if (isNewUser) {
            await FirestoreService().createUserProfile(
              userId: user.uid,
              email: user.email!,
              displayName: user.displayName ?? user.email!.split('@')[0],
              photoUrl: user.photoURL,
              username: user.email!.split('@')[0].toLowerCase(),
            );
          }
        }),
      ],
      styles: {
        EmailFormStyle(signInButtonVariant: ButtonVariant.filled),
      },
      footerBuilder: (context, action) {
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            'By signing in, you agree to our Terms of Service and Privacy Policy',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}
