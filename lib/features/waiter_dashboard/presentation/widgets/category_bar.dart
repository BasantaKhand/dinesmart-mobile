import 'package:dinesmart_app/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/category_entity.dart';

class CategoryBar extends StatelessWidget {
  final List<CategoryEntity> categories;
  final CategoryEntity? selectedCategory;
  final Function(CategoryEntity?) onCategorySelected;
  final int allCount;
  final Map<String, int> categoryCountsById;
  final VoidCallback? onFilterTap;
  final bool filterActive;

  const CategoryBar({
    super.key,
    required this.categories,
    this.selectedCategory,
    required this.onCategorySelected,
    required this.allCount,
    required this.categoryCountsById,
    this.onFilterTap,
    this.filterActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = Colors.grey[50]!;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;
    final double barHeight = isTablet ? 64 : 52;

    return SizedBox(
      height: barHeight,
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: isTablet ? 20 : 16, right: 0),
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isAllSelected = selectedCategory == null;
                  return _CategoryItem(
                    name: 'All Menu',
                    count: _formatCount(allCount),
                    isSelected: isAllSelected,
                    onTap: () => onCategorySelected(null),
                    icon: Icons.grid_view_rounded,
                  );
                }

                final category = categories[index - 1];
                final isSelected = selectedCategory?.id == category.id;
                final c = categoryCountsById[category.id] ?? 0;

                return _CategoryItem(
                  name: category.name,
                  count: _formatCount(c),
                  isSelected: isSelected,
                  onTap: () => onCategorySelected(category),
                  imageUrl: category.image,
                );
              },
            ),
          ),
          SizedBox(
            width: isTablet ? 80 : 68,
            height: barHeight,
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Container(
                      width: 28,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Colors.transparent, bg],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _FilterButton(
                    onTap: onFilterTap,
                    isActive: filterActive,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int n) => '$n ${n == 1 ? "item" : "items"}';
}

class _FilterButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isActive;

  const _FilterButton({this.onTap, required this.isActive});

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(12));

    final bgColor = isActive ? AppColors.primary : Colors.white;
    final borderColor = Colors.grey[200]!;
    final iconColor = isActive ? Colors.white : AppColors.primary;

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: Ink(
        height: 52,
        width: 52,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: radius,
          border: Border.all(color: borderColor),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          child: Center(
            child: Icon(Icons.tune_rounded, color: iconColor, size: 22),
          ),
        ),
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
    const radius = BorderRadius.all(Radius.circular(12));

    final bgColor = isSelected ? AppColors.primary : Colors.white;
    final borderColor = Colors.grey[200]!;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: radius,
            border: Border.all(color: borderColor),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: isSelected ? Colors.white : AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (imageUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl!,
                        width: 28,
                        height: 28,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => SizedBox(
                          width: 28,
                          height: 28,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: isSelected ? Colors.white : AppColors.primary,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.fastfood,
                          size: 20,
                          color: isSelected ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        count,
                        style: TextStyle(
                          color: isSelected ? Colors.white70 : Colors.grey,
                          fontSize: 12,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
