import 'package:hive/hive.dart';
import 'package:dinesmart_app/core/constants/hive_box_constants.dart';
import '../../domain/entities/category_entity.dart';

part 'category_hive_model.g.dart';

@HiveType(typeId: HiveBoxConstants.categoryTypeId)
class CategoryHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? image;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final int? itemCount;

  CategoryHiveModel({
    required this.id,
    required this.name,
    this.image,
    this.description,
    this.itemCount,
  });

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      image: image,
      description: description,
      itemCount: itemCount,
    );
  }

  factory CategoryHiveModel.fromEntity(CategoryEntity entity) {
    return CategoryHiveModel(
      id: entity.id,
      name: entity.name,
      image: entity.image,
      description: entity.description,
      itemCount: entity.itemCount,
    );
  }

  static List<CategoryEntity> toEntityList(List<CategoryHiveModel> models) {
    return models.map((m) => m.toEntity()).toList();
  }

  static List<CategoryHiveModel> fromEntityList(List<CategoryEntity> entities) {
    return entities.map((e) => CategoryHiveModel.fromEntity(e)).toList();
  }
}
