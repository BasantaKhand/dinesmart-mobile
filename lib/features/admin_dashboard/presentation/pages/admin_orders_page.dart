import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/entities/order_entity.dart';
import '../view_model/admin_dashboard_view_model.dart';
import '../state/admin_dashboard_state.dart';

class AdminOrdersPage extends ConsumerWidget {
  const AdminOrdersPage({super.key});

  // Dashboard tokens (match AdminOverviewPage)
  static const Color _pageBg = Color(0xFFF7F7F8);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _text = Color(0xFF111827);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _muted2 = Color(0xFF9CA3AF);
  static const Color _brand = Color(0xFFFF7D29);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminDashboardViewModelProvider);

    return Scaffold(
      backgroundColor: _pageBg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 1000;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopHeader(context, ref, isMobile),
              const SizedBox(height: 4),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 14 : 28,
                    vertical: isMobile ? 12 : 18,
                  ),
                  child: _buildV3OrdersList(context, state, isMobile, ref),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------------- Header (grey bg) ----------------

  Widget _buildTopHeader(BuildContext context, WidgetRef ref, bool isMobile) {
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
            'Orders',
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
            'Manage and track orders across tables and waiters.',
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              color: _muted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          _buildSearchAndFilters(context, ref),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _border),
            ),
            child: TextField(
              onChanged: (value) => ref
                  .read(adminDashboardViewModelProvider.notifier)
                  .setSearchQuery(value),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.grey[500],
                  size: 20,
                ),
                hintText: 'Search by order ID, table, waiter...',
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
          borderRadius: BorderRadius.circular(10),
          onTap: () => _showFilterSheet(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _border),
            ),
            child: Icon(Icons.tune_rounded, color: Colors.grey[800], size: 20),
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

  // ---------------- Orders List ----------------

  Widget _buildV3OrdersList(
    BuildContext context,
    AdminDashboardState state,
    bool isMobile,
    WidgetRef ref,
  ) {
    if (state.status == AdminDashboardStatus.loading) {
      return const Center(child: CircularProgressIndicator(color: _brand));
    }

    final orders = state.filteredOrders;

    if (orders.isEmpty) {
      return Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 62,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 14),
              Text(
                'No orders found',
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

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(adminDashboardViewModelProvider.notifier).initialize(),
      color: _brand,
      backgroundColor: Colors.white,
      child: isMobile
          ? _buildMobileOrderList(orders, ref)
          : _buildV3OrderTable(orders, ref),
    );
  }

  // ---------------- Mobile list (separated cards) ----------------

  Widget _buildMobileOrderList(List<OrderEntity> orders, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildMobileOrderCard(order, ref, context);
      },
    );
  }

  Widget _buildMobileOrderCard(
    OrderEntity order,
    WidgetRef ref,
    BuildContext context,
  ) {
    final dateStr = order.createdAt != null
        ? DateFormat('MMM d, yyyy').format(order.createdAt!)
        : DateFormat('MMM d, yyyy').format(DateTime.now());

    final orderId = order.id.length > 8
        ? order.id.substring(order.id.length - 8).toUpperCase()
        : order.id.toUpperCase();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '#ORD-$orderId',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: _text,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                dateStr,
                style: const TextStyle(
                  color: _muted2,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => _showOrderDetailsSheet(context, order),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _border),
                  ),
                  child: const Icon(
                    Icons.visibility_outlined,
                    color: Color(0xFF2563EB),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Body
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.tableNumber != null
                          ? 'Table ${order.tableNumber}'
                          : 'Customer Name',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: _text,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${order.items.length} items · ${order.notes ?? "DINE IN"}',
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'NRs. ${order.total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: _brand,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (order.paymentStatus != null)
                    _buildPaymentBadge(order.paymentStatus!.name),
                  const SizedBox(height: 12),
                  _buildStatusUpdateButton(context, ref, order),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusUpdateButton(
    BuildContext context,
    WidgetRef ref,
    OrderEntity order,
  ) {
    final isCancelled = order.status == OrderStatus.cancelled;

    return InkWell(
      onTap: isCancelled ? null : () => _showStatusPicker(context, ref, order),
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: isCancelled ? 0.45 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Update ${order.status.name.toUpperCase()}',
                style: const TextStyle(
                  color: _muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _muted,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatusPicker(
    BuildContext context,
    WidgetRef ref,
    OrderEntity order,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          widthFactor: 1, // ✅ Fix full width on web/desktop
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ✅ Reduce height
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

                    const SizedBox(height: 18),

                    const Text(
                      'Update Cooking Status',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Select new cooking status for #ORD-${order.id.substring(order.id.length - 6).toUpperCase()}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          [
                            OrderStatus.pending,
                            OrderStatus.cooking,
                            OrderStatus.cooked,
                          ].map((status) {
                            final isCurrent = order.status == status;
                            return InkWell(
                              onTap: () {
                                ref
                                    .read(
                                      adminDashboardViewModelProvider.notifier,
                                    )
                                    .updateOrderStatus(order.id, status);
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? Colors.orange[50]
                                      : const Color(0xFFF8F9FD),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isCurrent
                                        ? Colors.orange[200]!
                                        : Colors.grey[200]!,
                                  ),
                                ),
                                child: Text(
                                  status.name.toUpperCase(),
                                  style: TextStyle(
                                    color: isCurrent
                                        ? Colors.orange[700]
                                        : Colors.black87,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),

                    const SizedBox(height: 12), // ✅ reduced bottom spacing
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------- Order Details Sheet (unchanged logic) ----------------

  void _showOrderDetailsSheet(BuildContext context, OrderEntity order) {
    final dateStr = order.createdAt != null
        ? DateFormat('M/d/yyyy, h:mm:ss a').format(order.createdAt!)
        : DateFormat('M/d/yyyy, h:mm:ss a').format(DateTime.now());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.8,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
              child: Column(
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
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #ORD-${order.id.substring(order.id.length - 8).toUpperCase()} Details',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: _text,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Summary and item-level notes',
                              style: TextStyle(
                                color: _muted,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F4F8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: _text,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'SUMMARY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.black54,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    'ORDER TYPE',
                    order.notes ?? 'DINE IN',
                    'TABLE / MODE',
                    order.tableNumber != null
                        ? 'Table ${order.tableNumber}'
                        : 'N/A',
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    'ORDER STATUS',
                    order.status.name.toUpperCase(),
                    'PAYMENT STATUS',
                    order.paymentStatus?.name.toUpperCase() ?? 'PENDING',
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    'CREATED AT',
                    dateStr,
                    'TOTAL AMOUNT',
                    'NRs. ${order.total.toStringAsFixed(0)}',
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFFF1F4F8), thickness: 1),
                  const SizedBox(height: 24),
                  const Text(
                    'ITEMS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.black54,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...order.items.map((item) => _buildItemRow(item)),
                  const SizedBox(height: 16),
                  if (order.notes != null && order.notes!.isNotEmpty) ...[
                    const Divider(color: Color(0xFFF1F4F8), thickness: 1),
                    const SizedBox(height: 12),
                    Text(
                      'General Notes: ${order.notes}',
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else
                    const Text(
                      'No item notes added for this order.',
                      style: TextStyle(
                        color: _muted2,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ---------------- Shared UI helpers ----------------

  Widget _buildDetailRow(
    String label1,
    String value1,
    String label2,
    String value2,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label1,
                style: const TextStyle(
                  color: _muted2,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value1,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: _text,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label2,
                style: const TextStyle(
                  color: _muted2,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value2,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: _text,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow(OrderItemEntity item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${item.quantity} × ${item.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: _text,
                  ),
                ),
              ),
              Text(
                'NRs. ${item.total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: _text,
                ),
              ),
            ],
          ),
          if (item.notes != null && item.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Note: ${item.notes}',
                style: const TextStyle(
                  color: _muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Note: No note',
                style: TextStyle(
                  color: _muted2,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentBadge(String status) {
    final isPaid =
        status.toUpperCase() == 'PAID' || status.toUpperCase() == 'SUCCESS';
    final color = isPaid ? const Color(0xFF10B981) : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha((0.12 * 255).toInt()),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  // ---------------- Desktop table (kept same structure; only page bg changed) ----------------

  Widget _buildV3OrderTable(List<OrderEntity> orders, WidgetRef ref) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFFF9FAFB),
                ),
                columnSpacing: 40,
                columns: const [
                  DataColumn(
                    label: Text(
                      'Order ID',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Waiter Name',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Table No.',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Status',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Actions',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
                rows: orders.map((order) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          '#ORD-${order.id.substring(order.id.length - 4).toUpperCase()}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      DataCell(Text(order.waiterName ?? 'Saugat Shahi')),
                      DataCell(Text('T-${order.tableNumber ?? "02"}')),
                      DataCell(_buildStatusBadge(order.status.name)),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: Colors.blue,
                              ),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: Colors.red,
                              ),
                              onPressed: () {},
                            ),
                            const SizedBox(width: 8),
                            _buildTableButton('View', Colors.green, () {}),
                            const SizedBox(width: 8),
                            _buildTableButton('Send', Colors.blue, () {}),
                          ],
                        ),
                      ),
                    ],
                  );
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
        color: color.withAlpha((0.10 * 255).toInt()),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    final statusStr = status.toUpperCase();
    switch (statusStr) {
      case 'PENDING':
        color = _brand;
        break;
      case 'COOKING':
        color = const Color(0xFF8B5CF6);
        break;
      case 'SERVED':
        color = const Color(0xFF10B981);
        break;
      case 'COMPLETED':
        color = const Color(0xFF10B981);
        break;
      case 'CANCELLED':
        color = const Color(0xFFEF4444);
        break;
      default:
        color = Colors.grey;
    }

    return Text(
      statusStr,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900),
    );
  }
}

// ---------------- Filter Sheet (unchanged logic, small style alignment) ----------------

class _FilterSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminDashboardViewModelProvider);
    final notifier = ref.read(adminDashboardViewModelProvider.notifier);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
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
                  'Filter Orders',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    notifier.clearFilters();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      color: Color(0xFFFF7D29),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Refine your orders view',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'ORDER STATUS',
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
                  _FilterChip(
                    label: 'All',
                    isSelected: state.selectedStatus == null,
                    onTap: () {
                      notifier.setStatusFilter(null);
                      Navigator.pop(context);
                    },
                  ),
                  ...OrderStatus.values.map(
                    (status) => Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: _FilterChip(
                        label: status.name.toUpperCase(),
                        isSelected: state.selectedStatus == status,
                        onTap: () {
                          notifier.setStatusFilter(status);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'PAYMENT STATUS',
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
                  _FilterChip(
                    label: 'All',
                    isSelected: state.selectedPaymentStatus == null,
                    onTap: () {
                      notifier.setPaymentStatusFilter(null);
                      Navigator.pop(context);
                    },
                  ),
                  ...PaymentStatus.values.map(
                    (status) => Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: _FilterChip(
                        label: status.name.toUpperCase(),
                        isSelected: state.selectedPaymentStatus == status,
                        onTap: () {
                          notifier.setPaymentStatusFilter(status);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF7D29) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF7D29)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF111827),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
