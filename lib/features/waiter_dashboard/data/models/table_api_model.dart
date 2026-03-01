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
      if (number.isNotEmpty) 'number': number,
      'capacity': capacity,
      'status': status,
    };
  }

  factory TableApiModel.fromEntity(TableEntity entity) {
    return TableApiModel(
      id: entity.id,
      number: entity.number,
      capacity: entity.capacity,
      status: _toApiStatus(entity.status),
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
        return TableStatus.occupied;
      case 'RESERVED':
        return TableStatus.reserved;
      default:
        return TableStatus.available;
    }
  }

  static String _toApiStatus(TableStatus status) {
    switch (status) {
      case TableStatus.occupied:
        return 'OCCUPIED';
      case TableStatus.reserved:
        return 'RESERVED';
      case TableStatus.available:
        return 'AVAILABLE';
    }
  }
}
