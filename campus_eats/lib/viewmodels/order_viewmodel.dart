import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../services/firestore_service.dart';

/// Handles placing orders and rating — both use Firestore transactions.
class OrderViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;

  OrderViewModel(this._firestoreService);

  bool    _isLoading    = false;
  String? _errorMessage;
  bool    _orderSuccess = false;

  bool    get isLoading    => _isLoading;
  String? get errorMessage => _errorMessage;
  bool    get orderSuccess => _orderSuccess;

  // ── Place Order ───────────────────────────────────────────────────────────────
  /// Returns true on success. On stock failure the error message is set
  /// and the ViewModel stays in error state until clearError() is called.
  Future<bool> placeOrder({
    required String uid,
    required String email,
    required List<CartItemModel> cartItems,
  }) async {
    _isLoading = true;
    _orderSuccess = false;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.placeOrder(
        uid: uid,
        email: email,
        cartItems: cartItems,
      );
      _orderSuccess = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Rate Order (Advanced D) ──────────────────────────────────────────────────
  Future<bool> rateOrder({
    required String uid,
    required String orderId,
    required String primaryItemId,
    required int rating,
    required String comment,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.rateOrder(
        uid: uid,
        orderId: orderId,
        primaryItemId: primaryItemId,
        rating: rating,
        comment: comment,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to submit rating: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void resetSuccess() {
    _orderSuccess = false;
    notifyListeners();
  }
}
