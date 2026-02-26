import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/cashier_dashboard_view_model.dart';

class RecentSettlementsSection extends ConsumerWidget {
  const RecentSettlementsSection({super.key});

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Settlements',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'View All',
                style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (state.recentSettlements.isEmpty)
             const Padding(
               padding: EdgeInsets.symmetric(vertical: 20),
               child: Center(child: Text('No settlements today', style: TextStyle(color: Colors.grey))),
             )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.recentSettlements.length,
              separatorBuilder: (context, index) => Divider(color: Colors.grey[100]),
              itemBuilder: (context, index) {
                final item = state.recentSettlements[index];
                return _buildSettlementItem(item);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSettlementItem(dynamic item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Table ${item.tableNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    '${item.paymentMethod} • ${_formatTime(item.settledAt)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          Text(
            'NRs. ${item.totalAmount.toInt()}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, "0")}';
  }
}
