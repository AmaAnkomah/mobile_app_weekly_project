/// A single line-item inside an order.
/// Stored as a map list inside the order document (no separate subcollection needed).
class OrderItemModel {
  final String itemId;
  final String name;
  final double price;
  final int quantity;
  final double subtotal;

  const OrderItemModel({
    required this.itemId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) => OrderItemModel(
    itemId:   map['itemId']   as String?  ?? '',
    name:     map['name']     as String?  ?? '',
    price:    (map['price']   as num?)?.toDouble() ?? 0.0,
    quantity: map['quantity'] as int?     ?? 1,
    subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toMap() => {
    'itemId':   itemId,
    'name':     name,
    'price':    price,
    'quantity': quantity,
    'subtotal': subtotal,
  };
}
