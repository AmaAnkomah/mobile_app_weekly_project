import 'package:flutter/foundation.dart';
import '../models/menu_item_model.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';

/// Admin-only ViewModel: menu CRUD + order status management.
class AdminViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;

  AdminViewModel(this._firestoreService);

  bool    _isLoading    = false;
  String? _errorMessage;

  bool    get isLoading    => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── Streams (Delegated to FirestoreService) ─────────────────────────────────
  
  Stream<List<MenuItemModel>> streamMenu() => _firestoreService.streamMenu();
  
  Stream<List<OrderModel>> streamAllOrders() => _firestoreService.streamAllOrders();

  // ── Menu CRUD ─────────────────────────────────────────────────────────────────

  Future<void> addItem(MenuItemModel item) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.addMenuItem(item);
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.updateMenuItem(id, data);
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.deleteMenuItem(id);
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  // ── Order Management ─────────────────────────────────────────────────────────

  Future<void> updateStatus(String orderId, String uid, String newStatus) async {
    try {
      await _firestoreService.updateOrderStatus(
        orderId: orderId,
        uid: uid,
        newStatus: newStatus,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
