import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as fui show AuthProvider, AuthStateChangeAction, FirebaseUIAuth, SignInScreen, SignedIn, EmailAuthProvider, EmailFormStyle, ButtonVariant;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

import '../screens/main_navigation.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'profile_setup_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: context.read<AuthService>().user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const CustomSignInScreen();
        }

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.id)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              final firebaseUser = FirebaseAuth.instance.currentUser;
              if (firebaseUser != null) {
                return ProfileSetupScreen(user: firebaseUser);
              }
              return const CustomSignInScreen();
            }

            return const MainNavigation();
          },
        );
      },
    );
  }
}

class CustomSignInScreen extends StatelessWidget {
  const CustomSignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final providers = <fui.AuthProvider>[
      fui.EmailAuthProvider(),
      GoogleProvider(
        clientId: 'YOUR_GOOGLE_CLIENT_ID',
      ),
    ];
    
    return fui.SignInScreen(
      providers: providers.cast<fui.AuthProvider>(),
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
      fui.AuthStateChangeAction<fui.SignedIn>((context, state) async {
        final user = state.user!;
        final metadata = user.metadata;
        final isNewUser = metadata.creationTime == metadata.lastSignInTime;
        
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
    styles: const {
      fui.EmailFormStyle(signInButtonVariant: fui.ButtonVariant.filled),
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
