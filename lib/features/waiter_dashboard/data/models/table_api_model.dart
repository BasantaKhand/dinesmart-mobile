import '../../domain/entities/table_entity.dart';

class TableApiModel {
  final String id;
  final String number;
  final int capacity;
  final String status;

  TableApiModel({
    required this.id,
    required this.number,
    required this.capacity,
    required this.status,
  });

  factory TableApiModel.fromJson(Map<String, dynamic> json) {
    return TableApiModel(
      id: json['_id'],
      number: json['number'],
      capacity: json['capacity'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'capacity': capacity,
      'status': status,
    };
  }

  factory TableApiModel.fromEntity(TableEntity entity) {
    return TableApiModel(
      id: entity.id,
      number: entity.number,
      capacity: entity.capacity,
      status: entity.status.name,
    );
  }

  TableEntity toEntity() {
    return TableEntity(
      id: id,
      number: number,
      capacity: capacity,
      status: _mapStatus(status),
    );
  }

  static TableStatus _mapStatus(String status) {
    switch (status) {
      case 'OCCUPIED':
        return TableStatus.OCCUPIED;
      case 'RESERVED':
        return TableStatus.RESERVED;
      default:
        return TableStatus.AVAILABLE;
    }
  }
}
