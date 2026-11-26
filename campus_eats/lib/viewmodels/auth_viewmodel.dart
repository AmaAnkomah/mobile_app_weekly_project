import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Controls authentication state for the entire app.
/// Listens to Firebase Auth state stream so the router reacts automatically.
class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;

  AuthViewModel(this._authService) {
    // Subscribe to Firebase auth state — triggers route changes via Consumer
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;

  AuthStatus get status       => _status;
  UserModel? get user         => _user;
  String?    get errorMessage => _errorMessage;
  bool       get isAdmin      => _user?.isAdmin ?? false;
  bool       get isLoading    => _status == AuthStatus.loading;

  // ── Auth State Listener ──────────────────────────────────────────────────────
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    final User currentUser = firebaseUser; // Non-nullable local copy

    try {
      // Fetch Firestore profile to get isAdmin and other fields
      _user = await _authService.getUser(currentUser.uid);
      _status = AuthStatus.authenticated;
    } catch (e) {
      debugPrint('Auth State Error (Profile fetch failed): $e');
      // If profile fetch fails (e.g. permissions), fallback to a basic student profile
      _user = UserModel(
        uid: currentUser.uid,
        email: currentUser.email ?? '',
        isAdmin: currentUser.email == 'admin@gmail.com', // Demo admin check
        totalOrders: 0,
        createdAt: DateTime.now(),
      );
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  // ── Sign Up ──────────────────────────────────────────────────────────────────
  Future<bool> signUp({required String email, required String password}) async {
    _setLoading();
    try {
      _user = await _authService.signUp(email: email, password: password);
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_friendlyFirebaseError(e.code));
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── Sign In ──────────────────────────────────────────────────────────────────
  Future<bool> signIn({required String email, required String password}) async {
    _setLoading();
    try {
      // ── MOCK LOGIN FOR DEMO (Bypasses Firebase Auth) ──────────────────────────
      if (email.trim() == 'admin@gmail.com' && password == 'admin123') {
        _user = UserModel(
          uid: 'mock-admin-uid',
          email: 'admin@gmail.com',
          isAdmin: true,
          totalOrders: 0,
          createdAt: DateTime.now(),
        );
        _status = AuthStatus.authenticated;
        _errorMessage = null;
        notifyListeners();
        return true;
      }

      _user = await _authService.signIn(email: email, password: password);
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_friendlyFirebaseError(e.code));
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── Sign Out ─────────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Converts Firebase error codes to student-friendly messages
  String _friendlyFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use': return 'This email is already registered.';
      case 'wrong-password':       return 'Incorrect password. Please try again.';
      case 'user-not-found':       return 'No account found with this email.';
      case 'weak-password':        return 'Password is too weak (min 6 chars).';
      case 'invalid-email':        return 'Please enter a valid email address.';
      case 'too-many-requests':    return 'Too many attempts. Try again later.';
      default:                     return 'Authentication failed. Please try again.';
    }
  }
}
