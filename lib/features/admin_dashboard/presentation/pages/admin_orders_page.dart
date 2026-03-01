import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/entities/order_entity.dart';
import '../view_model/admin_dashboard_view_model.dart';
import '../state/admin_dashboard_state.dart';

class AdminOrdersPage extends ConsumerWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminDashboardViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 1000;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildV3Header(context, ref),
              const Divider(height: 1, color: Color(0xFFF1F4F8)),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: _buildV3OrdersList(context, state, isMobile, ref),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildV3Header(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Orders',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: -0.5),
          ),
          const SizedBox(height: 4),
          Text(
            'Track and manage all restaurant orders in real-time.',
            style: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          _buildSearchAndFilters(context, ref),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (value) => ref.read(adminDashboardViewModelProvider.notifier).setSearchQuery(value),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400], size: 20),
              hintText: 'Search by order ID, table, waiter...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: IconButton(
            onPressed: () => _showFilterSheet(context),
            icon: Icon(Icons.tune_rounded, color: Colors.grey[700]),
            tooltip: 'Filters',
          ),
        ),
      ],
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _FilterSheet(),
    );
  }

  Widget _buildV3OrdersList(BuildContext context, AdminDashboardState state, bool isMobile, WidgetRef ref) {
    if (state.status == AdminDashboardStatus.loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.orange));
    }

    final orders = state.filteredOrders;

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[200]),
            const SizedBox(height: 16),
            Text('No orders found.', style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(adminDashboardViewModelProvider.notifier).initialize(),
      color: const Color(0xFFFF7D29),
      backgroundColor: Colors.white,
      child: isMobile ? _buildMobileOrderList(orders, ref) : _buildV3OrderTable(orders, ref),
    );
  }

  Widget _buildMobileOrderList(List<OrderEntity> orders, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildMobileOrderCard(order, ref);
      },
    );
  }

  Widget _buildMobileOrderCard(OrderEntity order, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Id : #ORD-${order.id.substring(order.id.length - 4).toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
                      onPressed: () {},
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
                      onPressed: () {},
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F4F8)),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildCardRow('Waiter name', ': ${order.waiterName ?? "Saugat Shahi"}'),
                const SizedBox(height: 8),
                _buildCardRow('Table No.', ': T-${order.tableNumber ?? "02"}'),
                const SizedBox(height: 8),
                _buildCardRow('Status', ': ', valueWidget: _buildMinimalStatusText(order.status.name)),
              ],
            ),
          ),
          // Footer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FD),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Text(
                'View',
                style: TextStyle(
                  color: Colors.blue[600],
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardRow(String label, String value, {Widget? valueWidget}) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
          ),
        ),
        if (valueWidget != null) ...[
          const Text(': ', style: TextStyle(fontWeight: FontWeight.w600)),
          valueWidget,
        ] else
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
          ),
      ],
    );
  }

  Widget _buildMinimalStatusText(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'PENDING': color = Colors.orange; break;
      case 'COMPLETED': color = Colors.green; break;
      case 'SERVED': color = Colors.green; break;
      case 'CANCELLED': color = Colors.red; break;
      default: color = Colors.blue;
    }
    return Text(
      status.toUpperCase(),
      style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
    );
  }

  Widget _buildV3OrderTable(List<OrderEntity> orders, WidgetRef ref) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FD)),
                columnSpacing: 40,
                columns: const [
                  DataColumn(label: Text('Order ID', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.black54))),
                  DataColumn(label: Text('Waiter Name', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.black54))),
                  DataColumn(label: Text('Table No.', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.black54))),
                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.black54))),
                  DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.black54))),
                ],
                rows: orders.map((order) {
                  return DataRow(cells: [
                    DataCell(Text('#ORD-${order.id.substring(order.id.length - 4).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w700))),
                    DataCell(Text(order.waiterName ?? 'Saugat Shahi')),
                    DataCell(Text('T-${order.tableNumber ?? "02"}')),
                    DataCell(_buildStatusBadge(order.status.name)),
                    DataCell(
                      Row(
                        children: [
                          IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue), onPressed: () {}),
                          IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red), onPressed: () {}),
                          const SizedBox(width: 8),
                          _buildTableButton('View', Colors.green, () {}),
                          const SizedBox(width: 8),
                          _buildTableButton('Send', Colors.blue, () {}),
                        ],
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableButton(String label, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).toInt()),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    final statusStr = status.toUpperCase();
    switch (statusStr) {
      case 'PENDING': color = const Color(0xFFFF7D29); break;
      case 'COOKING': color = const Color(0xFF8B5CF6); break;
      case 'SERVED': color = const Color(0xFF10B981); break;
      case 'COMPLETED': color = const Color(0xFF10B981); break;
      case 'CANCELLED': color = const Color(0xFFEF4444); break;
      default: color = Colors.grey;
    }

    return Text(
      statusStr,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800),
    );
  }
}

class _FilterSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminDashboardViewModelProvider);
    final notifier = ref.read(adminDashboardViewModelProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black),
              ),
              TextButton(
                onPressed: () {
                  notifier.clearFilters();
                  Navigator.pop(context);
                },
                child: const Text(
                  'Reset All',
                  style: TextStyle(color: Color(0xFFFF7D29), fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'ORDER STATUS',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black54, letterSpacing: 1.0),
          ),
          const SizedBox(height: 16),
          _buildMinimalChoiceRow(
            options: ['All', ...OrderStatus.values.map((e) => e.name.toUpperCase())],
            selectedOption: state.selectedStatus == null ? 'All' : state.selectedStatus!.name.toUpperCase(),
            onSelected: (val) {
              if (val == 'All') {
                notifier.setStatusFilter(null);
              } else {
                final status = OrderStatus.values.firstWhere((e) => e.name.toUpperCase() == val);
                notifier.setStatusFilter(status);
              }
            },
          ),
          const SizedBox(height: 32),
          const Text(
            'PAYMENT STATUS',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black54, letterSpacing: 1.0),
          ),
          const SizedBox(height: 16),
          _buildMinimalChoiceRow(
            options: ['All', ...PaymentStatus.values.map((e) => e.name.toUpperCase())],
            selectedOption: state.selectedPaymentStatus == null ? 'All' : state.selectedPaymentStatus!.name.toUpperCase(),
            onSelected: (val) {
              if (val == 'All') {
                notifier.setPaymentStatusFilter(null);
              } else {
                final status = PaymentStatus.values.firstWhere((e) => e.name.toUpperCase() == val);
                notifier.setPaymentStatusFilter(status);
              }
            },
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Apply Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMinimalChoiceRow({
    required List<String> options,
    required String selectedOption,
    required Function(String) onSelected,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((option) {
          final isSelected = option == selectedOption;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => onSelected(option),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : const Color(0xFFF8F9FD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.black : const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
