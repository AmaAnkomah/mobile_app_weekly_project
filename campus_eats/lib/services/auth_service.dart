import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

/// Wraps Firebase Auth and creates the corresponding Firestore user document.
/// Authentication state is exposed via a stream so widgets reactively rebuild.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Auth State Stream ────────────────────────────────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // ── Sign Up ──────────────────────────────────────────────────────────────────
  /// Creates a Firebase Auth user then writes the users/{uid} Firestore document.
  /// isAdmin defaults to false — an existing admin must manually set isAdmin=true
  /// in Firestore console for the first admin account.
  Future<UserModel> signUp({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = credential.user!.uid;
    final userModel = UserModel(
      uid: uid,
      email: email.trim(),
      isAdmin: false,
      totalOrders: 0,
      createdAt: DateTime.now(),
    );
    // Persist to Firestore so security rules and role checks can read isAdmin
    await _db.collection(AppConstants.usersCollection).doc(uid).set(userModel.toMap());
    return userModel;
  }

  // ── Sign In ──────────────────────────────────────────────────────────────────
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = credential.user!.uid;
    final doc = await _db.collection(AppConstants.usersCollection).doc(uid).get();
    if (!doc.exists) {
      throw Exception('User profile not found. Please contact support.');
    }
    return UserModel.fromFirestore(doc);
  }

  // ── Sign Out ─────────────────────────────────────────────────────────────────
  Future<void> signOut() => _auth.signOut();

  // ── Fetch User Profile ───────────────────────────────────────────────────────
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection(AppConstants.usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  // ── Stream User (real-time profile updates) ──────────────────────────────────
  Stream<UserModel?> streamUser(String uid) => _db
      .collection(AppConstants.usersCollection)
      .doc(uid)
      .snapshots()
      .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
}
