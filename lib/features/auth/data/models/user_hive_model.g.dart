// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserHiveModelAdapter extends TypeAdapter<UserHiveModel> {
  @override
  final int typeId = 1;

  @override
  UserHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserHiveModel(
      id: fields[0] as String,
      email: fields[1] as String,
      fullName: fields[2] as String,
      username: fields[3] as String,
      role: fields[4] as String,
      restaurantId: fields[5] as String?,
      phoneNumber: fields[6] as String?,
      profilePicture: fields[7] as String?,
      lastUpdated: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserHiveModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.fullName)
      ..writeByte(3)
      ..write(obj.username)
      ..writeByte(4)
      ..write(obj.role)
      ..writeByte(5)
      ..write(obj.restaurantId)
      ..writeByte(6)
      ..write(obj.phoneNumber)
      ..writeByte(7)
      ..write(obj.profilePicture)
      ..writeByte(8)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
