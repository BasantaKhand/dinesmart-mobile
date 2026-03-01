import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/admin_dashboard_view_model.dart';
import '../state/admin_dashboard_state.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class AdminOverviewPage extends ConsumerWidget {
  const AdminOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminDashboardViewModelProvider);
    final stats = state.adminStatistics;

    if (state.status == AdminDashboardStatus.loading && stats == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.orange));
    }

    return Container(
      color: Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;
  
          return RefreshIndicator(
            onRefresh: () => ref.read(adminDashboardViewModelProvider.notifier).initialize(),
            color: const Color(0xFFFF7D29),
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24.0 : 32.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overview',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Welcome back! Here\'s what\'s happening today.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 32),
                  _buildV3StatGrid(context, state, isMobile),
                  const SizedBox(height: 32),
                  _buildAnalyticsSection(context, state, isMobile),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildV3StatGrid(BuildContext context, AdminDashboardState state, bool isMobile) {
    final stats = state.adminStatistics;
    final width = MediaQuery.of(context).size.width;
    
    // Responsive column count: 2 for mobile, 4 for wide tablets/desktop
    final crossAxisCount = width < 1100 ? 2 : 4;
    
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: width < 1100 ? 1.15 : 1.3,
      children: [
        _buildV3StatCard(
          'Net Revenue', 
          'NRs. ${stats?.totalRevenue.toInt() ?? 0}', 
          Icons.attach_money_rounded, 
          const Color(0xFF10B981), 
          '+0.4% vs last month',
        ),
        _buildV3StatCard(
          'Unpaid Orders', 
          '${state.orders.where((o) => o.status.name == "PENDING").length}', 
          Icons.access_time_filled_rounded, 
          const Color(0xFF3B82F6), 
          '+100% of total orders',
        ),
        _buildV3StatCard(
          'Paid Orders', 
          '${state.orders.where((o) => o.status.name == "COMPLETED").length}', 
          Icons.check_circle_rounded, 
          const Color(0xFFF59E0B), 
          '+0% paid vs total',
        ),
        _buildV3StatCard(
          'Occupied Tables', 
          '2', // Placeholder as per mockup
          Icons.grid_view_rounded, 
          const Color(0xFF8B5CF6), 
          '+17% of total tables',
        ),
      ],
    );
  }

  Widget _buildV3StatCard(String label, String value, IconData icon, Color color, String trend) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
            ],
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.north_east_rounded, color: color, size: 12),
              const SizedBox(width: 4),
              Text(trend, style: TextStyle(color: Colors.grey[400], fontSize: 10, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildV3StatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBDD),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'PENDING',
        style: TextStyle(color: Color(0xFFFF7D29), fontSize: 10, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _buildAnalyticsSection(BuildContext context, AdminDashboardState state, bool isMobile) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 1100;

    final overviewCard = Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sales Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: const Row(
                  children: [
                    Text('Last 30 Days', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    SizedBox(width: 8),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 250,
            width: double.infinity,
            child: CustomPaint(
              painter: _SalesLineChartPainter(),
            ),
          ),
        ],
      ),
    );

    final categoryCard = Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sales by Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              TextButton(
                onPressed: () {},
                child: const Row(
                  children: [
                    Text('View All', style: TextStyle(color: Color(0xFFFF7D29), fontWeight: FontWeight.bold)),
                    Icon(Icons.chevron_right_rounded, color: Color(0xFFFF7D29), size: 18),
                  ],
                ),
              ),
            ],
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Latest orders placed across the restaurant.', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          const SizedBox(height: 32),
          Column(
            children: [
              Center(
                child: SizedBox(
                  height: 180,
                  child: CustomPaint(
                    size: const Size(180, 180),
                    painter: _DonutChartPainter(),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildLegend(),
            ],
          ),
        ],
      ),
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: overviewCard),
          const SizedBox(width: 24),
          Expanded(flex: 2, child: categoryCard),
        ],
      );
    }

    return Column(
      children: [
        overviewCard,
        const SizedBox(height: 24),
        categoryCard,
      ],
    );
  }

  Widget _buildLegend() {
    return const Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: [
        _LegendItem(color: Color(0xFF8B5CF6), label: 'Appetizers'),
        _LegendItem(color: Color(0xFF3B82F6), label: 'Beverages'),
        _LegendItem(color: Color(0xFFF59E0B), label: 'Desserts'),
        _LegendItem(color: Color(0xFFFF7D29), label: 'Main Course'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700], fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _SalesLineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey[100]!
      ..strokeWidth = 1;

    final axisTextStyle = TextStyle(color: Colors.grey[400]!, fontSize: 10, fontWeight: FontWeight.w500);
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);

    // Draw horizontal grid lines and Y-axis labels
    for (var i = 0; i <= 4; i++) {
       final y = size.height - (i * size.height / 4) - 20;
       canvas.drawLine(Offset(40, y), Offset(size.width, y), gridPaint);
       
       textPainter.text = TextSpan(text: 'Rs.$i', style: axisTextStyle);
       textPainter.layout();
       textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
    }

    // Draw line
    final linePaint = Paint()
      ..color = const Color(0xFFFF7D29)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final points = [
      Offset(40, size.height - 20),
      Offset(size.width * 0.4, size.height - 20),
      Offset(size.width * 0.55, size.height - 25), // Slight dip
      Offset(size.width, size.height - 20),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);

    // Draw point indicator
    final activePoint = Offset(size.width * 0.55, size.height - 25);
    canvas.drawCircle(activePoint, 5, Paint()..color = const Color(0xFFFF7D29));
    canvas.drawCircle(activePoint, 3, Paint()..color = Colors.white);

    // Draw Vertical interaction line
    canvas.drawLine(Offset(activePoint.dx, 0), Offset(activePoint.dx, size.height - 20), gridPaint..color = Colors.grey[300]!);

    // Draw Tooltip (Pseudo implementation)
    final tooltipRect = Rect.fromLTWH(activePoint.dx - 40, 40, 80, 50);
    canvas.drawRRect(RRect.fromRectAndRadius(tooltipRect, const Radius.circular(8)), Paint()..color = Colors.white..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    canvas.drawRRect(RRect.fromRectAndRadius(tooltipRect, const Radius.circular(8)), Paint()..color = Colors.white);
    canvas.drawRRect(RRect.fromRectAndRadius(tooltipRect, const Radius.circular(8)), Paint()..color = Colors.grey[200]!..style = PaintingStyle.stroke);

    textPainter.text = const TextSpan(text: 'Feb 18', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w900));
    textPainter.layout();
    textPainter.paint(canvas, Offset(activePoint.dx - 40 + 10, 45));

    textPainter.text = const TextSpan(text: 'Sales: Nrs. 0', style: TextStyle(color: Color(0xFFFF7D29), fontSize: 10, fontWeight: FontWeight.bold));
    textPainter.layout();
    textPainter.paint(canvas, Offset(activePoint.dx - 40 + 10, 62));

    // Draw X-axis labels
    final dates = ['Feb 1', 'Feb 5', 'Feb 9', 'Feb 13', 'Feb 17', 'Feb 21', 'Feb 25', 'Mar 1'];
    for(var i = 0; i < dates.length; i++) {
      final x = 40 + (i * (size.width - 40) / (dates.length - 1));
      textPainter.text = TextSpan(text: dates[i], style: TextStyle(color: Colors.grey[400], fontSize: 9, fontWeight: FontWeight.w600));
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width/2, size.height - 10));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 18.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw segments with gaps for premium look
    const gap = 0.2; // Radians
    
    // Appetizers (Purple)
    paint.color = const Color(0xFF8B5CF6);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - strokeWidth), -1.5, 0.8 - gap, false, paint);

    // Beverages (Blue)
    paint.color = const Color(0xFF3B82F6);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - strokeWidth), -0.7, 1.8 - gap, false, paint);

    // Desserts (Yellow/Amber)
    paint.color = const Color(0xFFF59E0B);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - strokeWidth), 1.1, 1.3 - gap, false, paint);

    // Main Course (Orange)
    paint.color = const Color(0xFFFF7D29);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - strokeWidth), 2.4, 2.4 - gap, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
