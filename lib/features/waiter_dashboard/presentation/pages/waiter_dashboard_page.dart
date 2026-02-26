import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/waiter_dashboard_state.dart';
import '../view_model/waiter_dashboard_view_model.dart';
import '../widgets/table_grid.dart';
import '../widgets/category_bar.dart';
import '../widgets/menu_item_grid.dart';
import '../widgets/bill_summary_sheet.dart';
import '../../../auth/presentation/widgets/user_profile_drop_down.dart';

class WaiterDashboardPage extends ConsumerWidget {
  const WaiterDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(waiterDashboardViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/logos/dinesmart_logo.png', height: 40, errorBuilder: (c, e, s) => const Icon(Icons.restaurant, color: Colors.orange)),
            const SizedBox(width: 10),
            const Text(
              'DineSmart',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: const [
          UserProfileDropDown(),
          SizedBox(width: 8),
        ],
      ),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, WaiterDashboardState state) {
    if (state.status == WaiterDashboardStatus.loading && state.tables.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == WaiterDashboardStatus.error && state.tables.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text('Error: ${state.errorMessage ?? "Failed to load dashboard"}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(waiterDashboardViewModelProvider.notifier).initialize(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.tables.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.table_restaurant_outlined, color: Colors.grey, size: 60),
            const SizedBox(height: 16),
            const Text('No tables found for your restaurant.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(waiterDashboardViewModelProvider.notifier).initialize(),
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Active Tables',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              TableGrid(
                tables: state.tables,
                selectedTable: state.selectedTable,
                onTableSelected: (table) => ref.read(waiterDashboardViewModelProvider.notifier).selectTable(table),
              ),
              const SizedBox(height: 20),
              CategoryBar(
                categories: state.categories,
                selectedCategory: state.selectedCategory,
                onCategorySelected: (cat) => ref.read(waiterDashboardViewModelProvider.notifier).selectCategory(cat),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                child: Text(
                  'Special menu for you',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              MenuItemGrid(
                items: state.menuItems.where((i) => state.selectedCategory == null || i.categoryId == state.selectedCategory!.id).toList(),
                onItemAdded: (item) => ref.read(waiterDashboardViewModelProvider.notifier).addToCart(item),
              ),
            ],
          ),
        ),
        if (state.selectedTable != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BillSummarySheet(
              state: state,
              onCreateOrder: () => ref.read(waiterDashboardViewModelProvider.notifier).createOrder(),
              onPrintBill: () => _showPrintConfirmation(context, ref),
            ),
          ),
      ],
    );
  }

  void _showPrintConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[400]),
            const SizedBox(width: 10),
            const Text('Confirm Bill Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Have you printed the bill and given it to the customer? The order will be marked as complete.',
          style: TextStyle(color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Go Back', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(waiterDashboardViewModelProvider.notifier).printBill();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Yes, Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

