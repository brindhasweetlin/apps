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
  CollectionReference<UserModel> get usersCollection {
    return _firestore.collection(AppConstants.usersCollection).withConverter<UserModel>(
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
          followingTeamIds: List<String>.from(data['followingTeamIds'] ?? []),
          betIds: List<String>.from(data['betIds'] ?? []),
          notificationsEnabled: data['notificationsEnabled'] ?? true,
          isAnonymous: data['isAnonymous'] ?? false,
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      },
      toFirestore: (UserModel user, _) => user.toMap(),
    );
  }

  // Teams Collection
  CollectionReference<TeamModel> get teamsCollection {
    return _firestore.collection(AppConstants.teamsCollection).withConverter<TeamModel>(
      fromFirestore: (snapshot, _) => TeamModel.fromFirestore(snapshot),
      toFirestore: (TeamModel team, _) => team.toMap(),
    );
  }

  // Raw collections without model conversion
  CollectionReference<Map<String, dynamic>> get _rawEventsCollection {
    return _firestore.collection(AppConstants.eventsCollection);
  }

  // Events Collection with model conversion
  CollectionReference<EventModel> get eventsCollection {
    return _firestore.collection(AppConstants.eventsCollection).withConverter<EventModel>(
      fromFirestore: (snapshot, _) => EventModel.fromFirestore(snapshot),
      toFirestore: (EventModel event, _) => event.toMap(),
    );
  }

  // Raw bets collection without type conversion
  CollectionReference<Map<String, dynamic>> get _rawBetsCollection {
    return _firestore.collection(AppConstants.betsCollection);
  }

  // Bets collection with type conversion
  CollectionReference<BetModel> get betsCollection {
    return _rawBetsCollection.withConverter<BetModel>(
      fromFirestore: (snapshot, _) => BetModel.fromFirestore(snapshot),
      toFirestore: (BetModel bet, _) => bet.toFirestore(),
    );
  }

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
    try {
      return usersCollection
          .doc(userId)
          .snapshots()
          .map((doc) => doc.data()!)
          .handleError((error) {
            debugPrint('Error in getUserStream: $error');
            throw error;
          });
    } catch (e) {
      debugPrint('Error setting up user stream: $e');
      rethrow;
    }
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
    return _rawEventsCollection
        .where('startTime', isGreaterThanOrEqualTo: DateTime.now())
        .orderBy('startTime')
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<EventModel>> getLiveEvents({int limit = 10}) {
    return _rawEventsCollection
        .where('status', isEqualTo: 'ongoing')
        .orderBy('startTime')
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromFirestore(doc))
            .toList());
  }

  Future<EventModel> getEvent(String eventId) async {
    try {
      final doc = await _rawEventsCollection.doc(eventId).get();
      if (!doc.exists) {
        throw Exception('Event not found');
      }
      return EventModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error getting event $eventId: $e');
      rethrow;
    }
  }

  // Place a new bet
  Future<BetModel> placeBet(BetModel bet) async {
    try {
      // Get user data to check balance
      final userDoc = await usersCollection.doc(bet.userId).get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }
      
      final userData = userDoc.data()!;
      if (userData.credits < bet.amount) {
        throw Exception('Insufficient credits');
      }
      
      // Create a new bet with ID and timestamps
      final now = DateTime.now();
      
      // Create a new bet with the generated ID
      final betWithId = BetModel(
        id: '', // Will be set by Firestore
        userId: bet.userId,
        eventId: bet.eventId,
        teamId: bet.teamId,
        amount: bet.amount,
        odds: bet.odds,
        potentialWinnings: bet.potentialWinnings,
        status: BetStatus.pending,
        placedAt: now,
        isNoLossBet: bet.isNoLossBet,
      );
      
      // Start a batch write to ensure data consistency
      final batch = _firestore.batch();
      
      // Add the bet to the bets collection
      final betRef = _rawBetsCollection.doc();
      batch.set(betRef, betWithId.toFirestore());
      
      // Update user's credits and bet IDs
      final userRef = usersCollection.doc(bet.userId);
      batch.update(userRef, {
        'credits': FieldValue.increment(-bet.amount),
        'betIds': FieldValue.arrayUnion([betRef.id]),
        'updatedAt': now,
      });
      
      // Execute batch
      await batch.commit();
      
      // Return the created bet with the new ID
      return betWithId.copyWith(id: betRef.id);
    } catch (e) {
      debugPrint('Error placing bet: $e');
      rethrow; // Rethrow to be handled by the caller
    }
  }

  Stream<List<BetModel>> getUserBets(String userId) {
    try {
      // Use _rawBetsCollection to avoid double conversion
      return _rawBetsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('placedAt', descending: true)
          .snapshots()
          .handleError((error) {
            debugPrint('Error in getUserBets stream: $error');
            return <QueryDocumentSnapshot<Map<String, dynamic>>>[];
          })
          .map((snapshot) {
            try {
              return snapshot.docs
                  .map((doc) {
                    try {
                      return BetModel.fromFirestore(doc);
                    } catch (e, stackTrace) {
                      debugPrint('Error parsing bet ${doc.id}: $e');
                      debugPrint('Stack trace: $stackTrace');
                      debugPrint('Document data: ${doc.data()}');
                      return null;
                    }
                  })
                  .whereType<BetModel>()
                  .toList();
            } catch (e, stackTrace) {
              debugPrint('Error mapping bets: $e');
              debugPrint('Stack trace: $stackTrace');
              return <BetModel>[];
            }
          });
    } catch (e, stackTrace) {
      debugPrint('Error in getUserBets: $e');
      debugPrint('Stack trace: $stackTrace');
      return Stream.value(<BetModel>[]);
    }
  }

  /// Get all bets for a specific event
  Stream<List<BetModel>> getEventBets(String eventId) {
    return betsCollection
        .where('eventId', isEqualTo: eventId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Get a specific bet by ID
  Future<BetModel> getBet(String betId) async {
    final doc = await betsCollection.doc(betId).get();
    if (!doc.exists) {
      throw Exception('Bet not found');
    }
    return doc.data()!;
  }

  /// Update bet status
  Future<void> updateBetStatus(String betId, String status) async {
    await betsCollection.doc(betId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
      if (status == 'won' || status == 'lost') 'resolvedAt': FieldValue.serverTimestamp(),
    });
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
