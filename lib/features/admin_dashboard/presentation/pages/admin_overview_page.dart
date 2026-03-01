import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../view_model/admin_dashboard_view_model.dart';
import '../state/admin_dashboard_state.dart';
import 'package:dinesmart_app/features/admin_dashboard/domain/entities/admin_statistics.dart';

class AdminOverviewPage extends ConsumerWidget {
  const AdminOverviewPage({super.key});

  // Web-like flat tokens
  static const Color _pageBg = Color(0xFFF7F7F8);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _text = Color(0xFF111827);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _muted2 = Color(0xFF9CA3AF);
  static const Color _brand = Color(0xFFFF7D29);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminDashboardViewModelProvider);
    final stats = state.adminStatistics;

    if (state.status == AdminDashboardStatus.loading && stats == null) {
      return const Center(child: CircularProgressIndicator(color: _brand));
    }

    return Container(
      color: _pageBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isMobile = width < 700;
          final isDesktop = width >= 1100;

          return RefreshIndicator(
            onRefresh: () => ref.read(adminDashboardViewModelProvider.notifier).initialize(),
            color: _brand,
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16.0 : 28.0,
                vertical: isMobile ? 16.0 : 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopHeader(context, state, isMobile),
                  const SizedBox(height: 16),
                  _buildV3StatGrid(context, state, isMobile, isDesktop),
                  const SizedBox(height: 16),
                  _buildAnalyticsSection(context, state, isMobile),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------- Header (web-like) ----------------

  Widget _buildTopHeader(BuildContext context, AdminDashboardState state, bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overview',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 28,
                  height: 1.05,
                  fontWeight: FontWeight.w800,
                  color: _text,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Welcome back! Here\'s what\'s happening today.',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 15,
                  color: _muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (!isMobile) ...[
          const SizedBox(width: 12),
          _PrimaryButton(
            label: 'Download Report',
            icon: Icons.download_rounded,
            onTap: () {},
          ),
        ],
      ],
    );
  }

  // ---------------- Stat Grid (web-like cards) ----------------

  Widget _buildV3StatGrid(
    BuildContext context,
    AdminDashboardState state,
    bool isMobile,
    bool isDesktop,
  ) {
    final stats = state.adminStatistics;

    // Match web feel:
    // - mobile/tablet: 2 columns
    // - desktop: 4 columns
    final crossAxisCount = isDesktop ? 4 : 2;

    // More “web” aspect ratio (tighter height on desktop, slightly taller on mobile)
    final childAspectRatio = isDesktop ? 1.55 : 1.28;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: childAspectRatio,
      children: [
        _WebStatCard(
          title: 'Net Revenue',
          value: 'NRs. ${stats?.totalRevenue.toInt() ?? 0}',
          icon: Icons.attach_money_rounded,
          iconBg: const Color(0xFFEFFDF5),
          iconColor: const Color(0xFF16A34A),
          deltaText: '+0.4% vs last month',
          isPositive: true,
        ),
        _WebStatCard(
          title: 'Unpaid Orders',
          value: '${((stats?.totalOrders ?? 0) - (stats?.paidOrders ?? 0)).clamp(0, 1 << 31)}',
          icon: Icons.info_outline_rounded,
          iconBg: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF2563EB),
          deltaText: '+33% of total orders',
          isPositive: false,
        ),
        _WebStatCard(
          title: 'Paid Orders',
          value: '${stats?.paidOrders ?? 0}',
          icon: Icons.check_circle_rounded,
          iconBg: const Color(0xFFFFF7ED),
          iconColor: const Color(0xFFF97316),
          deltaText: '+67% paid vs total',
          isPositive: true,
        ),
        _WebStatCard(
          title: 'Occupied Tables',
          value: '${stats?.occupiedTables ?? 0}',
          icon: Icons.grid_view_rounded,
          iconBg: const Color(0xFFF5F3FF),
          iconColor: const Color(0xFF7C3AED),
          deltaText: '+8% of total tables',
          isPositive: true,
        ),
      ],
    );
  }

  // ---------------- Analytics (web-like containers) ----------------

  Widget _buildAnalyticsSection(BuildContext context, AdminDashboardState state, bool isMobile) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 1100;

    final overviewCard = _FlatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Sales Overview',
            subtitle: 'Revenue trend over the last ${state.adminStatistics?.days ?? 30} days',
            trailing: _SoftDropdownChip(
              label: 'Last ${state.adminStatistics?.days ?? 30} Days',
              onTap: () {},
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 14),
          SizedBox(
            height: isMobile ? 240 : 260,
            width: double.infinity,
            child: _buildSalesLineChart(state.salesData),
          ),
        ],
      ),
    );

    final categoryCard = _FlatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Sales by Category',
            subtitle: 'Distribution of revenue',
            trailing: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'View All →',
                style: TextStyle(
                  color: _brand,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 18),
          Center(
            child: SizedBox(
              height: isMobile ? 200 : 220,
              child: _buildCategoryPieChart(state.categorySales),
            ),
          ),
          const SizedBox(height: 18),
          _buildDynamicLegend(state.categorySales),
        ],
      ),
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: overviewCard),
          const SizedBox(width: 14),
          Expanded(flex: 2, child: categoryCard),
        ],
      );
    }

    return Column(
      children: [
        overviewCard,
        const SizedBox(height: 14),
        categoryCard,
      ],
    );
  }

  // ---------------- Charts (same logic; only UI polish) ----------------

  Widget _buildSalesLineChart(List<SalesData> salesData) {
    if (salesData.isEmpty) {
      return const _EmptyState(
        icon: Icons.show_chart_rounded,
        title: 'No sales data',
        message: 'No sales data available for this period.',
      );
    }

    final maxY = salesData.map((e) => e.total).reduce((a, b) => a > b ? a : b);
    final validMaxY = maxY > 0 ? (maxY * 1.2) : 100.0;

    final List<FlSpot> spots = [];
    for (int i = 0; i < salesData.length; i++) {
      spots.add(FlSpot(i.toDouble(), salesData[i].total));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (validMaxY / 4) > 0 ? validMaxY / 4 : 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: const Color(0xFFF0F2F5),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              interval: salesData.length > 7 ? (salesData.length / 5).ceilToDouble() : 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= salesData.length) return const SizedBox();

                final dateStr = salesData[index].date;
                final date = DateTime.tryParse(dateStr);
                final label = date != null ? DateFormat('MMM d').format(date) : dateStr;

                return SideTitleWidget(
                  meta: meta,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: _muted2,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (validMaxY / 4) > 0 ? validMaxY / 4 : 1,
              reservedSize: 48,
              getTitlesWidget: (value, meta) {
                if (value == validMaxY || value == 0) return const SizedBox();
                final text = value >= 1000
                    ? '${(value / 1000).toStringAsFixed(1)}k'
                    : value.toInt().toString();
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: _muted2,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (salesData.length - 1).toDouble() > 0 ? (salesData.length - 1).toDouble() : 1,
        minY: 0,
        maxY: validMaxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: _brand,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: _brand.withAlpha((0.10 * 255).toInt()),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF111827),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final date = salesData[spot.x.toInt()].date;
                final parsed = DateTime.tryParse(date);
                final formattedDate =
                    parsed != null ? DateFormat('MMM d, yyyy').format(parsed) : date;

                return LineTooltipItem(
                  '$formattedDate\nSales : NRs. ${spot.y.toInt()}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    height: 1.25,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart(List<CategorySalesData> categorySales) {
    if (categorySales.isEmpty) {
      return const _EmptyState(
        icon: Icons.pie_chart_rounded,
        title: 'No category data',
        message: 'No category revenue available.',
      );
    }

    final colors = [
      const Color(0xFF2563EB), // Blue
      const Color(0xFFF97316), // Orange
      const Color(0xFF7C3AED), // Purple
      const Color(0xFF16A34A), // Green
      const Color(0xFFEC4899), // Pink
      const Color(0xFFF59E0B), // Amber
    ];

    final double total = categorySales.fold(0, (sum, item) => sum + item.value);

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            pieTouchData: PieTouchData(enabled: true),
            borderData: FlBorderData(show: false),
            sectionsSpace: 4,
            centerSpaceRadius: 60,
            sections: categorySales.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              final percentage = total > 0 ? (data.value / total * 100) : 0;

              return PieChartSectionData(
                color: colors[index % colors.length],
                value: data.value,
                title: '${percentage.toStringAsFixed(1)}%',
                radius: 22,
                titleStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.transparent, // keep clean (no arc labels)
                ),
              );
            }).toList(),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Total',
              style: TextStyle(
                color: _muted2,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'NRs. ${total.toInt()}',
              style: const TextStyle(
                color: _text,
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildDynamicLegend(List<CategorySalesData> categorySales) {
    if (categorySales.isEmpty) return const SizedBox();

    final colors = [
      const Color(0xFF2563EB),
      const Color(0xFFF97316),
      const Color(0xFF7C3AED),
      const Color(0xFF16A34A),
      const Color(0xFFEC4899),
      const Color(0xFFF59E0B),
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: categorySales.asMap().entries.map((entry) {
        return _LegendItem(
          color: colors[entry.key % colors.length],
          label: entry.value.name,
          value: entry.value.value,
        );
      }).toList(),
    );
  }
}

// ---------------- Web-like stat card ----------------

class _WebStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String deltaText;
  final bool isPositive;

  const _WebStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.deltaText,
    required this.isPositive,
  });

  static const Color _border = Color(0xFFE5E7EB);
  static const Color _text = Color(0xFF111827);
  static const Color _muted = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final deltaColor = isPositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _muted,
                  ),
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 24,
              height: 1.05,
              fontWeight: FontWeight.w800,
              color: _text,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                size: 16,
                color: deltaColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  deltaText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: deltaColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------- Reusable UI widgets (flat web-like) ----------------

class _FlatCard extends StatelessWidget {
  final Widget child;
  const _FlatCard({required this.child});

  static const Color _border = Color(0xFFE5E7EB);
  static const double _radius = 16;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: _border),
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  static const Color _text = Color(0xFF111827);
  static const Color _muted = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w900,
                  color: _text,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: _muted,
                ),
              ),
            ],
          ),
        ),
        trailing,
      ],
    );
  }
}

class _SoftDropdownChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SoftDropdownChip({required this.label, required this.onTap});

  static const Color _border = Color(0xFFE5E7EB);
  static const Color _muted = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _muted,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: _muted),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool fullWidth;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.fullWidth = false,
  });

  static const Color _brand = Color(0xFFFF7D29);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _brand,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: fullWidth ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF9CA3AF)),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final double value;

  const _LegendItem({required this.color, required this.label, required this.value});

  static const Color _border = Color(0xFFE5E7EB);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _text = Color(0xFF111827);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: _muted,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'NRs. ${value.toInt()}',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: _text,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}