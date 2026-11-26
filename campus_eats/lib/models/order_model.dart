import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_item_model.dart';

/// Represents a placed order.
/// Exists in TWO places:
///   1. users/{uid}/orders/{orderId}  — student can stream their own orders
///   2. orders/{orderId}              — admin global mirror, ordered by timestamp
///
/// WHY DENORMALISE INTO A GLOBAL COLLECTION?
/// Firestore does not support collection-group queries on subcollections by
/// default without a composite index that would couple admin queries to every
/// user's subcollection. The global mirror lets the admin screen do a simple
/// collectionGroup or top-level collection query, ordered by timestamp.
class OrderModel {
  final String id;
  final List<OrderItemModel> items;
  final double total;
  final String status;   // pending | preparing | ready | completed
  final DateTime timestamp;
  // Rating fields — set after order is completed (Advanced D)
  final int? rating;
  final String? ratingComment;
  final DateTime? ratedAt;
  // Present on global admin copy only
  final String? uid;
  final String? userEmail;

  const OrderModel({
    required this.id,
    required this.items,
    required this.total,
    required this.status,
    required this.timestamp,
    this.rating,
    this.ratingComment,
    this.ratedAt,
    this.uid,
    this.userEmail,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawItems = data['items'] as List<dynamic>? ?? [];
    return OrderModel(
      id:            doc.id,
      items:         rawItems
          .map((e) => OrderItemModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      total:         (data['total']  as num?)?.toDouble() ?? 0.0,
      status:        data['status']  as String?           ?? 'pending',
      timestamp:     (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      rating:        data['rating']  as int?,
      ratingComment: data['ratingComment'] as String?,
      ratedAt:       (data['ratedAt'] as Timestamp?)?.toDate(),
      uid:           data['uid']       as String?,
      userEmail:     data['userEmail'] as String?,
    );
  }

  bool get isRated => rating != null;
  bool get canRate => status == 'completed' && !isRated;
}
