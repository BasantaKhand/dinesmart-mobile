import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_tables_page.dart';
import 'admin_menu_items_page.dart';
import 'admin_categories_page.dart';
import 'admin_orders_page.dart';
import 'admin_staff_page.dart';
import 'admin_overview_page.dart';
import '../../../auth/presentation/widgets/user_profile_drop_down.dart';

enum AdminModule { dashboard, menuItems, categories, orders, staff, tables }

final adminModuleProvider = StateProvider<AdminModule>(
  (ref) => AdminModule.dashboard,
);

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedModule = ref.watch(adminModuleProvider);
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: Colors.grey[50],

      // AppBar refactored to match WaiterDashboardPage style
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          children: [
            Image.asset(
              'assets/logos/logo.png',
              height: 32,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.restaurant, color: Colors.orange),
            ),
            const SizedBox(width: 10),
            const Text(
              'DineSmart',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: const [UserProfileDropDown(), SizedBox(width: 8)],
      ),

      // No drawer/menu-drawer code
      body: Row(
        children: [
          if (!isMobile)
            SidebarNav(
              onSelect: (m) => ref.read(adminModuleProvider.notifier).state = m,
              selectedModule: selectedModule,
            ),
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: _buildModuleContent(selectedModule),
            ),
          ),
        ],
      ),

      bottomNavigationBar: isMobile
          ? _buildBottomNav(ref, selectedModule)
          : null,
    );
  }

  Widget _buildBottomNav(WidgetRef ref, AdminModule selectedModule) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: BottomNavigationBar(
        currentIndex: _getModuleIndex(selectedModule),
        onTap: (index) => ref.read(adminModuleProvider.notifier).state =
            _getModuleFromIndex(index),
        selectedItemColor: const Color(0xFFFF7D29),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_rounded),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_bar_outlined),
            label: 'Tables',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  int _getModuleIndex(AdminModule module) {
    switch (module) {
      case AdminModule.dashboard:
        return 0;
      case AdminModule.orders:
        return 1;
      case AdminModule.menuItems:
        return 2;
      case AdminModule.tables:
        return 3;
      case AdminModule.staff:
        return 4;
      default:
        return 0;
    }
  }

  AdminModule _getModuleFromIndex(int index) {
    switch (index) {
      case 0:
        return AdminModule.dashboard;
      case 1:
        return AdminModule.orders;
      case 2:
        return AdminModule.menuItems;
      case 3:
        return AdminModule.tables;
      case 4:
        return AdminModule.staff;
      default:
        return AdminModule.dashboard;
    }
  }

  Widget _buildModuleContent(AdminModule module) {
    switch (module) {
      case AdminModule.tables:
        return const AdminTablesPage();
      case AdminModule.menuItems:
        return const AdminMenuItemsPage();
      case AdminModule.categories:
        return const AdminCategoriesPage();
      case AdminModule.orders:
        return const AdminOrdersPage();
      case AdminModule.staff:
        return const AdminStaffPage();
      case AdminModule.dashboard:
        return const AdminOverviewPage();
    }
  }
}

class SidebarNav extends StatelessWidget {
  final Function(AdminModule) onSelect;
  final AdminModule? selectedModule;

  const SidebarNav({super.key, required this.onSelect, this.selectedModule});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFFF7D29,
                    ).withAlpha((0.1 * 255).toInt()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/logos/logo.png',
                    height: 24,
                    errorBuilder: (c, e, s) => const Icon(
                      Icons.restaurant,
                      color: Color(0xFFFF7D29),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DineSmart',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'ADMIN CLOUD',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildNavItem(
            AdminModule.dashboard,
            Icons.grid_view_rounded,
            'Dashboard',
          ),
          _buildNavItem(
            AdminModule.orders,
            Icons.shopping_bag_outlined,
            'Orders',
          ),
          _buildNavItem(
            AdminModule.menuItems,
            Icons.restaurant_menu_rounded,
            'Menu Items',
          ),
          _buildNavItem(
            AdminModule.categories,
            Icons.category_outlined,
            'Categories',
          ),
          _buildNavItem(
            AdminModule.staff,
            Icons.people_outline,
            'Staff Management',
          ),
          _buildNavItem(
            AdminModule.tables,
            Icons.table_bar_outlined,
            'Table Setup',
          ),
          const Spacer(),
          _buildBottomProfile(),
        ],
      ),
    );
  }

  Widget _buildNavItem(AdminModule module, IconData icon, String label) {
    final isSelected = selectedModule == module;
    return InkWell(
      onTap: () => onSelect(module),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF7D29).withAlpha((0.08 * 255).toInt())
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFFF7D29) : Colors.grey[500],
              size: 22,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? const Color(0xFFFF7D29) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomProfile() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.orange[100],
            child: const Text(
              'A',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Admin User',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Manager',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          Icon(Icons.more_vert, size: 16, color: Colors.grey[400]),
        ],
      ),
    );
  }
}
