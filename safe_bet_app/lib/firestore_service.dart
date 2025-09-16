import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // USERS
  Stream<UserProfile> streamUser(String userId) {
    return _db.collection('users').doc(userId).snapshots().map(
      (snap) => UserProfile.fromJson(snap.id, snap.data()!),
    );
  }

  Future<void> createUser(UserProfile user) {
    return _db.collection('users').doc(user.id).set(user.toJson());
  }

  // TEAMS
  Stream<List<Team>> streamTeams() {
    return _db.collection('teams').snapshots().map((snap) =>
      snap.docs.map((doc) => Team.fromJson(doc.id, doc.data())).toList()
    );
  }

  // ATHLETES
  Stream<List<Athlete>> streamAthletes() {
    return _db.collection('athletes').snapshots().map((snap) =>
      snap.docs.map((doc) => Athlete.fromJson(doc.id, doc.data())).toList()
    );
  }

  // CHALLENGES
  Stream<List<Challenge>> streamOngoingChallenges() {
    return _db.collection('challenges')
      .where('status', isEqualTo: 'ongoing')
      .orderBy('startTime', descending: false)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => Challenge.fromJson(doc.id, doc.data())).toList());
  }

  // BETS
  Stream<List<Bet>> streamUserBets(String userId) {
    return _db.collection('bets').where('userId', isEqualTo: userId)
      .orderBy('placedAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => Bet.fromJson(doc.id, doc.data())).toList());
  }

  Future<void> placeBet(Bet bet) {
    return _db.collection('bets').doc(bet.id).set(bet.toJson());
  }

  // Trending teams & athletes
  Stream<List<Team>> streamTrendingTeams() {
    return _db.collection('teams').orderBy('trendingScore', descending: true).limit(5)
      .snapshots().map((snap) => snap.docs.map((doc) => Team.fromJson(doc.id, doc.data())).toList());
  }
  Stream<List<Athlete>> streamTrendingAthletes() {
    return _db.collection('athletes').orderBy('trendingScore', descending: true).limit(5)
      .snapshots().map((snap) => snap.docs.map((doc) => Athlete.fromJson(doc.id, doc.data())).toList());
  }
}
