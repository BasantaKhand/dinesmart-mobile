// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MenuItemHiveModelAdapter extends TypeAdapter<MenuItemHiveModel> {
  @override
  final int typeId = 3;

  @override
  MenuItemHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MenuItemHiveModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      image: fields[3] as String?,
      price: fields[4] as double,
      originalPrice: fields[5] as double?,
      categoryId: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MenuItemHiveModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.image)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.originalPrice)
      ..writeByte(6)
      ..write(obj.categoryId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuItemHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
