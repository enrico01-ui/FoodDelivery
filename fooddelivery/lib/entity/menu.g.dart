// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MenuAdapter extends TypeAdapter<Menu> {
  @override
  final int typeId = 0;

  @override
  Menu read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Menu(
      item_id: fields[0] as int,
      restaurant_id: fields[1] as int,
      name: fields[2] as String,
      price: fields[3] as int,
      type: fields[6] as String,
      description: fields[7] as String,
      image_url: fields[8] as String,
      restaurant: fields[9] as Restaurant,
      totalPrice: fields[4] as int?,
      totalCount: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Menu obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.item_id)
      ..writeByte(1)
      ..write(obj.restaurant_id)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.totalPrice)
      ..writeByte(5)
      ..write(obj.totalCount)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.image_url)
      ..writeByte(9)
      ..write(obj.restaurant);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
