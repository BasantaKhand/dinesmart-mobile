import 'package:hive/hive.dart';
import 'package:dinesmart_app/core/constants/hive_box_constants.dart';
import '../../domain/entities/table_entity.dart';

part 'table_hive_model.g.dart';

@HiveType(typeId: HiveBoxConstants.tableTypeId)
class TableHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String number;

  @HiveField(2)
  final int capacity;

  @HiveField(3)
  final int statusIndex;

  TableHiveModel({
    required this.id,
    required this.number,
    required this.capacity,
    required this.statusIndex,
  });

  TableEntity toEntity() {
    return TableEntity(
      id: id,
      number: number,
      capacity: capacity,
      status: TableStatus.values[statusIndex],
    );
  }

  factory TableHiveModel.fromEntity(TableEntity entity) {
    return TableHiveModel(
      id: entity.id,
      number: entity.number,
      capacity: entity.capacity,
      statusIndex: entity.status.index,
    );
  }

  static List<TableEntity> toEntityList(List<TableHiveModel> models) {
    return models.map((m) => m.toEntity()).toList();
  }

  static List<TableHiveModel> fromEntityList(List<TableEntity> entities) {
    return entities.map((e) => TableHiveModel.fromEntity(e)).toList();
  }
}
