import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/view_model/auth_viewmodel.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../../app/routes/app_routes.dart';
import 'admin_tables_page.dart';
import 'admin_menu_items_page.dart';
import 'admin_categories_page.dart';
import 'admin_orders_page.dart';
import 'admin_staff_page.dart';
import 'admin_overview_page.dart';
import '../../../auth/presentation/widgets/user_profile_drop_down.dart';

enum AdminModule { dashboard, menuItems, categories, orders, staff, tables }

final adminModuleProvider = StateProvider<AdminModule>((ref) => AdminModule.dashboard);

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedModule = ref.watch(adminModuleProvider);
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: Text(_getModuleTitle(selectedModule)),
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
              actions: const [
                UserProfileDropDown(),
              ],
            )
          : null,
      drawer: isMobile
          ? SidebarNav(
              onSelect: (m) => ref.read(adminModuleProvider.notifier).state = m,
              onLogout: () => _handleLogout(context, ref),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            SidebarNav(
              onSelect: (m) => ref.read(adminModuleProvider.notifier).state = m,
              selectedModule: selectedModule,
              onLogout: () => _handleLogout(context, ref),
            ),
          Expanded(
            child: Column(
              children: [
                if (!isMobile)
                  Container(
                    height: 70,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        UserProfileDropDown(),
                      ],
                    ),
                  ),
                Expanded(
                  child: Container(
                    color: const Color(0xFFF9FAFB),
                    child: _buildModuleContent(selectedModule),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    ref.read(authViewModelProvider.notifier).logout();
    AppRoutes.pushAndRemoveUntil(context, const LoginPage());
  }

  String _getModuleTitle(AdminModule module) {
    switch (module) {
      case AdminModule.dashboard: return 'Dashboard';
      case AdminModule.menuItems: return 'Menu Items';
      case AdminModule.categories: return 'Categories';
      case AdminModule.orders: return 'Orders';
      case AdminModule.staff: return 'Staff';
      case AdminModule.tables: return 'Tables';
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
  final VoidCallback? onLogout;

  const SidebarNav({super.key, required this.onSelect, this.selectedModule, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Image.asset(
                  'assets/logos/dinesmart_logo.png',
                  height: 40,
                  errorBuilder: (c, e, s) => const Icon(Icons.restaurant, color: Colors.orange, size: 30),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DineSmart', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('ADMIN PANEL', style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1.2)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('OVERVIEW'),
          _buildNavItem(AdminModule.dashboard, Icons.grid_view_rounded, 'Dashboard'),
          const SizedBox(height: 24),
          _buildSectionHeader('MANAGEMENT'),
          _buildNavItem(AdminModule.menuItems, Icons.restaurant_menu_rounded, 'Menu Items'),
          _buildNavItem(AdminModule.categories, Icons.grid_view_sharp, 'Categories'),
          _buildNavItem(AdminModule.orders, Icons.shopping_bag_outlined, 'Orders'),
          _buildNavItem(AdminModule.staff, Icons.people_outline, 'Staff'),
          _buildNavItem(AdminModule.tables, Icons.table_chart_outlined, 'Tables'),
          const Spacer(),
          // if (onLogout != null)
          //   Padding(
          //     padding: const EdgeInsets.all(16.0),
          //     child: ListTile(
          //       onTap: onLogout,
          //       leading: const Icon(Icons.logout, color: Colors.red),
          //       title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
      ),
    );
  }

  Widget _buildNavItem(AdminModule module, IconData icon, String label) {
    final isSelected = selectedModule == module;
    return InkWell(
      onTap: () => onSelect(module),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF7F2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.orange : Colors.grey[600], size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.orange : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
