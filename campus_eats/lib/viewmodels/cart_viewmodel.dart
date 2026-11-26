import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../services/cart_service.dart';

/// Manages local Hive cart — exposes list, total, and count to the UI.
/// All writes go through CartService; ViewModel keeps an in-memory cache
/// and notifies listeners after every mutation.
class CartViewModel extends ChangeNotifier {
  final CartService _cartService;

  CartViewModel(this._cartService) {
    _loadFromHive();
  }

  List<CartItemModel> _items = [];

  List<CartItemModel> get items      => _items;
  double             get total       => _cartService.total;
  int                get itemCount   => _cartService.itemCount;
  bool               get isEmpty     => _items.isEmpty;

  // ── Load ─────────────────────────────────────────────────────────────────────
  void _loadFromHive() {
    _items = _cartService.getAll();
    notifyListeners();
  }

  // ── Add to Cart ───────────────────────────────────────────────────────────────
  Future<void> addItem(CartItemModel item) async {
    await _cartService.addItem(item);
    _loadFromHive();
  }

  // ── Update Quantity ───────────────────────────────────────────────────────────
  Future<void> updateQuantity(String itemId, int quantity) async {
    await _cartService.updateQuantity(itemId, quantity);
    _loadFromHive();
  }

  // ── Remove Item ───────────────────────────────────────────────────────────────
  Future<void> removeItem(String itemId) async {
    await _cartService.removeItem(itemId);
    _loadFromHive();
  }

  // ── Clear Cart ────────────────────────────────────────────────────────────────
  Future<void> clearCart() async {
    await _cartService.clearCart();
    _loadFromHive();
  }

  // ── Cart badge count for bottom nav indicator ─────────────────────────────────
  bool containsItem(String itemId) => _items.any((e) => e.itemId == itemId);
}
