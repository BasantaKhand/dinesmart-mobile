import '../../domain/entities/menu_item_entity.dart';

class MenuItemApiModel {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final double price;
  final double? originalPrice;
  final String categoryId;

  MenuItemApiModel({
    required this.id,
    required this.name,
    this.description,
    this.image,
    required this.price,
    this.originalPrice,
    required this.categoryId,
  });

  factory MenuItemApiModel.fromJson(Map<String, dynamic> json) {
    return MenuItemApiModel(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      categoryId: json['categoryId']['_id'] ?? json['categoryId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'image': image,
      'price': price,
      'originalPrice': originalPrice,
      'categoryId': categoryId,
    };
  }

  factory MenuItemApiModel.fromEntity(MenuItemEntity entity) {
    return MenuItemApiModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      image: entity.image,
      price: entity.price,
      originalPrice: entity.originalPrice,
      categoryId: entity.categoryId,
    );
  }

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
}
