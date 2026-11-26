import 'package:hive_flutter/hive_flutter.dart';
import '../models/cart_item_model.dart';
import '../utils/constants.dart';

/// Manages the local Hive cart box.
///
/// WHY HIVE FOR CART?
/// The cart is a purely local concern — there is no need to sync every
/// quantity change to the cloud. Hive provides:
///   • O(1) key-based reads (itemId is the box key)
///   • Full offline support
///   • Persistence across app restarts
/// We only write to Firestore when the user explicitly places an order.
class CartService {
  Future<void> init() async {
    await Hive.openBox<CartItemModel>(AppConstants.cartBox);
  }

  Box<CartItemModel> get _box => Hive.box<CartItemModel>(AppConstants.cartBox);

  List<CartItemModel> getAll() => _box.values.toList();

  CartItemModel? getItem(String itemId) => _box.get(itemId);

  /// Adds a new item or increments quantity if already in cart.
  Future<void> addItem(CartItemModel item) async {
    final existing = _box.get(item.itemId);
    if (existing != null) {
      // Respect stock ceiling so cart can't exceed available inventory
      final newQty = (existing.quantity + item.quantity).clamp(1, item.stock);
      existing.quantity = newQty;
      await existing.save();
    } else {
      // Use itemId as key so duplicate prevention is O(1)
      await _box.put(item.itemId, item);
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    final item = _box.get(itemId);
    if (item == null) return;
    if (quantity <= 0) {
      await item.delete();
    } else {
      item.quantity = quantity.clamp(1, item.stock);
      await item.save();
    }
  }

  Future<void> removeItem(String itemId) async {
    await _box.delete(itemId);
  }

  Future<void> clearCart() async => _box.clear();

  double get total =>
      _box.values.fold(0, (sum, item) => sum + item.subtotal);

  int get itemCount =>
      _box.values.fold(0, (sum, item) => sum + item.quantity);
}
