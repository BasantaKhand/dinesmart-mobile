import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/order_entity.dart';
import '../state/waiter_dashboard_state.dart';
import '../view_model/waiter_dashboard_view_model.dart';

class BillSummarySheet extends ConsumerWidget {
  final WaiterDashboardState state;
  final VoidCallback onCreateOrder;
  final VoidCallback onPrintBill;

  const BillSummarySheet({
    super.key,
    required this.state,
    required this.onCreateOrder,
    required this.onPrintBill,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtotalCart = state.cart.fold(0.0, (acc, item) => acc + item.total);
    final subtotalActive = state.activeOrder?.subtotal ?? 0.0;
    
    // Calculate total based on both active order and current cart
    final totalSubtotal = subtotalCart + subtotalActive;
    final tax = totalSubtotal * 0.13;
    final total = totalSubtotal + tax;

    final isExpanded = state.isBillExpanded;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      constraints: BoxConstraints(
        maxHeight: isExpanded 
          ? MediaQuery.of(context).size.height * 0.8 
          : 120, // Contracted height
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle/Indicator - Tappable to toggle
          GestureDetector(
            onTap: () => ref.read(waiterDashboardViewModelProvider.notifier).toggleBillExpansion(),
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        (state.activeOrder != null && state.activeOrder!.status == OrderStatus.COMPLETED) 
                          ? 'View & Print Bill' 
                          : 'Bill Summary',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          if (!isExpanded) ...[
                            Text(
                              'NRs. ${total.toInt()}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 16),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Icon(
                            isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up, 
                            color: Colors.grey,
                            size: 28,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.restaurant_menu, color: Colors.orange, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recipient : Table ${state.selectedTable?.number ?? "-"}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateTime.now().toString().split('.')[0], // Simple date display
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      if (state.activeOrder != null)
                        Text(
                          '#${state.activeOrder?.id.substring(state.activeOrder!.id.length - 6).toUpperCase() ?? ""}',
                          style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            if (state.activeOrder != null)
              _buildStatusCard('ORDER STATUS', state.activeOrder!.status.name),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.activeOrder != null && state.activeOrder!.items.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildSectionHeader('ORDER ITEMS (${state.activeOrder!.items.length})'),
                      ...state.activeOrder!.items.map((item) => _buildItemRow(item, isKitchen: true)),
                    ],
                    if (state.cart.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildSectionHeader('CURRENT SELECTION (${state.cart.length})'),
                      ...state.cart.map((item) => _buildItemRow(item, isKitchen: false)),
                    ],
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                children: [
                  _buildTotalRow('Subtotal', 'NRs. ${totalSubtotal.toInt()}'),
                  const SizedBox(height: 8),
                  _buildTotalRow('Tax 13% (VAT)', 'NRs. ${tax.toInt()}'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'NRs. ${total.toInt()}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (state.cart.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: onCreateOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Send to Kitchen',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (state.activeOrder != null)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: state.activeOrder!.status == OrderStatus.COMPLETED 
                            ? onPrintBill 
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: state.activeOrder!.status == OrderStatus.BILL_PRINTED
                              ? const Color(0xFF00C569) // Green
                              : (state.activeOrder!.status == OrderStatus.COMPLETED ? Colors.orange : Colors.grey[300]),
                          disabledBackgroundColor: state.activeOrder!.status == OrderStatus.BILL_PRINTED
                              ? const Color(0xFF00C569)
                              : Colors.grey[200],
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              state.activeOrder!.status == OrderStatus.BILL_PRINTED
                                  ? Icons.check_circle
                                  : (state.activeOrder!.status == OrderStatus.COMPLETED 
                                      ? Icons.print_outlined 
                                      : Icons.timer_outlined),
                              color: state.activeOrder!.status == OrderStatus.PENDING || state.activeOrder!.status == OrderStatus.COOKING || state.activeOrder!.status == OrderStatus.SERVED 
                                  ? Colors.grey[600] 
                                  : Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              state.activeOrder!.status == OrderStatus.BILL_PRINTED
                                  ? 'Bill Printed ✓'
                                  : (state.activeOrder!.status == OrderStatus.COMPLETED 
                                      ? 'View Bill & Print' 
                                      : (state.activeOrder!.status == OrderStatus.COOKING || state.activeOrder!.status == OrderStatus.SERVED ? 'Items in Kitchen' : 'Processing...')),
                              style: TextStyle(
                                color: state.activeOrder!.status == OrderStatus.PENDING || state.activeOrder!.status == OrderStatus.COOKING || state.activeOrder!.status == OrderStatus.SERVED 
                                    ? Colors.grey[600] 
                                    : Colors.white, 
                                fontSize: 16, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard(String label, String status) {
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
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: color),
              const SizedBox(width: 8),
              Text(status, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildItemRow(dynamic item, {required bool isKitchen}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${item.quantity}x',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                if (!isKitchen)
                  const Text('Pending send...', style: TextStyle(color: Colors.orange, fontSize: 10)),
              ],
            ),
          ),
          if (isKitchen)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _mapStatusToColor(item.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _mapStatusToLabel(item.status),
                style: TextStyle(
                  color: _mapStatusToColor(item.status),
                  fontSize: 10, 
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _mapStatusToLabel(dynamic status) {
    if (status == null) return 'Processing';
    if (status is OrderStatus) return status.name;
    if (status == 'PREPARING') return 'Preparing';
    if (status == 'READY') return 'Ready';
    return status.toString();
  }

  Color _mapStatusToColor(dynamic status) {
    if (status == null) return Colors.grey;
    String statusStr = status.toString();
    if (status is OrderStatus) statusStr = status.name;

    switch (statusStr) {
      case 'PENDING': return Colors.amber[700]!;
      case 'COOKING':
      case 'PREPARING': return Colors.blue[600]!;
      case 'SERVED': return Colors.teal[600]!;
      case 'READY': return Colors.green[600]!;
      case 'BILL_PRINTED': return Colors.indigo[600]!;
      case 'COMPLETED': return Colors.green[600]!;
      case 'CANCELLED': return Colors.red[600]!;
      default: return Colors.grey[600]!;
    }
  }

  Widget _buildTotalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
