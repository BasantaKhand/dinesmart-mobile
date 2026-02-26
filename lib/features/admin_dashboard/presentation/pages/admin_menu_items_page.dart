import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dinesmart_app/features/waiter_dashboard/presentation/view_model/waiter_dashboard_view_model.dart';
import 'package:dinesmart_app/features/waiter_dashboard/presentation/state/waiter_dashboard_state.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/entities/menu_item_entity.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/entities/category_entity.dart';

class AdminMenuItemsPage extends ConsumerWidget {
  const AdminMenuItemsPage({super.key});

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
            _buildHeader(context, ref, isMobile),
            const SizedBox(height: 24),
            _buildToolbar(state, ref, context, availableWidth),
            const SizedBox(height: 24),
            Expanded(
              child: _buildItemList(context, state, ref),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Menu Items',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                        fontSize: isMobile ? 24 : null,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your restaurant menu inventory',
                  style: TextStyle(color: Colors.grey[600], fontSize: isMobile ? 12 : 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () => _showItemDialog(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              elevation: 0,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 10 : 12,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                if (!isMobile) ...[
                  const SizedBox(width: 8),
                  const Text(
                    'Add Item',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(WaiterDashboardState state, WidgetRef ref, BuildContext context, double availableWidth) {
    final isMobile = availableWidth < 600;
    final isCompact = availableWidth < 450;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 24.0),
      child: isMobile
          ? Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 12),
                if (isCompact)
                  Column(
                    children: [
                      _buildFilterButton(context, state, ref, true),
                      const SizedBox(height: 8),
                      _buildSortButton(state, ref, true),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(child: _buildFilterButton(context, state, ref, false)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildSortButton(state, ref, false)),
                    ],
                  ),
              ],
            )
          : Row(
              children: [
                Expanded(child: _buildSearchBar()),
                const SizedBox(width: 12),
                _buildFilterButton(context, state, ref, false),
                const SizedBox(width: 12),
                _buildSortButton(state, ref, false),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: Colors.grey[400], size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search menu items...',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, WaiterDashboardState state, WidgetRef ref, bool isFullWidth) {
    return PopupMenuButton<CategoryEntity?>(
      offset: const Offset(0, 52),
      onSelected: (category) {
        ref.read(waiterDashboardViewModelProvider.notifier).selectCategory(category);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: null,
          child: Text('All Categories'),
        ),
        ...state.categories.map((c) => PopupMenuItem(
              value: c,
              child: Text(c.name),
            )),
      ],
      child: Container(
        height: 48,
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: state.selectedCategory != null ? Colors.orange.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: state.selectedCategory != null ? Colors.orange : Colors.grey[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list_rounded,
              color: state.selectedCategory != null ? Colors.orange : Colors.black87,
              size: 20,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                state.selectedCategory?.name ?? 'Filter',
                style: TextStyle(
                  color: state.selectedCategory != null ? Colors.orange : Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortButton(WaiterDashboardState state, WidgetRef ref, bool isFullWidth) {
    final isSorting = state.sortPriceOrder != SortOrder.none;
    return InkWell(
      onTap: () => ref.read(waiterDashboardViewModelProvider.notifier).toggleSortPriceOrder(),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 48,
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSorting ? Colors.blue.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSorting ? Colors.blue : Colors.grey[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              state.sortPriceOrder == SortOrder.ascending
                  ? Icons.arrow_upward_rounded
                  : (state.sortPriceOrder == SortOrder.descending
                      ? Icons.arrow_downward_rounded
                      : Icons.swap_vert_rounded),
              color: isSorting ? Colors.blue : Colors.black87,
              size: 20,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                isSorting ? (state.sortPriceOrder == SortOrder.ascending ? 'P Low' : 'P High') : 'Sort',
                style: TextStyle(
                  color: isSorting ? Colors.blue : Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemList(BuildContext context, WaiterDashboardState state, WidgetRef ref) {
    if (state.status == WaiterDashboardStatus.loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.orange));
    }

    var items = state.menuItems;

    // Apply Filter
    if (state.selectedCategory != null) {
      items = items.where((i) => i.categoryId == state.selectedCategory!.id).toList();
    }

    // Apply Sort
    if (state.sortPriceOrder == SortOrder.ascending) {
      items = List.from(items)..sort((a, b) => a.price.compareTo(b.price));
    } else if (state.sortPriceOrder == SortOrder.descending) {
      items = List.from(items)..sort((a, b) => b.price.compareTo(a.price));
    }

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu_rounded, size: 64, color: Colors.grey[200]),
            const SizedBox(height: 16),
            Text('No menu items found', style: TextStyle(color: Colors.grey[400])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final category = state.categories.firstWhere(
          (c) => c.id == item.categoryId,
          orElse: () => const CategoryEntity(id: '', name: 'Unknown'),
        );
        return _buildItemCard(context, item, category, ref);
      },
    );
  }

  Widget _buildItemCard(BuildContext context, MenuItemEntity item, CategoryEntity category, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 80,
              height: 80,
              color: Colors.grey[50],
              child: item.image != null && item.image!.isNotEmpty
                  ? Image.network(
                      item.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, color: Colors.grey),
                    )
                  : const Icon(Icons.restaurant, color: Colors.grey, size: 32),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, letterSpacing: -0.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildPriceBadge(item.price),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category.name,
                        style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      'ID: #${item.id.substring(item.id.length - 4).toUpperCase()}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildActionButton(Icons.edit_outlined, Colors.blue, () => _showItemDialog(context, ref, item: item)),
                    const SizedBox(width: 8),
                    _buildActionButton(Icons.delete_outline_rounded, Colors.red, () => _showDeleteConfirm(context, ref, item)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBadge(double price) {
    return Text(
      'रू ${price.toInt()}',
      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black87),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  void _showItemDialog(BuildContext context, WidgetRef ref, {MenuItemEntity? item}) {
    final nameController = TextEditingController(text: item?.name);
    final descController = TextEditingController(text: item?.description);
    final priceController = TextEditingController(text: item?.price.toString());
    final imageController = TextEditingController(text: item?.image);
    String? selectedCategoryId = item?.categoryId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(item == null ? 'New Menu Item' : 'Edit Menu Item', style: const TextStyle(fontWeight: FontWeight.w900)),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(nameController, 'Item Name', Icons.restaurant_rounded),
                  const SizedBox(height: 16),
                  _buildTextField(descController, 'Description', Icons.description_outlined, maxLines: 3),
                  const SizedBox(height: 16),
                  _buildTextField(priceController, 'Price (रू)', Icons.payments_outlined, keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  _buildTextField(imageController, 'Image URL', Icons.image_outlined),
                  const SizedBox(height: 16),
                  _buildCategoryDropdown(ref, selectedCategoryId, (val) => setState(() => selectedCategoryId = val)),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final newItem = MenuItemEntity(
                  id: item?.id ?? '',
                  name: nameController.text,
                  description: descController.text,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  image: imageController.text,
                  categoryId: selectedCategoryId ?? '',
                );
                if (item == null) {
                  ref.read(waiterDashboardViewModelProvider.notifier).createMenuItem(newItem);
                } else {
                  ref.read(waiterDashboardViewModelProvider.notifier).updateMenuItem(item.id, newItem);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
              child: Text(item == null ? 'Create' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.orange, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[200]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.orange)),
      ),
    );
  }

  Widget _buildCategoryDropdown(WidgetRef ref, String? selectedId, Function(String?) onChanged) {
    final state = ref.watch(waiterDashboardViewModelProvider);
    return DropdownButtonFormField<String>(
      value: selectedId,
      decoration: InputDecoration(
        labelText: 'Category',
        prefixIcon: const Icon(Icons.category_outlined, color: Colors.orange, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      items: state.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
      onChanged: onChanged,
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, MenuItemEntity item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Menu Item?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to remove ${item.name} from the menu?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(waiterDashboardViewModelProvider.notifier).deleteMenuItem(item.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
