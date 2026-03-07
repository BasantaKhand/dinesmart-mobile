import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dinesmart_app/app/theme/app_colors.dart';
import 'package:dinesmart_app/core/utils/snackbar_utils.dart';
import 'package:dinesmart_app/core/sensors/accelerometer_service.dart';
import 'package:dinesmart_app/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:dinesmart_app/features/auth/presentation/pages/login_page.dart';
import 'package:dinesmart_app/app/routes/app_routes.dart';
import '../view_model/cashier_dashboard_view_model.dart';
import '../state/cashier_dashboard_state.dart';
import '../widgets/payment_queue_section.dart';
import '../widgets/recent_settlements_section.dart';
import '../widgets/today_settlement_section.dart';
import '../../../auth/presentation/widgets/user_profile_drop_down.dart';
import '../../../notifications/presentation/widgets/notification_badge.dart';

class CashierDashboardPage extends ConsumerStatefulWidget {
  const CashierDashboardPage({super.key});

  @override
  ConsumerState<CashierDashboardPage> createState() => _CashierDashboardPageState();
}

class _CashierDashboardPageState extends ConsumerState<CashierDashboardPage> {
  late AccelerometerService _accelerometerService;

  @override
  void initState() {
    super.initState();
    _accelerometerService = AccelerometerService();
    _initializeAccelerometerMonitoring();
  }

  /// Initialize accelerometer for logout detection
  void _initializeAccelerometerMonitoring() {
    _accelerometerService.startMonitoring(
      onShakeDetected: _handleShakeLogout,
      threshold: 15.0,
    );
    print('🔴 [CASHIER] Accelerometer monitoring enabled - rotate or shake device to logout');
  }

  /// Handle logout when shake is detected
  Future<void> _handleShakeLogout() async {
    print('🚨 [CASHIER] SHAKE DETECTED - Device motion detected!');
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Device Motion Detected', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to logout?\n\n'
          'Your device movement was detected. This may indicate an unauthorized access attempt.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              print('✅ [CASHIER] User cancelled logout - resumed session');
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.blue, fontSize: 16)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// Perform logout
  void _performLogout() {
    _accelerometerService.stopMonitoring();
    ref.read(authViewModelProvider.notifier).logout();
    AppRoutes.pushAndRemoveUntil(context, const LoginPage());
  }

  @override
  void dispose() {
    _accelerometerService.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cashierDashboardViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/logos/logo.png',
              height: 32,
              errorBuilder: (c, e, s) => Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.restaurant, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'DineSmart',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
         
          const NotificationBadge(),
          const UserProfileDropDown(),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, CashierDashboardState state) {
    if (state.status == CashierDashboardStatus.loading && state.paymentQueue.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == CashierDashboardStatus.error && state.paymentQueue.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(state.errorMessage ?? 'Something went wrong', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(cashierDashboardViewModelProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMM d').format(now);
    final stats = state.stats;

    return RefreshIndicator(
      onRefresh: () => ref.read(cashierDashboardViewModelProvider.notifier).refresh(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Date & subtitle ───
            Text(
              'Today, $dateStr',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Track collections, settle bills, and close tables.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),

            // ─── Stat Cards ───
            _buildStatCard(
              label: 'COLLECTIONS TODAY',
              value: 'NRs. ${stats.collectionsToday.toInt()}',
              icon: Icons.account_balance_wallet_outlined,
              color: Colors.teal,
              subtitle: stats.collectionsToday == 0 ? 'No settlements yet' : '${stats.billsClosedToday} bills closed',
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              label: 'PENDING PAYMENTS',
              value: '${stats.pendingPayments}',
              icon: Icons.access_time,
              color: Colors.orange,
              subtitle: 'Awaiting settlement',
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              label: 'AVG BILL SIZE',
              value: 'NRs. ${stats.avgBillSize.toInt()}',
              icon: Icons.receipt_outlined,
              color: Colors.blue,
              subtitle: 'Per payment avg',
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              label: 'CASH COLLECTED',
              value: 'NRs. ${stats.cashCollected.toInt()}',
              icon: Icons.money,
              color: Colors.purple,
              subtitle: 'Cash collected today',
            ),

            // ─── Cash Drawer Action ───
            const SizedBox(height: 20),
            _buildDrawerSection(context, ref, state),

            // ─── Payment Queue ───
            const SizedBox(height: 24),
            const PaymentQueueSection(),

            // ─── Today Settlement Summary ───
            const SizedBox(height: 24),
            const TodaySettlementSection(),

            // ─── Recent Settlements ───
            const SizedBox(height: 24),
            const RecentSettlementsSection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerSection(BuildContext context, WidgetRef ref, CashierDashboardState state) {
    final drawerOpen = state.drawerStatus?.isOpen ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: drawerOpen ? Colors.green.withValues(alpha: 0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: drawerOpen ? Colors.green.withValues(alpha: 0.3) : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: drawerOpen ? Colors.green.withValues(alpha: 0.1) : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              drawerOpen ? Icons.lock_open : Icons.lock_outline,
              color: drawerOpen ? Colors.green : Colors.grey[600],
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  drawerOpen ? 'Drawer Open' : 'Drawer Closed',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                if (drawerOpen && state.drawerStatus != null)
                  Text(
                    'Opening: NRs. ${state.drawerStatus!.openingAmount.toInt()}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (drawerOpen) {
                _showCloseDrawerDialog(context, ref);
              } else {
                _showOpenDrawerDialog(context, ref);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: drawerOpen ? Colors.red[400] : AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              drawerOpen ? 'Close Drawer' : 'Open Drawer',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _showOpenDrawerDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Open Cash Drawer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Opening Amount (NRs)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount <= 0) {
                SnackbarUtils.showError(context, 'Enter a valid amount');
                return;
              }
              Navigator.pop(ctx);
              ref.read(cashierDashboardViewModelProvider.notifier).openDrawer(
                amount,
                notes: notesController.text.isNotEmpty ? notesController.text : null,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  void _showCloseDrawerDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Close Cash Drawer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Closing Amount (NRs)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount <= 0) {
                SnackbarUtils.showError(context, 'Enter a valid amount');
                return;
              }
              Navigator.pop(ctx);
              ref.read(cashierDashboardViewModelProvider.notifier).closeDrawer(
                amount,
                notes: notesController.text.isNotEmpty ? notesController.text : null,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
            ),
            child: const Text('Close'),
          ),
        ],
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
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
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

