import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/admin_dashboard_view_model.dart';
import '../state/admin_dashboard_state.dart';
import 'package:intl/intl.dart';

class AdminOverviewPage extends ConsumerWidget {
  const AdminOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminDashboardViewModelProvider);
    final stats = state.adminStatistics;

    if (state.status == AdminDashboardStatus.loading && stats == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final isMobile = availableWidth < 700;
        final isTablet = availableWidth >= 700 && availableWidth < 1100;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16.0 : 32.0,
            vertical: isMobile ? 24.0 : 40.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, availableWidth),
              SizedBox(height: isMobile ? 24 : 48),
              _buildStatGrid(context, state, isMobile, isTablet),
              SizedBox(height: isMobile ? 32 : 48),
              if (isMobile) ...[
                _buildRevenueChart(context, state, isMobile),
                const SizedBox(height: 32),
                _buildTopProducts(context, state, isMobile),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildRevenueChart(context, state, isMobile)),
                    const SizedBox(width: 32),
                    Expanded(flex: 1, child: _buildTopProducts(context, state, isMobile)),
                  ],
                ),
              SizedBox(height: isMobile ? 32 : 48),
              _buildRecentOrders(context, state, isMobile),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, double availableWidth) {
    final isMobile = availableWidth < 700;
    
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderTitle(context, isMobile),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildDateFilter(),
              _buildDownloadButton(),
            ],
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildHeaderTitle(context, isMobile)),
        const SizedBox(width: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDateFilter(),
            const SizedBox(width: 16),
            _buildDownloadButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderTitle(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Restaurant Overview',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: -1,
                fontSize: isMobile ? 24 : null,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Track your performance and growth',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: isMobile ? 13 : 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDateFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded, size: 16, color: Colors.orange),
          const SizedBox(width: 10),
          Text(
            'Last 30 Days',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildDownloadButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: IconButton(
        onPressed: () {},
        icon: const Icon(Icons.file_download_outlined, color: Colors.orange),
        tooltip: 'Download Report',
      ),
    );
  }

  Widget _buildStatGrid(BuildContext context, AdminDashboardState state, bool isMobile, bool isTablet) {
    final stats = state.adminStatistics;
    final currencyFormat = NumberFormat.currency(symbol: 'रू ', decimalDigits: 0);

    return GridView.count(
      crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 2), 
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: isMobile ? 16 : 32,
      mainAxisSpacing: isMobile ? 16 : 32,
      childAspectRatio: isMobile ? 2.8 : (isTablet ? 1.8 : 2.2),
      children: [
        _buildStatCard(
          context,
          'Total Revenue',
          currencyFormat.format(stats?.totalRevenue ?? 0),
          Icons.payments_rounded,
          const Color(0xFF6366F1),
          12.5,
          isMobile,
        ),
        _buildStatCard(
          context,
          'Total Orders',
          '${stats?.totalOrders ?? 0}',
          Icons.shopping_cart_rounded,
          const Color(0xFFF59E0B),
          5.2,
          isMobile,
        ),
        _buildStatCard(
          context,
          'Total Products',
          '${stats?.productsCount ?? 0}',
          Icons.restaurant_menu_rounded,
          const Color(0xFF10B981),
          -2.1,
          isMobile,
        ),
        _buildStatCard(
          context,
          'Active Tables',
          '${stats?.occupiedTables ?? 0}/${stats?.tablesTotal ?? 0}',
          Icons.table_restaurant_rounded,
          const Color(0xFF8B5CF6),
          0,
          isMobile,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    double trendPercentage,
    bool isMobile,
  ) {
    final isPositive = trendPercentage >= 0;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: isMobile ? 24 : 32),
          ),
          SizedBox(width: isMobile ? 12 : 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 12 : 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (trendPercentage != 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                              size: 10,
                              color: isPositive ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${trendPercentage.abs().toInt()}%',
                              style: TextStyle(
                                color: isPositive ? Colors.green[700] : Colors.red[700],
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }

  Widget _buildRevenueChart(BuildContext context, AdminDashboardState state, bool isMobile) {
    return Container(
      constraints: BoxConstraints(maxHeight: isMobile ? 400 : 480),
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Revenue Growth',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tracking daily revenue performance',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_graph_rounded, color: Colors.orange, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _RevenueChartPainter(),
            ),
          ),
          const SizedBox(height: 24),
          _buildChartLabels(),
        ],
      ),
    );
  }

  Widget _buildChartLabels() {
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels.map((label) => Text(
        label,
        style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.w600),
      )).toList(),
    );
  }

  Widget _buildTopProducts(BuildContext context, AdminDashboardState state, bool isMobile) {
    return Container(
      constraints: BoxConstraints(maxHeight: isMobile ? 400 : 480),
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Selling Products',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your best performing items this month',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: state.categorySales.isEmpty
                ? Center(child: Text('No sales data yet', style: TextStyle(color: Colors.grey[300])))
                : ListView.builder(
                    itemCount: (state.categorySales.length > 5 ? 5 : state.categorySales.length),
                    itemBuilder: (context, index) {
                      final item = state.categorySales[index];
                      return _buildProductItem(index + 1, item.name, 'रु ${item.value.toStringAsFixed(0)}', item.value / (state.adminStatistics?.totalRevenue ?? 1));
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(int rank, String name, String sales, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 15),
                    ),
                    Text(
                      sales,
                      style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey[100],
                  valueColor: const AlwaysStoppedAnimation(Colors.orange),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(BuildContext context, AdminDashboardState state, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRecentOrdersHeader(isMobile),
          const SizedBox(height: 24),
          if (state.orders.isEmpty)
            _buildEmptyOrdersState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (state.orders.length > 5 ? 5 : state.orders.length),
              separatorBuilder: (_, __) => Divider(color: Colors.grey[50], height: 1),
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return _buildOrderRow(order, isMobile);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersHeader(bool isMobile) {
    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Performance',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black87),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All Activities', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Performance',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('View All Activities'),
                style: TextButton.styleFrom(foregroundColor: Colors.orange),
              ),
            ],
          );
  }

  Widget _buildEmptyOrdersState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[200]),
            const SizedBox(height: 16),
            Text('No recent orders discovered', style: TextStyle(color: Colors.grey[400])),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderRow(dynamic order, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          _buildInitialsAvatar(order.tableNumber != null ? 'T${order.tableNumber}' : 'O'),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.tableNumber != null ? 'Table ${order.tableNumber}' : 'Takeaway',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '#${order.id.substring(order.id.length - 6).toUpperCase()}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'रू ${order.total.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const SizedBox(height: 4),
              _buildStatusBadge(order.status.name),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsAvatar(String text) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _RevenueChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final shadowPaint = Paint()
      ..color = Colors.orange.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final path = Path();
    final points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.15, size.height * 0.8),
      Offset(size.width * 0.3, size.height * 0.4),
      Offset(size.width * 0.45, size.height * 0.6),
      Offset(size.width * 0.6, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.45),
      Offset(size.width, size.height * 0.2),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    
    for (var i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final cp1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final cp2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
    }

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);

    // Draw gradient area
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.orange.withOpacity(0.2), Colors.orange.withOpacity(0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey[100]!
      ..strokeWidth = 1;

    for (var i = 0; i < 5; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
