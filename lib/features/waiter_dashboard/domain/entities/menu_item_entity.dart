import 'package:equatable/equatable.dart';

class MenuItemEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final double price;
  final double? originalPrice;
  final String categoryId;

  const MenuItemEntity({
    required this.id,
    required this.name,
    this.description,
    this.image,
    required this.price,
    this.originalPrice,
    required this.categoryId,
  });

  @override
  List<Object?> get props => [id, name, description, image, price, originalPrice, categoryId];
}
