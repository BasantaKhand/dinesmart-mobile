import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/cashier_dashboard_view_model.dart';

class TodaySettlementSection extends ConsumerWidget {
  const TodaySettlementSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cashierDashboardViewModelProvider);
    final settlement = state.todaySettlement;

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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.analytics_outlined, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Today's Settlement",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (settlement == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No settlement data yet', style: TextStyle(color: Colors.grey)),
              ),
            )
          else ...[
            // Total Collection
            _buildRow('Total Collection', 'NRs. ${settlement.totalCollection.toInt()}', isBold: true, color: Colors.teal),
            const Divider(height: 24),

            // Breakdown
            _buildRow('Total Bills', '${settlement.totalBills}'),
            const SizedBox(height: 10),
            _buildRow('Cash', 'NRs. ${settlement.cashAmount.toInt()}', icon: Icons.money, iconColor: Colors.green),
            const SizedBox(height: 10),
            _buildRow('QR / Digital', 'NRs. ${settlement.qrAmount.toInt()}', icon: Icons.qr_code, iconColor: Colors.blue),
            const SizedBox(height: 10),
            _buildRow('Card', 'NRs. ${settlement.cardAmount.toInt()}', icon: Icons.credit_card, iconColor: Colors.purple),

            if (settlement.openingAmount > 0) ...[
              const Divider(height: 24),
              _buildRow('Opening Amount', 'NRs. ${settlement.openingAmount.toInt()}'),
              const SizedBox(height: 10),
              _buildRow('Expected Cash', 'NRs. ${settlement.expectedCash.toInt()}'),
              const SizedBox(height: 10),
              _buildRow(
                'Variance',
                'NRs. ${settlement.variance.toInt()}',
                color: settlement.variance == 0 ? Colors.green : Colors.red,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
    IconData? icon,
    Color? iconColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: iconColor ?? Colors.grey[600]),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isBold ? 15 : 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isBold ? 18 : 15,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }
}
