import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dinesmart_app/core/api/api_endpoints.dart';
import 'package:dinesmart_app/core/services/storage/user_session_service.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/entities/order_entity.dart';
import '../view_model/admin_dashboard_view_model.dart';
import '../state/admin_dashboard_state.dart';
import 'package:intl/intl.dart';

class AdminOrdersPage extends ConsumerWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminDashboardViewModelProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final isMobile = availableWidth < 1000; // Adjusted for table content

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isMobile),
            const SizedBox(height: 16),
            Expanded(
              child: _buildOrdersList(context, state, isMobile, ref),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Restaurant Orders',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Track and manage all restaurant orders in real-time.',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, AdminDashboardState state, bool isMobile, WidgetRef ref) {
    if (state.status == AdminDashboardStatus.loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.orange));
    }

    if (state.status == AdminDashboardStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.errorMessage ?? 'An error occurred while fetching orders.', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(adminDashboardViewModelProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.orders.isEmpty) {
      final restaurantId = ref.read(userSessionServiceProvider).getCurrentRestaurantId();
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[200]),
            const SizedBox(height: 16),
            Text('No orders found today.', style: TextStyle(color: Colors.grey[400])),
            const SizedBox(height: 10),
            Text('DEBUG: URL: ${ApiEndpoints.baseUrl}', style: TextStyle(color: Colors.grey[300], fontSize: 10)),
            Text('DEBUG: Restaurant: $restaurantId', style: TextStyle(color: Colors.grey[300], fontSize: 10)),
          ],
        ),
      );
    }

    if (isMobile) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.orders.length,
        itemBuilder: (context, index) {
          final order = state.orders[index];
          return _buildOrderCard(order, ref);
        },
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: Column(
          children: [
            _buildTableHeader(),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.orders.length,
              separatorBuilder: (context, index) => Divider(color: Colors.grey[50], height: 1),
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return _buildOrderRow(order, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderEntity order, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(
                  '#ORD-${order.id.substring(order.id.length - 6).toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 12),
                ),
              ),
              _buildStatusBadge(order.status.name),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.table_restaurant_rounded, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text('Table ${order.tableNumber ?? "N/A"}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              _buildTimeBadge(order.createdAt),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(order.waiterName ?? 'Waiter One', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              const Spacer(),
              Text('रू ${order.total.toInt()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionButtons(order, ref, isMobile: true),
        ],
      ),
    );
  }

  Widget _buildTimeBadge(DateTime? time) {
    return Row(
      children: [
        const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          time != null ? DateFormat('HH:mm').format(time) : '--:--',
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'PENDING': color = Colors.amber[700]!; break;
      case 'COOKING': color = Colors.blue[600]!; break;
      case 'SERVED': color = Colors.teal[600]!; break;
      case 'BILL_PRINTED': color = Colors.indigo[600]!; break;
      case 'COMPLETED': color = Colors.green[600]!; break;
      case 'CANCELLED': color = Colors.red[600]!; break;
      default: color = Colors.grey[600]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          const Expanded(flex: 3, child: Text('ORDER ID', style: _headerStyle)),
          const Expanded(flex: 2, child: Text('TABLE', style: _headerStyle)),
          const Expanded(flex: 3, child: Text('WAITER', style: _headerStyle)),
          const Expanded(flex: 2, child: Text('ITEMS', style: _headerStyle)),
          const Expanded(flex: 2, child: Text('TOTAL', style: _headerStyle)),
          const Expanded(flex: 3, child: Text('STATUS', style: _headerStyle)),
          const Expanded(flex: 4, child: Text('ACTIONS', style: _headerStyle)),
        ],
      ),
    );
  }

  Widget _buildOrderRow(OrderEntity order, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
              child: Text(
                '#ORD-${order.id.substring(order.id.length - 6).toUpperCase()}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text('Table ${order.tableNumber ?? "N/A"}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey[100],
                  child: Text(order.waiterName?.substring(0, 1) ?? 'W', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ),
                const SizedBox(width: 10),
                Text(order.waiterName ?? 'Waiter One', style: TextStyle(color: Colors.grey[800])),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text('${order.items.length} Items', style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            flex: 2,
            child: Text('NRs. ${order.total.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 3,
            child: _buildStatusBadge(order.status.name),
          ),
          Expanded(
            flex: 4,
            child: _buildActionButtons(order, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(OrderEntity order, WidgetRef ref, {bool isMobile = false}) {
    List<Widget> buttons = [];

    // Helper to add a button
    void addButton(String label, OrderStatus targetStatus, Color color, {bool isOutlined = false}) {
      buttons.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 4.0),
          child: isMobile 
            ? SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _updateStatus(ref, order.id, targetStatus),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOutlined ? Colors.white : color,
                    foregroundColor: isOutlined ? color : Colors.white,
                    side: isOutlined ? BorderSide(color: color) : null,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              )
            : ElevatedButton(
                onPressed: () => _updateStatus(ref, order.id, targetStatus),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOutlined ? Colors.white : color.withOpacity(0.1),
                  foregroundColor: color,
                  side: isOutlined ? BorderSide(color: color) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              ),
        ),
      );
    }

    if (order.status == OrderStatus.PENDING) {
      addButton('COOKING', OrderStatus.COOKING, Colors.blue);
      addButton('CANCEL', OrderStatus.CANCELLED, Colors.red, isOutlined: true);
    } else if (order.status == OrderStatus.COOKING) {
      addButton('READY', OrderStatus.SERVED, Colors.orange);
      addButton('CANCEL', OrderStatus.CANCELLED, Colors.red, isOutlined: true);
    } else if (order.status == OrderStatus.SERVED) {
      addButton('COMPLETE', OrderStatus.COMPLETED, Colors.green);
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return isMobile 
        ? Column(children: buttons)
        : Row(mainAxisAlignment: MainAxisAlignment.start, children: buttons);
  }

  void _updateStatus(WidgetRef ref, String orderId, OrderStatus status) {
    ref.read(adminDashboardViewModelProvider.notifier).updateOrderStatus(orderId, status);
  }

  static const _headerStyle = TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1);
}
