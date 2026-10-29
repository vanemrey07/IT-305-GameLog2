import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gamelog/game_model.dart';

class FirebaseService {
  FirebaseService._internal();

  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() => _instance;

  bool _isReady = false;

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  bool get isReady => _isReady;
  String? get currentUserId => _isReady ? _auth.currentUser?.uid : null;

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _isReady = true;
    } catch (_) {
      _isReady = false;
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    if (!_isReady) {
      return true;
    }

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> registerWithEmail(String email, String password) async {
    if (!_isReady) {
      return true;
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> signOut() async {
    if (_isReady) {
      await _auth.signOut();
    }
  }

  Future<void> saveGamesToCloud(String? uid, List<GameEntry> games) async {
    if (!_isReady || uid == null || uid.isEmpty) {
      return;
    }

    try {
      await _firestore.collection('users').doc(uid).set({
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('games')
          .doc('library')
          .set({
            'games': games.map((game) => game.toJson()).toList(),
          }, SetOptions(merge: true));
    } catch (_) {
      // Gracefully fail when Firebase is not configured or unavailable.
    }
  }

  Future<List<GameEntry>> loadGamesFromCloud(String? uid) async {
    if (!_isReady || uid == null || uid.isEmpty) {
      return const [];
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('games')
          .doc('library')
          .get();

      final data = snapshot.data();
      final rawGames = data?['games'] as List? ?? const [];

      return rawGames
          .map((game) => GameEntry.fromJson(Map<String, dynamic>.from(game)))
          .toList();
    } catch (_) {
      return const [];
    }
  }
}
