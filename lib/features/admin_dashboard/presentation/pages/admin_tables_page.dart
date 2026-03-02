import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dinesmart_app/features/waiter_dashboard/presentation/view_model/waiter_dashboard_view_model.dart';
import 'package:dinesmart_app/features/waiter_dashboard/presentation/state/waiter_dashboard_state.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/entities/table_entity.dart';

class AdminTablesPage extends ConsumerStatefulWidget {
  const AdminTablesPage({super.key});

  @override
  ConsumerState<AdminTablesPage> createState() => _AdminTablesPageState();
}

class _AdminTablesPageState extends ConsumerState<AdminTablesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  TableStatus? _selectedStatusFilter;

  // Dashboard tokens (match Overview/Orders/Menu pages)
  static const Color _pageBg = Color(0xFFF7F7F8);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _text = Color(0xFF111827);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _muted2 = Color(0xFF9CA3AF);
  static const Color _brand = Color(0xFFFF7D29);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(waiterDashboardViewModelProvider);

    return Scaffold(
      backgroundColor: _pageBg,
      floatingActionButton: FloatingActionButton(
        backgroundColor: _brand,
        onPressed: () => _showTableBottomSheet(context, ref),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopHeader(context, isMobile),
              const SizedBox(height: 4),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 28,
                    vertical: isMobile ? 12 : 18,
                  ),
                  child: _buildTableList(context, state, ref),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------------- Header (grey bg) ----------------

  Widget _buildTopHeader(BuildContext context, bool isMobile) {
    final isFilterActive = _selectedStatusFilter != null;

    return Container(
      color: _pageBg,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 28,
        isMobile ? 16 : 22,
        isMobile ? 16 : 28,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tables',
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
            'Create, edit, and manage table availability.',
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              color: _muted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),

          // Search + filter directly on grey background
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _border),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.grey[500],
                        size: 20,
                      ),
                      hintText: 'Search tables...',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () => _showFilterSheet(context),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _border),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: isFilterActive ? _brand : Colors.grey[800],
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- Filter sheet ----------------

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) {
        return FractionallySizedBox(
          widthFactor: 1,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Tables',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: _text,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => _selectedStatusFilter = null);
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'Reset',
                          style: TextStyle(
                            color: _brand,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Filter by table status',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'STATUS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.black54,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children:
                        [
                          null,
                          TableStatus.available,
                          TableStatus.occupied,
                          TableStatus.reserved,
                        ].map((status) {
                          final label = status == null
                              ? 'All'
                              : status.name[0].toUpperCase() +
                                    status.name.substring(1);
                          final isSelected = _selectedStatusFilter == status;
                          return InkWell(
                            onTap: () => setState(() {
                              _selectedStatusFilter = status;
                              Navigator.pop(ctx);
                            }),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _brand
                                    : const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? _brand : _border,
                                ),
                              ),
                              child: Text(
                                label,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : _text,
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w900
                                      : FontWeight.w700,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------- Table list ----------------

  Widget _buildTableList(
    BuildContext context,
    WaiterDashboardState state,
    WidgetRef ref,
  ) {
    if (state.status == WaiterDashboardStatus.loading) {
      return const Center(child: CircularProgressIndicator(color: _brand));
    }

    var tables = state.tables;

    if (_searchQuery.isNotEmpty) {
      tables = tables
          .where(
            (t) => t.number.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    if (_selectedStatusFilter != null) {
      tables = tables.where((t) => t.status == _selectedStatusFilter).toList();
    }

    if (tables.isEmpty) {
      return Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.grid_view_rounded, size: 62, color: Colors.grey[300]),
              const SizedBox(height: 14),
              Text(
                'No tables configured',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Add a new table to get started.',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final availableWidth = MediaQuery.of(context).size.width;
    final isDesktop = availableWidth > 900;

    if (isDesktop) {
      return GridView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 3.6,
        ),
        itemCount: tables.length,
        itemBuilder: (context, index) {
          final table = tables[index];
          return _buildTableCard(context, table, ref, isDesktop: true);
        },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: tables.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final table = tables[index];
        return _buildTableCard(context, table, ref);
      },
    );
  }

  Widget _buildTableCard(
    BuildContext context,
    TableEntity table,
    WidgetRef ref, {
    bool isDesktop = false,
  }) {
    final isOccupied = table.status == TableStatus.occupied;
    final isReserved = table.status == TableStatus.reserved;

    Color statusColor;
    if (isOccupied) {
      statusColor = _brand;
    } else if (isReserved) {
      statusColor = const Color(0xFF2563EB);
    } else {
      statusColor = const Color(0xFF16A34A);
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.table_restaurant_rounded,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Table ${table.number}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: -0.2,
                          color: _text,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildStatusBadge(table.status),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline_rounded,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${table.capacity} Seats',
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildActionButton(
                          Icons.edit_outlined,
                          const Color(0xFF2563EB),
                          () =>
                              _showTableBottomSheet(context, ref, table: table),
                        ),
                        const SizedBox(width: 6),
                        _buildActionButton(
                          Icons.delete_outline_rounded,
                          const Color(0xFFEF4444),
                          () => _showDeleteConfirm(context, ref, table),
                        ),
                      ],
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

  Widget _buildStatusBadge(TableStatus status) {
    final isOccupied = status == TableStatus.occupied;
    final isReserved = status == TableStatus.reserved;
    final color = isOccupied
        ? _brand
        : (isReserved ? const Color(0xFF2563EB) : const Color(0xFF16A34A));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha((0.12 * 255).toInt()),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withAlpha((0.10 * 255).toInt()),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  // ---------------- Add/Edit bottom sheet ----------------
  // ✅ Table Number is DISABLED and shows auto-generated text for new tables

  void _showTableBottomSheet(
    BuildContext context,
    WidgetRef ref, {
    TableEntity? table,
  }) {
    // auto-number for NEW table, keep existing when editing
    final existingTables = ref.read(waiterDashboardViewModelProvider).tables;
    final nextIndex = (existingTables.length + 1).clamp(1, 9999);
    final autoNumber = 'T-${nextIndex.toString().padLeft(2, '0')}';

    final numberController = TextEditingController(
      text: table?.number ?? autoNumber,
    );
    final capacityController = TextEditingController(
      text: table?.capacity.toString(),
    );
    TableStatus selectedStatus = table?.status ?? TableStatus.available;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 700;
        final padding = isMobile ? 16.0 : 24.0; // More padding on tablets/web
        
        return FractionallySizedBox(
          widthFactor: 1,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(padding, 0, padding, 20),
              child: StatefulBuilder(
                builder: (context, setState) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                table == null
                                    ? 'New Table'
                                    : 'Edit Table #${table.number}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: _text,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                table == null
                                    ? 'Configure a new table for your restaurant.'
                                    : 'Modify capacity and status for this table.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F4F8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: _text,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Table Number'),
                              _buildTextField(
                                numberController,
                                'Auto-generated',
                                enabled: false,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Capacity (Seats)'),
                              _buildTextField(
                                capacityController,
                                'E.g. 4',
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    _label('Current Status'),
                    _buildStatusDropdown(
                      selectedStatus,
                      (val) => setState(() => selectedStatus = val!),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          final newTable = TableEntity(
                            id: table?.id ?? '',
                            number: numberController
                                .text, // ✅ uses auto-generated text
                            capacity:
                                int.tryParse(capacityController.text) ?? 4,
                            status: selectedStatus,
                          );

                          if (table == null) {
                            ref
                                .read(waiterDashboardViewModelProvider.notifier)
                                .createTable(newTable);
                          } else {
                            ref
                                .read(waiterDashboardViewModelProvider.notifier)
                                .updateTable(table.id, newTable);
                          }
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _brand,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          table == null ? 'Add Table' : 'Save Changes',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.black.withAlpha(190),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      readOnly: !enabled,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black.withAlpha(120),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withAlpha(25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _brand, width: 1.4),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withAlpha(18)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(
    TableStatus selectedStatus,
    ValueChanged<TableStatus?> onChanged,
  ) {
    return DropdownButtonFormField<TableStatus>(
      initialValue: selectedStatus,
      decoration: InputDecoration(
        hintText: 'Select status',
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black.withAlpha(120),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withAlpha(25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _brand, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[600]),
      items: TableStatus.values
          .map(
            (s) => DropdownMenuItem(
              value: s,
              child: Text(
                s.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  void _showDeleteConfirm(
    BuildContext context,
    WidgetRef ref,
    TableEntity table,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Table?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Are you sure you want to remove Table ${table.number}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(waiterDashboardViewModelProvider.notifier)
                  .deleteTable(table.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
