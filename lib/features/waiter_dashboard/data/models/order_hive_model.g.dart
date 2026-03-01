// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderHiveModelAdapter extends TypeAdapter<OrderHiveModel> {
  @override
  final int typeId = 5;

  @override
  OrderHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderHiveModel(
      id: fields[0] as String,
      tableId: fields[1] as String,
      tableNumber: fields[2] as String?,
      waiterName: fields[3] as String?,
      items: (fields[4] as List).cast<OrderItemHiveModel>(),
      statusIndex: fields[5] as int,
      subtotal: fields[6] as double,
      tax: fields[7] as double,
      vat: fields[8] as double,
      total: fields[9] as double,
      notes: fields[10] as String?,
      paymentMethod: fields[11] as String?,
      transactionId: fields[12] as String?,
      createdAt: fields[13] as DateTime?,
      isPending: fields[14] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, OrderHiveModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tableId)
      ..writeByte(2)
      ..write(obj.tableNumber)
      ..writeByte(3)
      ..write(obj.waiterName)
      ..writeByte(4)
      ..write(obj.items)
      ..writeByte(5)
      ..write(obj.statusIndex)
      ..writeByte(6)
      ..write(obj.subtotal)
      ..writeByte(7)
      ..write(obj.tax)
      ..writeByte(8)
      ..write(obj.vat)
      ..writeByte(9)
      ..write(obj.total)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.paymentMethod)
      ..writeByte(12)
      ..write(obj.transactionId)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.isPending);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OrderItemHiveModelAdapter extends TypeAdapter<OrderItemHiveModel> {
  @override
  final int typeId = 6;

  @override
  OrderItemHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderItemHiveModel(
      menuItemId: fields[0] as String,
      imageUrl: fields[1] as String?,
      name: fields[2] as String,
      price: fields[3] as double,
      quantity: fields[4] as int,
      total: fields[5] as double,
      status: fields[6] as String?,
      notes: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OrderItemHiveModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.menuItemId)
      ..writeByte(1)
      ..write(obj.imageUrl)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.total)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItemHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
