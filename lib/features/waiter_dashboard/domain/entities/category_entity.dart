import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String? image;
  final String? description;
  final int? itemCount;

  const CategoryEntity({
    required this.id,
    required this.name,
    this.image,
    this.description,
    this.itemCount,
  });

  @override
  List<Object?> get props => [id, name, image, description, itemCount];
}
