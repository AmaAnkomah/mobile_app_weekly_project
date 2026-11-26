import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item_model.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

/// Core Firestore operations.
///
/// KEY DESIGN DECISIONS:
/// 1. Menu items are a top-level collection for fast reads with no auth required.
/// 2. Orders live in TWO places: users/{uid}/orders (student view) and
///    orders (admin view). This avoids expensive collection-group indexes.
/// 3. Stock check + decrement + order creation all happen atomically in a single
///    Firestore transaction preventing race conditions (e.g., two students buying
///    the last item simultaneously).
/// 4. Rating aggregation uses a transaction to read–modify–write totalRating and
///    ratingCount atomically, which prevents lost-update races.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ══════════════════════════════════════════════════════
  // MENU
  // ══════════════════════════════════════════════════════

  /// Real-time stream of every menu item, sorted by category then name.
  Stream<List<MenuItemModel>> streamMenu() => _db
      .collection(AppConstants.menuCollection)
      .orderBy('category')
      .snapshots()
      .map((snap) => snap.docs.map(MenuItemModel.fromFirestore).toList());

  Future<void> addMenuItem(MenuItemModel item) =>
      _db.collection(AppConstants.menuCollection).add(item.toMap());

  Future<void> updateMenuItem(String id, Map<String, dynamic> data) =>
      _db.collection(AppConstants.menuCollection).doc(id).update(data);

  Future<void> deleteMenuItem(String id) =>
      _db.collection(AppConstants.menuCollection).doc(id).delete();

  // ══════════════════════════════════════════════════════
  // ORDERS — Place Order (Critical Transaction)
  // ══════════════════════════════════════════════════════

  /// Atomically:
  ///   1. Reads current stock for all cart items.
  ///   2. Throws if any item has insufficient stock (rolls back entire transaction).
  ///   3. Decrements stock for each item.
  ///   4. Creates order in users/{uid}/orders AND global orders collection.
  ///   5. Increments user's totalOrders counter.
  ///
  /// WHY A TRANSACTION?
  /// Without a transaction, two concurrent orders could both pass the stock check
  /// and both decrement, leaving stock at -N. Firestore transactions serialise the
  /// read-check-write sequence, guaranteeing consistency.
  Future<void> placeOrder({
    required String uid,
    required String email,
    required List<CartItemModel> cartItems,
  }) async {
    // Pre-compute document references outside the transaction closure
    final menuRefs = cartItems
        .map((c) => _db.collection(AppConstants.menuCollection).doc(c.itemId))
        .toList();

    // Use a pre-generated ID so the same ID lands in both collections atomically
    final orderId = _db.collection(AppConstants.ordersCollection).doc().id;
    final globalOrderRef = _db.collection(AppConstants.ordersCollection).doc(orderId);
    final userOrderRef = _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection(AppConstants.userOrdersSub)
        .doc(orderId);
    final userRef = _db.collection(AppConstants.usersCollection).doc(uid);

    await _db.runTransaction((tx) async {
      // ── Step 1: Read all menu docs inside the transaction ─────────────────────
      // Firestore requires all reads to happen before writes in a transaction.
      final menuSnaps = await Future.wait(menuRefs.map(tx.get));

      // ── Step 2: Stock validation ───────────────────────────────────────────────
      for (int i = 0; i < cartItems.length; i++) {
        final item = cartItems[i];
        final currentStock = menuSnaps[i].data()?['stock'] as int? ?? 0;
        if (currentStock < item.quantity) {
          // Throwing inside a transaction automatically rolls it back
          throw Exception(
            '"${item.name}" only has $currentStock left in stock '
            'but you requested ${item.quantity}. Please adjust your cart.',
          );
        }
      }

      // ── Step 3 & 4: Build order document and write atomically ─────────────────
      final orderItems = cartItems.map((c) => {
        'itemId':   c.itemId,
        'name':     c.name,
        'price':    c.price,
        'quantity': c.quantity,
        'subtotal': c.subtotal,
      }).toList();

      final total = cartItems.fold<double>(0, (sum, c) => sum + c.subtotal);

      final orderData = {
        'uid':       uid,
        'userEmail': email,
        'items':     orderItems,
        'total':     total,
        'status':    AppConstants.statusPending,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Decrement stock for every item
      for (int i = 0; i < cartItems.length; i++) {
        tx.update(menuRefs[i], {
          'stock': FieldValue.increment(-cartItems[i].quantity),
        });
      }

      // Write order to both collections (student + admin views)
      tx.set(globalOrderRef, orderData);
      tx.set(userOrderRef, orderData);

      // Increment user's total order count
      tx.update(userRef, {'totalOrders': FieldValue.increment(1)});
    });
  }

  // ══════════════════════════════════════════════════════
  // ORDER HISTORY — Student View
  // ══════════════════════════════════════════════════════

  /// Real-time stream of a student's own orders, newest first.
  Stream<List<OrderModel>> streamUserOrders(String uid) => _db
      .collection(AppConstants.usersCollection)
      .doc(uid)
      .collection(AppConstants.userOrdersSub)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(OrderModel.fromFirestore).toList());

  // ══════════════════════════════════════════════════════
  // ORDER MANAGEMENT — Admin View
  // ══════════════════════════════════════════════════════

  /// Real-time stream of ALL orders (global collection), pending first.
  Stream<List<OrderModel>> streamAllOrders() => _db
      .collection(AppConstants.ordersCollection)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(OrderModel.fromFirestore).toList());

  /// Admin updates order status.
  /// Updates BOTH global orders collection AND the user's subcollection
  /// so the student's real-time stream immediately reflects the change.
  Future<void> updateOrderStatus({
    required String orderId,
    required String uid,   // needed to locate users/{uid}/orders/{orderId}
    required String newStatus,
  }) async {
    final batch = _db.batch();
    final globalRef = _db.collection(AppConstants.ordersCollection).doc(orderId);
    final userRef = _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection(AppConstants.userOrdersSub)
        .doc(orderId);

    batch.update(globalRef, {'status': newStatus});
    batch.update(userRef, {'status': newStatus});
    await batch.commit();
  }

  // ══════════════════════════════════════════════════════
  // RATING — Advanced Feature D
  // ══════════════════════════════════════════════════════

  /// Student rates a completed order.
  ///
  /// Uses a transaction to atomically update the menu item's running totals,
  /// preventing race conditions when multiple students rate almost simultaneously.
  ///
  /// Rating aggregation strategy:
  ///   newAverage = (totalRating + newRating) / (ratingCount + 1)
  /// We store totalRating and ratingCount to allow correct re-computation without
  /// needing to re-read all individual ratings.
  Future<void> rateOrder({
    required String uid,
    required String orderId,
    required String primaryItemId, // Rate based on first item in the order
    required int rating,
    required String comment,
  }) async {
    final menuRef = _db.collection(AppConstants.menuCollection).doc(primaryItemId);
    final userOrderRef = _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection(AppConstants.userOrdersSub)
        .doc(orderId);
    final globalOrderRef = _db.collection(AppConstants.ordersCollection).doc(orderId);

    await _db.runTransaction((tx) async {
      final menuSnap = await tx.get(menuRef);
      final currentTotal = (menuSnap.data()?['totalRating'] as num?)?.toDouble() ?? 0.0;
      final currentCount = (menuSnap.data()?['ratingCount'] as int?) ?? 0;

      final newTotal   = currentTotal + rating;
      final newCount   = currentCount + 1;
      final newAverage = newTotal / newCount;

      tx.update(menuRef, {
        'totalRating':   newTotal,
        'ratingCount':   newCount,
        'averageRating': newAverage,
      });

      final ratingData = {
        'rating':        rating,
        'ratingComment': comment,
        'ratedAt':       FieldValue.serverTimestamp(),
      };
      tx.update(userOrderRef, ratingData);
      tx.update(globalOrderRef, ratingData);
    });
  }

  // ══════════════════════════════════════════════════════
  // USER PROFILE
  // ══════════════════════════════════════════════════════

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection(AppConstants.usersCollection).doc(uid).get();
    return doc.exists ? UserModel.fromFirestore(doc) : null;
  }

  Stream<UserModel?> streamUser(String uid) => _db
      .collection(AppConstants.usersCollection)
      .doc(uid)
      .snapshots()
      .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);

  // ══════════════════════════════════════════════════════
  // SEED DATA
  // ══════════════════════════════════════════════════════

  Future<void> seedDatabase() async {
    final menuCol = _db.collection(AppConstants.menuCollection);
    final snapshot = await menuCol.limit(1).get();
    
    if (snapshot.docs.isNotEmpty) return; // Already seeded

    final items = [
      {
        'name': 'VVU Special Jollof',
        'description': 'Traditional Ghanaian Jollof rice served with grilled chicken, salad, and shito.',
        'price': 45.0,
        'category': 'Lunch',
        'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/campus-connect-ba9ef.firebasestorage.app/o/placeholders%2Fjollof.jpg?alt=media',
        'stock': 15,
        'totalRating': 0.0,
        'ratingCount': 0,
        'averageRating': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Ghanian Waakye',
        'description': 'Rice and beans served with wele, egg, fish, and spaghetti.',
        'price': 35.0,
        'category': 'Lunch',
        'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/campus-connect-ba9ef.firebasestorage.app/o/placeholders%2Fwaakye.jpg?alt=media',
        'stock': 10,
        'totalRating': 0.0,
        'ratingCount': 0,
        'averageRating': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Egg & Sausage Sandwich',
        'description': 'Freshly baked bread with fried eggs, sausages, and vegetables.',
        'price': 25.0,
        'category': 'Breakfast',
        'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/campus-connect-ba9ef.firebasestorage.app/o/placeholders%2Fsandwich.jpg?alt=media',
        'stock': 4,
        'totalRating': 0.0,
        'ratingCount': 0,
        'averageRating': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Plantain Chips',
        'description': 'Crunchy and sweet ripe plantain chips.',
        'price': 10.0,
        'category': 'Snacks',
        'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/campus-connect-ba9ef.firebasestorage.app/o/placeholders%2Fchips.jpg?alt=media',
        'stock': 50,
        'totalRating': 0.0,
        'ratingCount': 0,
        'averageRating': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var item in items) {
      await menuCol.add(item);
    }
  }
}
