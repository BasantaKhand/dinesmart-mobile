import 'package:flutter/material.dart';
import '../../domain/entities/category_entity.dart';

class CategoryBar extends StatelessWidget {
  final List<CategoryEntity> categories;
  final CategoryEntity? selectedCategory;
  final Function(CategoryEntity?) onCategorySelected;

  const CategoryBar({
    super.key,
    required this.categories,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isAllSelected = selectedCategory == null;
            return _CategoryItem(
              name: 'All Menu',
              count: '13 items',
              isSelected: isAllSelected,
              onTap: () => onCategorySelected(null),
              icon: Icons.grid_view_rounded,
            );
          }
          final category = categories[index - 1];
          final isSelected = selectedCategory?.id == category.id;
          return _CategoryItem(
            name: category.name,
            count: '1 items', // Dynamic count if available
            isSelected: isSelected,
            onTap: () => onCategorySelected(category),
            imageUrl: category.image,
          );
        },
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String name;
  final String count;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final String? imageUrl;

  const _CategoryItem({
    required this.name,
    required this.count,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            if (icon != null)
              Icon(icon, color: isSelected ? Colors.white : Colors.orange),
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(imageUrl!, width: 30, height: 30, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.fastfood, size: 20)),
              ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  count,
                  style: TextStyle(
                    color: isSelected ? Colors.white70 : Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
