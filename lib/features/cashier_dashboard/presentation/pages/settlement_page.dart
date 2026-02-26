import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dinesmart_app/app/theme/app_colors.dart';
import 'package:dinesmart_app/core/utils/snackbar_utils.dart';
import 'package:dinesmart_app/features/cashier_dashboard/domain/entities/cashier_entities.dart';
import 'package:dinesmart_app/features/cashier_dashboard/presentation/view_model/cashier_dashboard_view_model.dart';
import 'package:dinesmart_app/features/cashier_dashboard/presentation/state/cashier_dashboard_state.dart';

class SettlementPage extends ConsumerStatefulWidget {
  final PaymentQueueItem item;

  const SettlementPage({super.key, required this.item});

  @override
  ConsumerState<SettlementPage> createState() => _SettlementPageState();
}

class _SettlementPageState extends ConsumerState<SettlementPage> {
  final _transactionController = TextEditingController();
  String _paymentMethod = 'QR';

  @override
  void dispose() {
    _transactionController.dispose();
    super.dispose();
  }

  Future<void> _handleMarkPaid() async {
    await ref.read(cashierDashboardViewModelProvider.notifier).markOrderPaid(
          widget.item.orderId,
          transactionId: _transactionController.text,
          paymentMethod: _paymentMethod,
        );

    if (ref.read(cashierDashboardViewModelProvider).errorMessage == null) {
      SnackbarUtils.showSuccess(context, 'Payment settled successfully');
      Navigator.pop(context);
    } else {
      SnackbarUtils.showError(context, ref.read(cashierDashboardViewModelProvider).errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(cashierDashboardViewModelProvider).status == CashierDashboardStatus.loading;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Settlement', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInvoiceHeader(),
            const SizedBox(height: 24),
            _buildBilledToCard(),
            const SizedBox(height: 24),
            const Text('ORDER ITEMS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 12),
            _buildOrderItemsList(),
            const SizedBox(height: 24),
            const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              'Please confirm payment before closing the table.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            _buildBillSummary(),
            const SizedBox(height: 32),
            if (_paymentMethod == 'QR') _buildQRCodeSection(),
            const SizedBox(height: 32),
            _buildTransactionInput(),
            const SizedBox(height: 40),
            _buildActionButtons(isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(flex: 4, child: Text('ITEM', style: _labelStyle)),
              Expanded(flex: 1, child: Text('QTY', style: _labelStyle)),
              Expanded(flex: 2, child: Text('PRICE', style: _labelStyle)),
              Expanded(flex: 2, child: Text('TOTAL', style: _labelStyle, textAlign: TextAlign.end)),
            ],
          ),
          const Divider(height: 24),
          ...widget.item.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (item.notes != null && item.notes!.isNotEmpty)
                            Text(item.notes!, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                        ],
                      ),
                    ),
                    Expanded(flex: 1, child: Text(item.quantity.toString())),
                    Expanded(flex: 2, child: Text('NRs. ${item.price.toInt()}')),
                    Expanded(
                        flex: 2,
                        child: Text('NRs. ${item.total.toInt()}',
                            style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.end)),
                  ],
                ),
              )),
          if (widget.item.items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text('No items found', style: TextStyle(color: Colors.grey[400])),
            ),
        ],
      ),
    );
  }

  static const _labelStyle = TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5);

  Widget _buildInvoiceHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('INVOICE', style: TextStyle(color: Colors.grey[400], letterSpacing: 1.2, fontWeight: FontWeight.bold, fontSize: 12)),
            Text('Invoice #ORD-${widget.item.orderId.substring(widget.item.orderId.length - 6).toUpperCase()}', 
                style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Active Restaurant',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text('Payment Receipt', style: TextStyle(color: Colors.grey[500])),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Date: 2/24/2026', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Table: T-${widget.item.tableNumber}', style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildBilledToCard() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BILLED TO', style: TextStyle(color: Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Walk-in Guest', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Order items as listed', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PAYMENT', style: TextStyle(color: Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Pending', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                Text('Method: $_paymentMethod', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBillSummary() {
    final subtotal = widget.item.amount / 1.13;
    final tax = widget.item.amount - subtotal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', 'NRs. ${subtotal.toInt()}'),
          const SizedBox(height: 12),
          _buildSummaryRow('VAT (13%)', 'NRs. ${tax.toInt()}'),
          const Divider(height: 32),
          _buildSummaryRow('Total', 'NRs. ${widget.item.amount.toInt()}', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
          fontSize: isTotal ? 20 : 16,
          fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
        )),
        Text(value, style: TextStyle(
          fontSize: isTotal ? 22 : 16,
          fontWeight: FontWeight.bold,
          color: isTotal ? AppColors.primary : Colors.black,
        )),
      ],
    );
  }

  Widget _buildQRCodeSection() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Image.asset('assets/images/mock_qr.png', height: 200, errorBuilder: (c, e, s) => Container(
              width: 200, height: 200, color: Colors.grey[100], child: const Icon(Icons.qr_code_2, size: 100, color: Colors.grey),
            )),
            const SizedBox(height: 16),
            const Text('Scan to pay via ESEWA', style: TextStyle(fontWeight: FontWeight.w500)),
            Text('Restaurant Dinesmart • 97862766652', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Transaction ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: _transactionController,
          decoration: InputDecoration(
            hintText: 'Customer payment reference',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: Colors.white,
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
        const SizedBox(height: 4),
        Text('Optional for manual verification if webhook is not enabled.', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
      ],
    );
  }

  Widget _buildActionButtons(bool isLoading) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              // Print logic
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            child: const Text('Print Bill', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleMarkPaid,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 20),
                      SizedBox(width: 8),
                      Text('Mark Paid', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
