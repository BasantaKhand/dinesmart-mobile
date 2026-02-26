import '../../domain/entities/category_entity.dart';

class CategoryApiModel {
  final String id;
  final String name;
  final String? image;
  final String? description;

  CategoryApiModel({
    required this.id,
    required this.name,
    this.image,
    this.description,
  });

  factory CategoryApiModel.fromJson(Map<String, dynamic> json) {
    return CategoryApiModel(
      id: json['_id'],
      name: json['name'],
      image: json['image'],
      description: json['description'],
    );
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      image: image,
      description: description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'description': description,
    };
  }

  static CategoryApiModel fromEntity(CategoryEntity entity) {
    return CategoryApiModel(
      id: entity.id,
      name: entity.name,
      image: entity.image,
      description: entity.description,
    );
  }
}
