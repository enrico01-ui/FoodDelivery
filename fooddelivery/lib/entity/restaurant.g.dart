// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RestaurantAdapter extends TypeAdapter<Restaurant> {
  @override
  final int typeId = 1;

  @override
  Restaurant read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Restaurant(
      id: fields[0] as int,
      name: fields[1] as String,
      address: fields[2] as String,
      phone_number: fields[3] as String,
      description: fields[4] as String,
      logo_url: fields[5] as String,
      rating: fields[6] as int,
      openTime: fields[7] as String,
      closeTime: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Restaurant obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.phone_number)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.logo_url)
      ..writeByte(6)
      ..write(obj.rating)
      ..writeByte(7)
      ..write(obj.openTime)
      ..writeByte(8)
      ..write(obj.closeTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RestaurantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
