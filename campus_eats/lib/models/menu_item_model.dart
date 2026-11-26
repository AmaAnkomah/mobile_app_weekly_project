import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single cafeteria menu item.
/// Stored in Firestore under the menu/{itemId} collection.
class MenuItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;   // "Breakfast" | "Lunch" | "Snacks"
  final String imageUrl;   // Firebase Storage download URL
  final int stock;
  // Rating fields — updated atomically via Firestore transactions (Advanced D)
  final double totalRating;
  final int ratingCount;
  final double averageRating;
  final DateTime createdAt;

  const MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.stock,
    required this.totalRating,
    required this.ratingCount,
    required this.averageRating,
    required this.createdAt,
  });

  factory MenuItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MenuItemModel.fromMap(data, doc.id);
  }

  factory MenuItemModel.fromMap(Map<String, dynamic> data, String id) {
    return MenuItemModel(
      id:            id,
      name:          data['name']          as String?  ?? '',
      description:   data['description']   as String?  ?? '',
      price:         (data['price']         as num?)?.toDouble() ?? 0.0,
      category:      data['category']       as String?  ?? 'Snacks',
      imageUrl:      data['imageUrl']       as String?  ?? '',
      stock:         data['stock']          as int?     ?? 0,
      totalRating:   (data['totalRating']   as num?)?.toDouble() ?? 0.0,
      ratingCount:   data['ratingCount']    as int?     ?? 0,
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
      createdAt:     data['createdAt'] is Timestamp 
          ? (data['createdAt'] as Timestamp).toDate() 
          : (data['createdAt'] is DateTime ? data['createdAt'] as DateTime : DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() => {
    'name':          name,
    'description':   description,
    'price':         price,
    'category':      category,
    'imageUrl':      imageUrl,
    'stock':         stock,
    'totalRating':   totalRating,
    'ratingCount':   ratingCount,
    'averageRating': averageRating,
    'createdAt':     FieldValue.serverTimestamp(),
  };

  MenuItemModel copyWith({
    String? id, String? name, String? description, double? price,
    String? category, String? imageUrl, int? stock,
    double? totalRating, int? ratingCount, double? averageRating,
    DateTime? createdAt,
  }) => MenuItemModel(
    id:            id            ?? this.id,
    name:          name          ?? this.name,
    description:   description   ?? this.description,
    price:         price         ?? this.price,
    category:      category      ?? this.category,
    imageUrl:      imageUrl      ?? this.imageUrl,
    stock:         stock         ?? this.stock,
    totalRating:   totalRating   ?? this.totalRating,
    ratingCount:   ratingCount   ?? this.ratingCount,
    averageRating: averageRating ?? this.averageRating,
    createdAt:     createdAt     ?? this.createdAt,
  );

  /// True when stock is at or below the alert threshold (Advanced E)
  bool get isLowStock => stock <= 5 && stock > 0;
  bool get isOutOfStock => stock <= 0;
}
