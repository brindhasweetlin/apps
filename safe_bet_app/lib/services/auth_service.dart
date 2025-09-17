import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

  // Configure authentication providers
  static List<AuthProvider<AuthListener, firebase_auth.AuthCredential>> get authProviders {
    return [
      EmailAuthProvider(),
      GoogleProvider(
        clientId: 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com',
      ),
    ];
  }

  // Get current user
  UserModel? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  // Auth state changes
  Stream<UserModel?> get user {
    debugPrint('AuthService: Subscribed to auth state changes');
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      debugPrint('AuthService: Auth state changed. User: ${firebaseUser?.uid}');
      
      if (firebaseUser == null) {
        debugPrint('AuthService: No user signed in');
        return null;
      }
      
      try {
        debugPrint('AuthService: Fetching user data from Firestore for UID: ${firebaseUser.uid}');
        final userDoc = await _firestoreService.usersCollection.doc(firebaseUser.uid).get();
        
        if (userDoc.exists) {
          debugPrint('AuthService: Found existing user in Firestore');
          return userDoc.data();
        } else {
          debugPrint('AuthService: Creating new user profile in Firestore');
          // Create new user profile in Firestore if not exists
          final newUser = UserModel(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? 'no-email@example.com',
            displayName: firebaseUser.displayName ?? 'User ${firebaseUser.uid.substring(0, 6)}',
            photoUrl: firebaseUser.photoURL,
            username: firebaseUser.email?.split('@')[0]?.toLowerCase() ?? 'user_${firebaseUser.uid.substring(0, 6)}',
            credits: 100,
            followingTeamIds: [],
            betIds: [],
            notificationsEnabled: true,
            emailVerified: firebaseUser.emailVerified,
            isAnonymous: firebaseUser.isAnonymous,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          // Save the new user to Firestore
          await _firestoreService.usersCollection.doc(firebaseUser.uid).set(newUser);
          debugPrint('AuthService: Successfully created new user');
          return newUser;
        }
      } catch (e, stackTrace) {
        debugPrint('AuthService: Error in user stream: $e');
        debugPrint('Stack trace: $stackTrace');
        rethrow;
      }
    }).handleError((error) {
      debugPrint('AuthService: Error in user stream: $error');
      throw error;
    });
  }

  // Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Failed to sign in');
      }

      // Get user data from Firestore
      final userDoc = await _firestoreService.usersCollection.doc(credential.user!.uid).get();
      
      if (!userDoc.exists) {
        throw Exception('User data not found');
      }
      
      return userDoc.data()!;
    } catch (e) {
      rethrow;
    }
  }

  // Register with email and password
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Create user in Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        throw Exception('Failed to create user');
      }
      
      // Update display name
      await credential.user!.updateDisplayName(displayName);
      await credential.user!.reload();
      
      // Create new user profile in Firestore
      final newUser = UserModel(
        id: credential.user!.uid,
        email: email,
        displayName: displayName,
        photoUrl: credential.user!.photoURL,
        username: email.split('@')[0].toLowerCase(),
        credits: 100,
        followingTeamIds: [],
        betIds: [],
        notificationsEnabled: true,
        emailVerified: false,
        isAnonymous: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save the new user to Firestore
      await _firestoreService.usersCollection.doc(credential.user!.uid).set(newUser);
      debugPrint('AuthService: Successfully created new user');
      return newUser;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }
      
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;
      
      // Create a new credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase with the credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user == null) {
        throw Exception('Failed to sign in with Google');
      }
      
      // Check if user exists in Firestore
      try {
        final userDoc = await _firestoreService.usersCollection.doc(userCredential.user!.uid).get();
        
        if (!userDoc.exists) {
          // Create new user profile in Firestore if not exists
          final newUser = UserModel(
            id: userCredential.user!.uid,
            email: userCredential.user!.email ?? 'no-email@example.com',
            displayName: userCredential.user!.displayName ?? 'User ${userCredential.user!.uid.substring(0, 6)}',
            photoUrl: userCredential.user!.photoURL,
            username: userCredential.user!.email?.split('@')[0]?.toLowerCase() ?? 'user_${userCredential.user!.uid.substring(0, 6)}',
            credits: 100,
            followingTeamIds: [],
            betIds: [],
            notificationsEnabled: true,
            emailVerified: userCredential.user!.emailVerified,
            isAnonymous: userCredential.user!.isAnonymous,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          // Save the new user to Firestore
          await _firestoreService.usersCollection.doc(userCredential.user!.uid).set(newUser);
          debugPrint('AuthService: Successfully created new user');
          return newUser;
        } else {
          return userDoc.data()!;
        }
      } catch (e) {
        debugPrint('Error in signInWithGoogle: $e');
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      // Update in Firebase Auth
      final user = _auth.currentUser;
      if (user != null) {
        if (displayName != null) {
          await user.updateDisplayName(displayName);
        }
        if (photoUrl != null) {
          await user.updatePhotoURL(photoUrl);
        }
      }
      
      // Update in Firestore
      await _firestoreService.updateUser(
        userId,
        displayName: displayName,
        photoUrl: photoUrl,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete from Firestore first
        await _firestoreService.deleteUser(user.uid);
        
        // Then delete from Firebase Auth
        await user.delete();
      }
    } catch (e) {
      rethrow;
    }
  }
}
