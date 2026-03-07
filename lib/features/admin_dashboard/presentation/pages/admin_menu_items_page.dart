import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dinesmart_app/features/waiter_dashboard/presentation/view_model/waiter_dashboard_view_model.dart';
import 'package:dinesmart_app/features/waiter_dashboard/presentation/state/waiter_dashboard_state.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/entities/menu_item_entity.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/entities/category_entity.dart';

class AdminMenuItemsPage extends ConsumerStatefulWidget {
  const AdminMenuItemsPage({super.key});

  @override
  ConsumerState<AdminMenuItemsPage> createState() => _AdminMenuItemsPageState();
}

class _AdminMenuItemsPageState extends ConsumerState<AdminMenuItemsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Dashboard tokens (match your Overview/Orders pages)
  static const Color _pageBg = Color(0xFFF7F7F8);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _text = Color(0xFF111827);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _muted2 = Color(0xFF9CA3AF);
  static const Color _brand = Color(0xFFFF7D29);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(waiterDashboardViewModelProvider);

    return Scaffold(
      backgroundColor: _pageBg,
      floatingActionButton: FloatingActionButton(
        backgroundColor: _brand,
        onPressed: () => _showItemBottomSheet(context),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final isMobile = availableWidth < 700;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopHeader(context, isMobile, state),
              const SizedBox(height: 4),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 14 : 28,
                    vertical: isMobile ? 12 : 18,
                  ),
                  child: _buildItemList(context, state),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopHeader(
    BuildContext context,
    bool isMobile,
    WaiterDashboardState state,
  ) {
    final isFilterActive =
        state.selectedCategory != null ||
        state.sortPriceOrder != SortOrder.none;

    return Container(
      color: _pageBg,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 28,
        isMobile ? 16 : 22,
        isMobile ? 16 : 28,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Menu Items',
            style: TextStyle(
              fontSize: isMobile ? 24 : 28,
              height: 1.05,
              fontWeight: FontWeight.w800,
              color: _text,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Create, edit, and organize your restaurant menu.',
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              color: _muted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _border),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.grey[500],
                        size: 20,
                      ),
                      hintText: 'Search menu items...',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () => _showFilterSheet(context, state),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _border),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: isFilterActive ? _brand : Colors.grey[800],
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WaiterDashboardState state) {
    final notifier = ref.read(waiterDashboardViewModelProvider.notifier);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) {
        // ✅ full width fix on web/desktop
        return FractionallySizedBox(
          widthFactor: 1,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Menu Items',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: _text,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          notifier.selectCategory(null);
                          notifier.setSortPriceOrder(SortOrder.none);
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'Reset',
                          style: TextStyle(
                            color: _brand,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Refine your menu items search',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'CATEGORY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.black54,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          'All',
                          state.selectedCategory == null,
                          () {
                            notifier.selectCategory(null);
                            Navigator.pop(ctx);
                          },
                        ),
                        ...state.categories.map(
                          (cat) => Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: _buildFilterChip(
                              cat.name,
                              state.selectedCategory?.id == cat.id,
                              () {
                                notifier.selectCategory(cat);
                                Navigator.pop(ctx);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'SORT BY PRICE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.black54,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildFilterChip(
                        'Default',
                        state.sortPriceOrder == SortOrder.none,
                        () {
                          notifier.setSortPriceOrder(SortOrder.none);
                          Navigator.pop(ctx);
                        },
                      ),
                      _buildFilterChip(
                        'Low to High',
                        state.sortPriceOrder == SortOrder.ascending,
                        () {
                          notifier.setSortPriceOrder(SortOrder.ascending);
                          Navigator.pop(ctx);
                        },
                      ),
                      _buildFilterChip(
                        'High to Low',
                        state.sortPriceOrder == SortOrder.descending,
                        () {
                          notifier.setSortPriceOrder(SortOrder.descending);
                          Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _brand : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? _brand : _border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : _text,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ---------------- Items list ----------------

  Widget _buildItemList(BuildContext context, WaiterDashboardState state) {
    if (state.status == WaiterDashboardStatus.loading) {
      return const Center(child: CircularProgressIndicator(color: _brand));
    }

    var items = state.menuItems;

    // Apply Filter
    if (state.selectedCategory != null) {
      items = items
          .where((i) => i.categoryId == state.selectedCategory!.id)
          .toList();
    }

    // Apply Sort
    if (state.sortPriceOrder == SortOrder.ascending) {
      items = List.from(items)..sort((a, b) => a.price.compareTo(b.price));
    } else if (state.sortPriceOrder == SortOrder.descending) {
      items = List.from(items)..sort((a, b) => b.price.compareTo(a.price));
    }

    // Apply Search Filter
    if (_searchQuery.isNotEmpty) {
      items = items
          .where(
            (i) => i.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    if (items.isEmpty) {
      return Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.restaurant_menu_rounded,
                size: 62,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 14),
              Text(
                'No menu items found',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Try adjusting search or filters.',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final availableWidth = MediaQuery.of(context).size.width;
    final isDesktop = availableWidth > 900;

    if (isDesktop) {
      return GridView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 2.55,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final category = state.categories.firstWhere(
            (c) => c.id == item.categoryId,
            orElse: () => const CategoryEntity(id: '', name: 'Unknown'),
          );
          return _buildItemCard(context, item, category, ref, isDesktop: true);
        },
      );
    }

    // Mobile/tablet: separated cards with soft gaps
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
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

  // ---------------- Item card (flat, minimal radius, soft spacing) ----------------

  Widget _buildItemCard(
    BuildContext context,
    MenuItemEntity item,
    CategoryEntity category,
    WidgetRef ref, {
    bool isDesktop = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 72,
              height: 72,
              color: const Color(0xFFF9FAFB),
              child: item.image != null && item.image!.isNotEmpty
                  ? Image.network(
                      item.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.restaurant, color: _muted2),
                    )
                  : const Icon(Icons.restaurant, color: _muted2, size: 28),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: _text,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '#ITM-${item.id.substring(item.id.length - 4).toUpperCase()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: _text,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Category
                Text(
                  category.name.toUpperCase(),
                  style: const TextStyle(
                    color: _muted2,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'NRs. ${item.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: _brand,
                      ),
                    ),
                    Row(
                      children: [
                        _buildActionButton(
                          Icons.edit_outlined,
                          const Color(0xFF2563EB),
                          () => _showItemBottomSheet(context, item: item),
                        ),
                        const SizedBox(width: 6),
                        _buildActionButton(
                          Icons.delete_outline_rounded,
                          const Color(0xFFEF4444),
                          () => _showDeleteConfirm(context, item),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withAlpha((0.10 * 255).toInt()),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }


  void _showItemBottomSheet(BuildContext context, {MenuItemEntity? item}) {
    final nameController = TextEditingController(text: item?.name);
    final descController = TextEditingController(text: item?.description);
    final priceController = TextEditingController(text: item?.price.toString());
    final imageController = TextEditingController(text: item?.image);
    String? selectedCategoryId = item?.categoryId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          widthFactor: 1,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.85,
              minChildSize: 0.5,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  child: StatefulBuilder(
                    builder: (context, setState) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 12),
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item == null
                                        ? 'New Menu Item'
                                        : 'Edit Menu Item',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: _text,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item == null
                                        ? 'Add a new item to your restaurant menu.'
                                        : 'Modify details for this menu item.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF1F4F8),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: _text,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _label('Item Name'),
                        _buildTextField(nameController, 'Enter item name'),
                        const SizedBox(height: 16),
                        _label('Description'),
                        _buildTextField(
                          descController,
                          'Enter description',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('Price (रू)'),
                                  _buildTextField(
                                    priceController,
                                    '0.00',
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('Category'),
                                  _buildCategoryDropdown(
                                    ref,
                                    selectedCategoryId,
                                    (val) => setState(
                                      () => selectedCategoryId = val,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _label('Image URL'),
                        _buildTextField(imageController, 'Enter image URL'),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              final newItem = MenuItemEntity(
                                id: item?.id ?? '',
                                name: nameController.text,
                                description: descController.text,
                                price:
                                    double.tryParse(priceController.text) ??
                                    0.0,
                                image: imageController.text,
                                categoryId: selectedCategoryId ?? '',
                              );
                              if (item == null) {
                                ref
                                    .read(
                                      waiterDashboardViewModelProvider.notifier,
                                    )
                                    .createMenuItem(newItem);
                              } else {
                                ref
                                    .read(
                                      waiterDashboardViewModelProvider.notifier,
                                    )
                                    .updateMenuItem(item.id, newItem);
                              }
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _brand,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              item == null ? 'Add Item' : 'Save Changes',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.black.withAlpha(190),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black.withAlpha(120),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withAlpha(25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _brand, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(
    WidgetRef ref,
    String? selectedId,
    Function(String?) onChanged,
  ) {
    final state = ref.watch(waiterDashboardViewModelProvider);
    return DropdownButtonFormField<String>(
      isExpanded: true,
      isDense: true,
      initialValue: selectedId,
      decoration: InputDecoration(
        hintText: 'Select Category',
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black.withAlpha(120),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withAlpha(25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _brand, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[600]),
      selectedItemBuilder: (context) {
        return state.categories.map((c) {
          return Text(
            c.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          );
        }).toList();
      },
      items: state.categories
          .map(
            (c) => DropdownMenuItem(
              value: c.id,
              child: Text(
                c.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  void _showDeleteConfirm(BuildContext context, MenuItemEntity item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Menu Item?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to remove ${item.name} from the menu?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(waiterDashboardViewModelProvider.notifier)
                  .deleteMenuItem(item.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
