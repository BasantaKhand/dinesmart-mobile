import 'package:equatable/equatable.dart';

enum TableStatus { AVAILABLE, OCCUPIED, RESERVED }

class TableEntity extends Equatable {
  final String id;
  final String number;
  final int capacity;
  final TableStatus status;

  const TableEntity({
    required this.id,
    required this.number,
    required this.capacity,
    required this.status,
  });

  @override
  List<Object?> get props => [id, number, capacity, status];
}
