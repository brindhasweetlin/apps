import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

  // Configure authentication providers
  static List<AuthProvider<AuthListener, AuthCredential>> get authProviders {
    return [
      EmailAuthProvider(),
      GoogleProvider(
        clientId: 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com',
      ),
      // AppleProvider(), // Uncomment when you set up Apple Sign In
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
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      
      // Get user data from Firestore
      final userDoc = await _firestoreService.getUser(firebaseUser.uid);
      
      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      } else {
        // Create new user in Firestore if not exists
        final newUser = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName,
          photoUrl: firebaseUser.photoURL,
        );
        
        await _firestoreService.createUser(newUser);
        return newUser;
      }
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
      
      return UserModel(
        id: credential.user!.uid,
        email: credential.user!.email ?? '',
        displayName: credential.user!.displayName,
        photoUrl: credential.user!.photoURL,
      );
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
      
      // Create user in Firestore
      final newUser = UserModel(
        id: credential.user!.uid,
        email: email,
        displayName: displayName,
        photoUrl: credential.user!.photoURL,
      );
      
      await _firestoreService.createUser(newUser);
      
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
      final userDoc = await _firestoreService.getUser(userCredential.user!.uid);
      
      if (!userDoc.exists) {
        // Create new user in Firestore if not exists
        final newUser = UserModel(
          id: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          displayName: userCredential.user!.displayName,
          photoUrl: userCredential.user!.photoURL,
        );
        
        await _firestoreService.createUser(newUser);
        return newUser;
      } else {
        return UserModel.fromFirestore(userDoc);
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
