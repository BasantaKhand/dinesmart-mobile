import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/cashier_dashboard_view_model.dart';
import '../state/cashier_dashboard_state.dart';
import '../widgets/payment_queue_section.dart';
import '../widgets/recent_settlements_section.dart';
import '../../../auth/presentation/widgets/user_profile_drop_down.dart';

class CashierDashboardPage extends ConsumerWidget {
  const CashierDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cashierDashboardViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cashier Desk', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const Text('Payment Control', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/logos/logo.png',
            height: 32,
            errorBuilder: (c, e, s) => Container(
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.restaurant, color: Colors.white, size: 20),
            ),
          ),
        ),
        actions: const [
          UserProfileDropDown(),
          SizedBox(width: 8),
        ],
      ),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, CashierDashboardState state) {
    if (state.status == CashierDashboardStatus.loading && state.stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(cashierDashboardViewModelProvider.notifier).refresh(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today, Thursday, Feb 26',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Track collections, settle bills, and close tables.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),
            
            _buildStatCard(
              label: 'COLLECTIONS TODAY',
              value: 'NRs. ${state.stats?.collectionsToday.toInt() ?? 0}',
              icon: Icons.account_balance_wallet_outlined,
              color: Colors.teal,
              subtitle: state.stats?.collectionsToday == 0 ? 'No settlements yet' : 'Total collected',
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              label: 'PENDING PAYMENTS',
              value: '${state.stats?.pendingPayments ?? 0}',
              icon: Icons.access_time,
              color: Colors.orange,
              subtitle: 'Awaiting settlement',
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              label: 'AVG BILL SIZE',
              value: 'NRs. ${state.stats?.avgBillSize.toInt() ?? 0}',
              icon: Icons.receipt_outlined,
              color: Colors.blue,
              subtitle: 'Per payment avg',
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              label: 'CASH DRAWER',
              value: 'NRs. ${state.stats?.cashInDrawer.toInt() ?? 0}',
              icon: Icons.money,
              color: Colors.purple,
              subtitle: 'Cash collected today',
            ),
            
            const SizedBox(height: 32),
            const PaymentQueueSection(),
            const SizedBox(height: 24),
            const RecentSettlementsSection(),
            const SizedBox(height: 100), // Extra space
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                const SizedBox(height: 10),
                Text(
                  value,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.north_east, size: 14, color: color),
                    const SizedBox(width: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ],
      ),
    );
  }
}

