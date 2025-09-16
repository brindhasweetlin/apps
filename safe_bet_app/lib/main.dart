import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as fui;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'models/user_model.dart';

import 'firebase_options.dart';
import 'screens/main_navigation.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'theme/app_theme.dart';
import 'auth/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Configure FirebaseUI Auth
  final providers = <dynamic>[
    fui.EmailAuthProvider(),
    GoogleProvider(
      clientId: 'YOUR_GOOGLE_CLIENT_ID',
    ),
  ];
  
  fui.FirebaseUIAuth.configureProviders(providers.cast<fui.AuthProvider>());
  GoogleFonts.config.allowRuntimeFetching = true;
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<FirestoreService>(
          create: (_) => FirestoreService(),
        ),
        StreamProvider<UserModel?>(
          initialData: null,
          create: (context) => context.read<AuthService>().user,
          catchError: (_, __) => null,
        ),
      ],
      child: MaterialApp(
        title: 'Sales Bets',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
      ),
    );
  }
}

