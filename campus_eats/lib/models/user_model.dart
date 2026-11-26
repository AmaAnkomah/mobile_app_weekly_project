import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a registered user (student or admin).
/// Stored in Firestore under users/{uid}.
class UserModel {
  final String uid;
  final String email;
  final bool isAdmin;
  final int totalOrders;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.isAdmin,
    required this.totalOrders,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      isAdmin: data['isAdmin'] as bool? ?? false,
      totalOrders: data['totalOrders'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'email': email,
    'isAdmin': isAdmin,
    'totalOrders': totalOrders,
    'createdAt': FieldValue.serverTimestamp(),
  };

  UserModel copyWith({
    String? uid,
    String? email,
    bool? isAdmin,
    int? totalOrders,
    DateTime? createdAt,
  }) => UserModel(
    uid: uid ?? this.uid,
    email: email ?? this.email,
    isAdmin: isAdmin ?? this.isAdmin,
    totalOrders: totalOrders ?? this.totalOrders,
    createdAt: createdAt ?? this.createdAt,
  );
}
