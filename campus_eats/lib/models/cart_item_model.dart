import 'package:hive_flutter/hive_flutter.dart';

/// Cart item stored locally in Hive — persists across app restarts and works offline.
///
/// WHY HIVE INSTEAD OF FIRESTORE FOR CART?
/// The cart is a local, ephemeral concept. Syncing it to Firestore on every
/// quantity change would be expensive and brittle offline. Hive gives us fast
/// O(1) reads with full offline support, and we only write to Firestore when
/// the user actually places an order (via a transaction).
///
/// TypeId 0 is registered in main.dart before runApp.
part 'cart_item_model.g.dart';

@HiveType(typeId: 0)
class CartItemModel extends HiveObject {
  @HiveField(0)
  String itemId;

  @HiveField(1)
  String name;

  @HiveField(2)
  double price;

  @HiveField(3)
  int quantity;

  @HiveField(4)
  String imageUrl;

  /// Max available stock — used to cap quantity increments in the cart UI
  @HiveField(5)
  int stock;

  CartItemModel({
    required this.itemId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.stock,
  });

  double get subtotal => price * quantity;
}
