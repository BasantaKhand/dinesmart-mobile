// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TableHiveModelAdapter extends TypeAdapter<TableHiveModel> {
  @override
  final int typeId = 4;

  @override
  TableHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TableHiveModel(
      id: fields[0] as String,
      number: fields[1] as String,
      capacity: fields[2] as int,
      statusIndex: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TableHiveModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.number)
      ..writeByte(2)
      ..write(obj.capacity)
      ..writeByte(3)
      ..write(obj.statusIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
