// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_operation_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingOperationHiveModelAdapter
    extends TypeAdapter<PendingOperationHiveModel> {
  @override
  final int typeId = 7;

  @override
  PendingOperationHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingOperationHiveModel(
      id: fields[0] as String,
      operationTypeIndex: fields[1] as int,
      payload: fields[2] as String,
      createdAt: fields[3] as DateTime,
      retryCount: fields[4] as int,
      relatedEntityId: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PendingOperationHiveModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.operationTypeIndex)
      ..writeByte(2)
      ..write(obj.payload)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.retryCount)
      ..writeByte(5)
      ..write(obj.relatedEntityId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingOperationHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
