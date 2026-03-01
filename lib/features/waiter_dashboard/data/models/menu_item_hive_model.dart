import 'package:hive/hive.dart';
import 'package:dinesmart_app/core/constants/hive_box_constants.dart';
import '../../domain/entities/menu_item_entity.dart';

part 'menu_item_hive_model.g.dart';

@HiveType(typeId: HiveBoxConstants.menuItemTypeId)
class MenuItemHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String? image;

  @HiveField(4)
  final double price;

  @HiveField(5)
  final double? originalPrice;

  @HiveField(6)
  final String categoryId;

  MenuItemHiveModel({
    required this.id,
    required this.name,
    this.description,
    this.image,
    required this.price,
    this.originalPrice,
    required this.categoryId,
  });

  MenuItemEntity toEntity() {
    return MenuItemEntity(
      id: id,
      name: name,
      description: description,
      image: image,
      price: price,
      originalPrice: originalPrice,
      categoryId: categoryId,
    );
  }

  factory MenuItemHiveModel.fromEntity(MenuItemEntity entity) {
    return MenuItemHiveModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      image: entity.image,
      price: entity.price,
      originalPrice: entity.originalPrice,
      categoryId: entity.categoryId,
    );
  }

  static List<MenuItemEntity> toEntityList(List<MenuItemHiveModel> models) {
    return models.map((m) => m.toEntity()).toList();
  }

  static List<MenuItemHiveModel> fromEntityList(List<MenuItemEntity> entities) {
    return entities.map((e) => MenuItemHiveModel.fromEntity(e)).toList();
  }
}
