import 'package:dinesmart_app/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/order_entity.dart';
import '../state/waiter_dashboard_state.dart';
import '../view_model/waiter_dashboard_view_model.dart';

class BillSummarySheet extends ConsumerWidget {
  final WaiterDashboardState state;
  final VoidCallback onCreateOrder;

  const BillSummarySheet({
    super.key,
    required this.state,
    required this.onCreateOrder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartSubtotal = state.cart.fold(0.0, (acc, item) => acc + item.total);
    final cartTax = cartSubtotal * 0.13;

    final activeSubtotal = state.activeOrder?.subtotal ?? 0.0;
    final activeTax = state.activeOrder?.tax ?? 0.0;
    final activeTotal = state.activeOrder?.total ?? 0.0;

    final totalSubtotal = activeSubtotal + cartSubtotal;
    final tax = activeTax + cartTax;
    final total = activeTotal + cartSubtotal + cartTax;

    final isExpanded = state.isBillExpanded;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      constraints: BoxConstraints(
        maxHeight: isExpanded ? MediaQuery.of(context).size.height * 0.54 : 132,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: isExpanded
          ? Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => ref
                      .read(waiterDashboardViewModelProvider.notifier)
                      .toggleBillExpansion(),
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
                              'Bill Summary',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.activeOrder != null)
                        Row(
                          children: [
                            Text(
                              '#${state.activeOrder!.id.substring(state.activeOrder!.id.length - 6).toUpperCase()}',
                              style: const TextStyle(
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.schedule_outlined,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              state.activeOrder!.createdAt != null
                                  ? '${state.activeOrder!.createdAt!.year}-${state.activeOrder!.createdAt!.month.toString().padLeft(2, '0')}-${state.activeOrder!.createdAt!.day.toString().padLeft(2, '0')} ${state.activeOrder!.createdAt!.hour.toString().padLeft(2, '0')}:${state.activeOrder!.createdAt!.minute.toString().padLeft(2, '0')}'
                                  : DateTime.now().toString().split('.')[0],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      if (state.activeOrder != null) const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.restaurant_menu,
                            color: Colors.orange,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Recipient : Table ${state.selectedTable?.number ?? "-"}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                if (state.activeOrder != null)
                  _buildStatusCard(ref, state.activeOrder!.status),

                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.activeOrder != null &&
                            state.activeOrder!.items.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _buildSectionHeader(
                            'Order Items (${state.activeOrder!.items.length})',
                          ),
                          ...state.activeOrder!.items.map(
                            (item) => _buildItemRow(item, isKitchen: true),
                          ),
                        ],
                        if (state.cart.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _buildSectionHeader(
                            'New Items (${state.cart.length})',
                          ),
                          ...state.cart.map(
                            (item) => _buildItemRow(
                              item,
                              isKitchen: false,
                              onEditNote: () => _showNoteEditor(
                                context,
                                initialValue: item.notes,
                                onSave: (value) => ref
                                    .read(
                                      waiterDashboardViewModelProvider.notifier,
                                    )
                                    .updateCartItemNote(item.menuItemId, value),
                              ),
                              onRemove: () => ref
                                  .read(
                                    waiterDashboardViewModelProvider.notifier,
                                  )
                                  .removeFromCart(item.menuItemId),
                            ),
                          ),
                        ],
                        // Empty state when no items in order
                        if (state.cart.isEmpty &&
                            (state.activeOrder == null ||
                                state.activeOrder!.items.isEmpty))
                          _buildEmptyOrderState(),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: Column(
                    children: [
                      _buildTotalRow(
                        'Subtotal',
                        'NRs. ${totalSubtotal.toInt()}',
                      ),
                      const SizedBox(height: 8),
                      _buildTotalRow('Tax 13% (VAT)', 'NRs. ${tax.toInt()}'),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'NRs. ${total.toInt()}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (state.cart.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed:
                                _canAddMoreItems(state.activeOrder?.status)
                                ? onCreateOrder
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Send to Kitchen',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
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
            )
          : GestureDetector(
              onTap: () => ref
                  .read(waiterDashboardViewModelProvider.notifier)
                  .toggleBillExpansion(),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
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
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Bill Summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'NRs. ${total.toInt()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.keyboard_arrow_up,
                              color: Colors.grey,
                              size: 22,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (state.activeOrder != null)
                      Row(
                        children: [
                          Text(
                            'ORDER STATUS',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _mapStatusToColor(
                                _orderStatusLabel(state.activeOrder!.status),
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _orderStatusLabel(state.activeOrder!.status),
                              style: TextStyle(
                                color: _mapStatusToColor(
                                  _orderStatusLabel(state.activeOrder!.status),
                                ),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )
                    else if (state.cart.isNotEmpty)
                      const Text(
                        'Draft order · Not sent to kitchen',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Tap items from menu to add',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _showNoteEditor(
    BuildContext context, {
    String? initialValue,
    required ValueChanged<String> onSave,
  }) async {
    final controller = TextEditingController(text: initialValue ?? '');

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.edit_note_outlined,
                      color: Colors.grey[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Add Note',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Special instructions for kitchen',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  autofocus: true,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'e.g. No onions, extra spicy...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[400]!,
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        onPressed: () =>
                            Navigator.of(dialogContext).pop(controller.text),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Save Note',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result != null) {
      onSave(result);
    }
  }

  bool _canAddMoreItems(OrderStatus? status) {
    if (status == null) return true;
    return status != OrderStatus.completed &&
        status != OrderStatus.cancelled &&
        status != OrderStatus.billPrinted;
  }

  String _orderStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'PENDING';
      case OrderStatus.cooking:
        return 'COOKING';
      case OrderStatus.cooked:
        return 'COOKED';
      case OrderStatus.served:
        return 'SERVED';
      case OrderStatus.billPrinted:
        return 'BILL_PRINTED';
      case OrderStatus.completed:
        return 'COMPLETED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
    }
  }

  Widget _buildStatusCard(WidgetRef ref, OrderStatus orderStatus) {
    final status = _orderStatusLabel(orderStatus);
    Color color;
    switch (status) {
      case 'PENDING':
        color = Colors.amber[700]!;
        break;
      case 'COOKING':
        color = Colors.blue[600]!;
        break;
      case 'COOKED':
        color = Colors.cyan[700]!;
        break;
      case 'SERVED':
        color = Colors.teal[600]!;
        break;
      case 'BILL_PRINTED':
        color = Colors.indigo[600]!;
        break;
      case 'COMPLETED':
        color = Colors.green[600]!;
        break;
      case 'CANCELLED':
        color = Colors.red[600]!;
        break;
      default:
        color = Colors.grey[600]!;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ORDER STATUS',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          if (orderStatus == OrderStatus.cooked)
            ElevatedButton.icon(
              onPressed: () => ref
                  .read(waiterDashboardViewModelProvider.notifier)
                  .markOrderServed(),
              icon: const Icon(
                Icons.room_service_outlined,
                size: 14,
                color: Colors.white,
              ),
              label: const Text(
                'Serve',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          else if (orderStatus == OrderStatus.pending)
            ElevatedButton.icon(
              onPressed: () => ref
                  .read(waiterDashboardViewModelProvider.notifier)
                  .cancelPendingOrder(),
              icon: const Icon(
                Icons.cancel_outlined,
                size: 14,
                color: Colors.white,
              ),
              label: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF2D55),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          else if (orderStatus == OrderStatus.served)
            ElevatedButton.icon(
              onPressed: () => ref
                  .read(waiterDashboardViewModelProvider.notifier)
                  .markOrderCompleted(),
              icon: const Icon(
                Icons.check_circle_outline,
                size: 14,
                color: Colors.white,
              ),
              label: const Text(
                'Complete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A86B),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
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
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyOrderState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 36,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'No items yet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap menu items to add to order',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(
    dynamic item, {
    required bool isKitchen,
    VoidCallback? onEditNote,
    VoidCallback? onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  image:
                      item.imageUrl != null && item.imageUrl.toString().isNotEmpty
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(item.imageUrl.toString()),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: item.imageUrl == null || item.imageUrl.toString().isEmpty
                    ? Center(
                        child: Icon(
                          Icons.fastfood_outlined,
                          color: Colors.grey[400],
                          size: 22,
                        ),
                      )
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${item.quantity}x',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'NRs. ${(item.price as num).toInt()}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.notes != null &&
                    item.notes.toString().trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.notes.toString(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isKitchen) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _mapStatusToColor(item.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _mapStatusToLabel(item.status),
                style: TextStyle(
                  color: _mapStatusToColor(item.status),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          if (!isKitchen) ...[
            // Action buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: onEditNote,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.edit_note_outlined,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                if (onRemove != null)
                  InkWell(
                    onTap: onRemove,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.red[400],
                      ),
                    ),
                  ),
              ],
            ),
          ],
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
      case 'PENDING':
        return Colors.amber[700]!;
      case 'COOKING':
      case 'PREPARING':
        return Colors.blue[600]!;
      case 'COOKED':
        return Colors.cyan[700]!;
      case 'SERVED':
        return Colors.teal[600]!;
      case 'READY':
        return Colors.green[600]!;
      case 'BILL_PRINTED':
        return Colors.indigo[600]!;
      case 'COMPLETED':
        return Colors.green[600]!;
      case 'CANCELLED':
        return Colors.red[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  Widget _buildTotalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
