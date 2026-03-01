import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dinesmart_app/features/waiter_dashboard/presentation/view_model/waiter_dashboard_view_model.dart';
import 'package:dinesmart_app/features/waiter_dashboard/presentation/state/waiter_dashboard_state.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/entities/category_entity.dart';

class AdminCategoriesPage extends ConsumerWidget {
  const AdminCategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(waiterDashboardViewModelProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final isMobile = availableWidth < 600;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, ref, availableWidth),
            const SizedBox(height: 24),
            _buildSearchAndFilter(isMobile),
            const SizedBox(height: 24),
            Expanded(
              child: _buildCategoryList(context, state, ref, isMobile),
            ),
          ],
        );
      },
    );
  }

  void _showCategoryDialog(BuildContext context, WidgetRef ref, {CategoryEntity? category}) {
    final nameController = TextEditingController(text: category?.name);
    final descriptionController = TextEditingController(text: category?.description);
    final imageController = TextEditingController(text: category?.image);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? 'Add Category' : 'Edit Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g. Italian'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description', hintText: 'e.g. Pasta and Pizzas'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(labelText: 'Image URL', hintText: 'https://example.com/image.jpg'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty) return;
              
              final newCategory = CategoryEntity(
                id: category?.id ?? '',
                name: nameController.text,
                description: descriptionController.text,
                image: imageController.text,
              );

              final viewModel = ref.read(waiterDashboardViewModelProvider.notifier);
              if (category == null) {
                viewModel.createCategory(newCategory);
              } else {
                viewModel.updateCategory(category.id, newCategory);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(category == null ? 'Create' : 'Save', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, CategoryEntity category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(waiterDashboardViewModelProvider.notifier).deleteCategory(category.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, double availableWidth) {
    final isMobile = availableWidth < 600;
    return Padding(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 24, isMobile ? 24 : 32, isMobile ? 16 : 24, 8),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderContent(context, isMobile),
                const SizedBox(height: 16),
                _buildAddButton(context, ref, isMobile),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildHeaderContent(context, isMobile)),
                const SizedBox(width: 16),
                _buildAddButton(context, ref, isMobile),
              ],
            ),
    );
  }

  Widget _buildHeaderContent(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: -0.5,
                fontSize: isMobile ? 24 : null,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Organize and manage your menu hierarchy',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: isMobile ? 13 : 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context, WidgetRef ref, bool isMobile) {
    return Material(
      color: Colors.orange,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      child: InkWell(
        onTap: () => _showCategoryDialog(context, ref),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 18, vertical: isMobile ? 10 : 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              if (!isMobile) ...[
                const SizedBox(width: 8),
                const Text(
                  'Add Category',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 24.0),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[200]!),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: Colors.grey[400], size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Search categories...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 1,
              height: 24,
              color: Colors.grey[200],
            ),
            const SizedBox(width: 8),
            Icon(Icons.filter_list_rounded, color: Colors.grey[400], size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, WaiterDashboardState state, WidgetRef ref, bool isMobile) {
    if (state.status == WaiterDashboardStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.orange,
        ),
      );
    }

    if (state.categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 64, color: Colors.grey[200]),
            const SizedBox(height: 16),
            Text(
              'No categories found',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 8),
      itemCount: state.categories.length,
      itemBuilder: (context, index) {
        final category = state.categories[index];
        final itemCount = state.menuItems.where((item) => item.categoryId == category.id).length;

        return _buildCategoryCard(context, ref, category, itemCount, isMobile);
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, WidgetRef ref, CategoryEntity category, int itemCount, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!, width: 1.2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {}, // Future: Browse category items
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image container with shadow
              Container(
                width: isMobile ? 70 : 90,
                height: isMobile ? 70 : 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isMobile ? 14 : 20),
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[100]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isMobile ? 14 : 20),
                  child: category.image != null && category.image!.isNotEmpty
                      ? Image.network(
                          category.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.grey,
                          ),
                        )
                      : Icon(Icons.restaurant_rounded, color: Colors.grey[300], size: isMobile ? 24 : 32),
                ),
              ),
              SizedBox(width: isMobile ? 12 : 20),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            category.name,
                            style: TextStyle(
                              fontSize: isMobile ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isMobile) _buildStatusBadge(),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      category.description ?? 'No description provided for this category',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: isMobile ? 12 : 14,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildMetricChip(Icons.restaurant_menu_rounded, '$itemCount Items', isMobile),
                        if (!isMobile) _buildMetricChip(Icons.trending_up_rounded, 'Top Seller', isMobile),
                      ],
                    ),
                  ],
                ),
              ),
              // Actions
              const SizedBox(width: 8),
              _buildActionButtons(context, ref, category, isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'ACTIVE',
        style: TextStyle(
          color: Colors.green[700],
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMetricChip(IconData icon, String label, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 10, vertical: isMobile ? 4 : 6),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isMobile ? 12 : 14, color: Colors.grey[400]),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isMobile ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, CategoryEntity category, bool isMobile) {
    return Column(
      children: [
        _buildIconButton(
          onPressed: () => _showCategoryDialog(context, ref, category: category),
          icon: Icons.edit_note_rounded,
          color: Colors.blue[600]!,
          isMobile: isMobile,
        ),
        const SizedBox(height: 8),
        _buildIconButton(
          onPressed: () => _showDeleteConfirmation(context, ref, category),
          icon: Icons.delete_outline_rounded,
          color: Colors.red[400]!,
          isMobile: isMobile,
        ),
      ],
    );
  }

  Widget _buildIconButton({required VoidCallback onPressed, required IconData icon, required Color color, bool isMobile = false}) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: isMobile ? 18 : 22),
        constraints: BoxConstraints(minWidth: isMobile ? 36 : 40, minHeight: isMobile ? 36 : 40),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
