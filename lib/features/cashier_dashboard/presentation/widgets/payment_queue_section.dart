import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/cashier_dashboard_view_model.dart';
import '../pages/settlement_page.dart';
import '../../domain/entities/cashier_entities.dart';

class PaymentQueueSection extends ConsumerWidget {
  const PaymentQueueSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cashierDashboardViewModelProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Queue',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Bills waiting at the cashier counter',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by order or table',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => ref.read(cashierDashboardViewModelProvider.notifier).refresh(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: const Text('Refresh', style: TextStyle(color: Colors.black54)),
            ),
          ),
          const SizedBox(height: 16),
          if (state.paymentQueue.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[100]!),
              ),
              child: const Center(
                child: Text(
                  'No pending payments right now.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            Column(
              children: [
                _buildTableHeader(),
                const Divider(height: 1),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.paymentQueue.length,
                  separatorBuilder: (context, index) => Divider(color: Colors.grey[100], height: 1),
                  itemBuilder: (context, index) {
                    final item = state.paymentQueue[index];
                    return _buildQueueRow(context, item);
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('Order', style: _tableHeaderStyle)),
          Expanded(flex: 2, child: Text('Table', style: _tableHeaderStyle)),
          Expanded(flex: 1, child: Text('Items', style: _tableHeaderStyle)),
          Expanded(flex: 2, child: Text('Channel', style: _tableHeaderStyle)),
          Expanded(flex: 3, child: Text('Status', style: _tableHeaderStyle)),
          Expanded(flex: 2, child: Text('Total', style: _tableHeaderStyle, textAlign: TextAlign.right)),
          const SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _buildQueueRow(BuildContext context, PaymentQueueItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'ORD-${item.orderId.substring(item.orderId.length - 6).toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text('T-${item.tableNumber}', style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 1,
            child: Text(item.itemCount.toString()),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
              child: const Text('CASH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey), textAlign: TextAlign.center),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1), 
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Waiting', 
                    style: TextStyle(
                      color: Colors.orange, 
                      fontSize: 10, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text('1 min ago', style: TextStyle(color: Colors.grey[400], fontSize: 10)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'NRs. ${item.amount.toInt()}',
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(
            width: 80,
            child: TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SettlementPage(item: item)));
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Settle', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                  SizedBox(width: 4),
                  Icon(Icons.north_east, size: 14, color: Colors.orange),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _tableHeaderStyle = TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1);
}
