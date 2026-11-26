// GENERATED CODE - DO NOT MODIFY BY HAND
// Manually written TypeAdapter for CartItemModel (avoids build_runner dependency)
// Mirrors what hive_generator would produce.

part of 'cart_item_model.dart';

class CartItemModelAdapter extends TypeAdapter<CartItemModel> {
  @override
  final int typeId = 0;

  @override
  CartItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartItemModel(
      itemId:   fields[0] as String,
      name:     fields[1] as String,
      price:    fields[2] as double,
      quantity: fields[3] as int,
      imageUrl: fields[4] as String,
      stock:    fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CartItemModel obj) {
    writer
      ..writeByte(6)      // total number of fields
      ..writeByte(0) ..write(obj.itemId)
      ..writeByte(1) ..write(obj.name)
      ..writeByte(2) ..write(obj.price)
      ..writeByte(3) ..write(obj.quantity)
      ..writeByte(4) ..write(obj.imageUrl)
      ..writeByte(5) ..write(obj.stock);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemModelAdapter && runtimeType == other.runtimeType && typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
