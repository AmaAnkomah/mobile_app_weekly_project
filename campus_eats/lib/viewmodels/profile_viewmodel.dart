import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

/// Manages the current user's profile data for the Profile screen.
class ProfileViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;

  ProfileViewModel(this._firestoreService);

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user         => _user;
  bool       get isLoading    => _isLoading;
  String?    get errorMessage => _errorMessage;

  /// Returns a live stream so total orders badge updates in real time
  Stream<UserModel?> streamUser(String uid) =>
      _firestoreService.streamUser(uid);

  Future<void> loadUser(String uid) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _firestoreService.getUser(uid);
    } catch (e) {
      _errorMessage = 'Failed to load profile.';
    }
    _isLoading = false;
    notifyListeners();
  }
}
