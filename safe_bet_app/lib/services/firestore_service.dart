import 'package:cloud_firestore/cloud_firestore.dart';
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
            fromFirestore: (snapshot, _) => UserModel.fromFirestore(snapshot),
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
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final userData = {
        'id': userId,
        'email': email,
        'displayName': displayName ?? email.split('@')[0],
        'photoUrl': photoUrl,
        'username': username?.toLowerCase(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'credits': 100, // Starting credits for new users
        'followingTeams': [],
        'betIds': [],
        'notificationsEnabled': true,
        ...?additionalData,
      };

      // Remove null values
      userData.removeWhere((key, value) => value == null);

      await usersCollection.doc(userId).set(
            userData,
            SetOptions(merge: true),
          );
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
    return createUserProfile(
      userId: user.id,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      username: user.username,
      additionalData: user.toMap(),
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
    final betWithId = bet.copyWith(id: betRef.id);
    
    // Update user's credits
    final userRef = usersCollection.doc(bet.userId);
    
    // Add operations to batch
    batch.set(betRef, betWithId);
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
