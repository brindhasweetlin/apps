import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../models/user_model.dart';
import '../models/team_model.dart';
import '../models/event_model.dart';
import '../models/bet_model.dart';
import '../constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Users Collection
  CollectionReference<UserModel> get usersCollection =>
      _firestore.collection(AppConstants.usersCollection).withConverter<UserModel>(
            fromFirestore: (snapshot, _) {
              final data = snapshot.data()!;
              return UserModel(
                id: snapshot.id,
                email: data['email'] ?? '',
                displayName: data['displayName'],
                photoUrl: data['photoUrl'],
                username: data['username'],
                bio: data['bio'],
                credits: (data['credits'] as num?)?.toInt() ?? 1000,
                emailVerified: data['emailVerified'] ?? false,
                isAnonymous: data['isAnonymous'] ?? false,
                notificationsEnabled: data['notificationsEnabled'] ?? true,
                followingTeamIds: List<String>.from(data['followingTeamIds'] ?? []),
                betIds: List<String>.from(data['betIds'] ?? []),
                createdAt: (data['createdAt'] as Timestamp).toDate(),
                updatedAt: (data['updatedAt'] as Timestamp).toDate(),
                lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
              );
            },
            toFirestore: (user, _) => user.toMap(),
          );

  // Teams Collection
  CollectionReference<TeamModel> get teamsCollection =>
      _firestore.collection(AppConstants.teamsCollection).withConverter<TeamModel>(
            fromFirestore: (snapshot, _) => TeamModel.fromFirestore(snapshot),
            toFirestore: (team, _) => team.toMap(),
          );

  // Events Collection
  CollectionReference<EventModel> get eventsCollection =>
      _firestore.collection(AppConstants.eventsCollection).withConverter<EventModel>(
            fromFirestore: (snapshot, _) => EventModel.fromFirestore(snapshot),
            toFirestore: (event, _) => event.toMap(),
          );

  // Bets Collection
  CollectionReference<BetModel> get betsCollection =>
      _firestore.collection(AppConstants.betsCollection).withConverter<BetModel>(
            fromFirestore: (snapshot, _) => BetModel.fromFirestore(snapshot),
            toFirestore: (bet, _) => bet.toMap(),
          );

  // User Operations
  Future<DocumentSnapshot<UserModel>> getUser(String userId) async {
    return await usersCollection.doc(userId).get();
  }

  /// Creates or updates a user profile in Firestore
  Future<void> createUserProfile({
    required String userId,
    required String email,
    String? displayName,
    String? photoUrl,
    String? username,
  }) async {
    try {
      debugPrint('FirestoreService: Creating/updating user profile for UID: $userId');
      debugPrint('FirestoreService: Email: $email, Display Name: $displayName, Username: $username');
      
      // Generate a username from email if not provided
      final usernameValue = username?.toLowerCase() ?? email.split('@')[0].toLowerCase();
      debugPrint('FirestoreService: Using username: $usernameValue');
      
      final user = UserModel(
        id: userId,
        email: email,
        displayName: displayName ?? email.split('@')[0],
        photoUrl: photoUrl,
        username: usernameValue,
        credits: 100, // Starting credits for new users
        followingTeamIds: [],
        betIds: [],
        notificationsEnabled: true,
        emailVerified: false,
        isAnonymous: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      debugPrint('FirestoreService: User model created: ${user.toMap()}');
      
      // Set the document with the UserModel instance
      debugPrint('FirestoreService: Saving user to Firestore...');
      await usersCollection.doc(userId).set(user);
      debugPrint('FirestoreService: User saved successfully');
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  /// Updates specific user fields
  Future<void> updateUserProfile(
    String userId, {
    String? displayName,
    String? photoUrl,
    String? username,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final updateData = {
        if (displayName != null) 'displayName': displayName,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (username != null) 'username': username.toLowerCase(),
        'updatedAt': FieldValue.serverTimestamp(),
        ...?additionalData,
      };

      await usersCollection.doc(userId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Gets a stream of user data
  Stream<UserModel> getUserStream(String userId) {
    return usersCollection
        .doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.data()!);
  }

  /// Updates user notification settings
  Future<void> updateNotificationSettings({
    required String userId,
    required Map<String, dynamic> settings,
  }) async {
    try {
      await usersCollection.doc(userId).update({
        'notificationSettings': settings,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update notification settings: $e');
    }
  }

  /// Checks if a username is available
  Future<bool> isUsernameAvailable(String username) async {
    if (username.isEmpty) return false;
    
    final query = await usersCollection
        .where('username', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();
        
    return query.docs.isEmpty;
  }

  /// Updates user data - kept for backward compatibility
  @Deprecated('Use updateUserProfile instead')
  Future<void> updateUser(
    String userId, {
    String? displayName,
    String? photoUrl,
    String? bio,
    String? username,
    int? credits,
    List<String>? followingTeamIds,
    List<String>? betIds,
  }) async {
    final additionalData = <String, dynamic>{};
    if (bio != null) additionalData['bio'] = bio;
    if (credits != null) additionalData['credits'] = credits;
    if (followingTeamIds != null) additionalData['followingTeamIds'] = followingTeamIds;
    if (betIds != null) additionalData['betIds'] = betIds;
    
    return updateUserProfile(
      userId,
      displayName: displayName,
      photoUrl: photoUrl,
      username: username,
      additionalData: additionalData.isNotEmpty ? additionalData : null,
    );
  }

  /// Creates a new user - kept for backward compatibility
  @Deprecated('Use createUserProfile instead')
  Future<void> createUser(UserModel user) async {
    // Create a copy of the user's data without the fields we're passing explicitly
    final userMap = user.toMap()..removeWhere((key, _) =>
      ['id', 'email', 'displayName', 'photoUrl', 'username'].contains(key)
    );

    return createUserProfile(
      userId: user.id,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      username: user.username,
    );
  }

  Future<void> deleteUser(String userId) async {
    await usersCollection.doc(userId).delete();
  }

  // Team Operations
  Stream<List<TeamModel>> getPopularTeams({int limit = 10}) {
    return teamsCollection
        .orderBy('followerCount', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<TeamModel> getTeam(String teamId) async {
    final doc = await teamsCollection.doc(teamId).get();
    if (!doc.exists) {
      throw Exception('Team not found');
    }
    return doc.data()!;
  }

  // Event Operations
  Stream<List<EventModel>> getUpcomingEvents({int limit = 10}) {
    return eventsCollection
        .where('startTime', isGreaterThanOrEqualTo: DateTime.now())
        .orderBy('startTime')
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<EventModel>> getLiveEvents({int limit = 10}) {
    return eventsCollection
        .where('status', isEqualTo: 'ongoing')
        .orderBy('startTime')
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<EventModel> getEvent(String eventId) async {
    final doc = await eventsCollection.doc(eventId).get();
    if (!doc.exists) {
      throw Exception('Event not found');
    }
    return doc.data()!;
  }

  // Bet Operations
  Future<BetModel> placeBet(BetModel bet) async {
    // Start a batch write to ensure data consistency
    final batch = _firestore.batch();
    
    // Add bet to bets collection
    final betRef = betsCollection.doc();
    final betWithId = bet.copyWith();
    
    // Update user's credits
    final userRef = usersCollection.doc(bet.userId);
    
    // Add operations to batch
    batch.set(betRef, betWithId.toMap()..['id'] = betRef.id);
    batch.update(userRef, {
      'credits': FieldValue.increment(-bet.amount),
      'betIds': FieldValue.arrayUnion([betRef.id]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    // Execute batch
    await batch.commit();
    
    return betWithId;
  }

  Stream<List<BetModel>> getUserBets(String userId) {
    return betsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('placedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Follow/Unfollow Team
  Future<void> toggleFollowTeam(String userId, String teamId, bool isFollowing) async {
    final userRef = usersCollection.doc(userId);
    final teamRef = teamsCollection.doc(teamId);
    
    final batch = _firestore.batch();
    
    if (isFollowing) {
      // Unfollow
      batch.update(userRef, {
        'followingTeamIds': FieldValue.arrayRemove([teamId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      batch.update(teamRef, {
        'followerCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Follow
      batch.update(userRef, {
        'followingTeamIds': FieldValue.arrayUnion([teamId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      batch.update(teamRef, {
        'followerCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    
    await batch.commit();
  }

  // Search
  Stream<List<TeamModel>> searchTeams(String query) {
    if (query.isEmpty) {
      return const Stream.empty();
    }
    
    final searchTerm = query.toLowerCase();
    
    return teamsCollection
        .where('nameLowercase', isGreaterThanOrEqualTo: searchTerm)
        .where('nameLowercase', isLessThanOrEqualTo: '$searchTerm\uf8ff')
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Helper method to initialize test data (for development)
  Future<void> initializeTestData() async {
    // This is just a placeholder - in a real app, you'd have proper data management
    // and this would be part of your admin panel or deployment scripts
    
    // Check if test data already exists
    final teamsSnapshot = await teamsCollection.limit(1).get();
    if (teamsSnapshot.docs.isNotEmpty) return;
    
    // Add some test teams
    final teams = [
      TeamModel(
        id: 'team1',
        name: 'Sales Titans',
        description: 'Leading sales team with a track record of success',
        sport: 'Sales',
        winRate: 0.85,
        totalEarnings: 15000,
      ),
      TeamModel(
        id: 'team2',
        name: 'Deal Makers',
        description: 'Specializing in high-value enterprise deals',
        sport: 'Sales',
        winRate: 0.75,
        totalEarnings: 12000,
      ),
    ];
    
    // Add test teams to Firestore
    final batch = _firestore.batch();
    for (final team in teams) {
      final docRef = teamsCollection.doc(team.id);
      batch.set(docRef, team);
    }
    
    await batch.commit();
  }
}
