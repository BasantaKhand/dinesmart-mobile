import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dinesmart_app/features/waiter_dashboard/presentation/view_model/waiter_dashboard_view_model.dart';
import 'package:dinesmart_app/features/waiter_dashboard/presentation/state/waiter_dashboard_state.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/entities/table_entity.dart';

class AdminTablesPage extends ConsumerWidget {
  const AdminTablesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(waiterDashboardViewModelProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final isMobile = availableWidth < 600;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, ref, availableWidth),
            const SizedBox(height: 24),
            _buildToolbar(isMobile),
            const SizedBox(height: 24),
            Expanded(
              child: _buildTableList(context, state, ref, isMobile),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, double availableWidth) {
    final isMobile = availableWidth < 600;
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderContent(context, isMobile),
                const SizedBox(height: 16),
                _buildAddButton(context, ref, isMobile),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildHeaderContent(context, isMobile)),
                const SizedBox(width: 16),
                _buildAddButton(context, ref, isMobile),
              ],
            ),
    );
  }

  Widget _buildHeaderContent(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Restaurant Tables',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
                fontSize: isMobile ? 24 : null,
              ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          'Manage your restaurant layout and table status',
          style: TextStyle(color: Colors.grey[600], fontSize: isMobile ? 12 : 13),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context, WidgetRef ref, bool isMobile) {
    return ElevatedButton(
      onPressed: () => _showTableDialog(context, ref),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 10 : 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add_rounded, color: Colors.white, size: 20),
          if (!isMobile) ...[
            const SizedBox(width: 8),
            const Text(
              'Add Table',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildToolbar(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 24.0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[200]!),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: Colors.grey[400], size: 20),
            const SizedBox(width: 12),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search tables...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableList(BuildContext context, WaiterDashboardState state, WidgetRef ref, bool isMobile) {
    if (state.status == WaiterDashboardStatus.loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.orange));
    }

    if (state.tables.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grid_view_rounded, size: 64, color: Colors.grey[200]),
            const SizedBox(height: 16),
            Text('No tables configured', style: TextStyle(color: Colors.grey[400])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      itemCount: state.tables.length,
      itemBuilder: (context, index) {
        final table = state.tables[index];
        return _buildTableCard(context, table, ref, isMobile);
      },
    );
  }

  Widget _buildTableCard(BuildContext context, TableEntity table, WidgetRef ref, bool isMobile) {
    final isOccupied = table.status == TableStatus.OCCUPIED;
    final statusColor = isOccupied ? Colors.orange : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 10 : 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.table_restaurant_rounded, color: statusColor, size: isMobile ? 24 : 28),
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Table ${table.number}',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: isMobile ? 16 : 18, letterSpacing: -0.5),
                    ),
                    _buildStatusBadge(table.status),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.people_outline_rounded, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 6),
                    Text(
                      '${table.capacity} Seats',
                      style: TextStyle(color: Colors.grey[500], fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildActionButton(Icons.edit_outlined, Colors.blue, () => _showTableDialog(context, ref, table: table), isMobile),
                    const SizedBox(width: 8),
                    _buildActionButton(Icons.delete_outline_rounded, Colors.red, () => _showDeleteConfirm(context, ref, table), isMobile),
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
    final isOccupied = status == TableStatus.OCCUPIED;
    final isReserved = status == TableStatus.RESERVED;
    final color = isOccupied ? Colors.orange : (isReserved ? Colors.blue : Colors.green);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.name,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap, bool isMobile) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 6 : 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: isMobile ? 16 : 18, color: color),
      ),
    );
  }

  void _showTableDialog(BuildContext context, WidgetRef ref, {TableEntity? table}) {
    final numberController = TextEditingController(text: table?.number);
    final capacityController = TextEditingController(text: table?.capacity.toString());
    TableStatus selectedStatus = table?.status ?? TableStatus.AVAILABLE;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(table == null ? 'New Table' : 'Edit Table', style: const TextStyle(fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(numberController, 'Table Number', Icons.grid_view_rounded),
              const SizedBox(height: 16),
              _buildTextField(capacityController, 'Capacity (Seats)', Icons.people_outline_rounded, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildStatusDropdown(selectedStatus, (val) => setState(() => selectedStatus = val!)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final newTable = TableEntity(
                  id: table?.id ?? '',
                  number: numberController.text,
                  capacity: int.tryParse(capacityController.text) ?? 4,
                  status: selectedStatus,
                );
                if (table == null) {
                  ref.read(waiterDashboardViewModelProvider.notifier).createTable(newTable);
                } else {
                  ref.read(waiterDashboardViewModelProvider.notifier).updateTable(table.id, newTable);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
              child: Text(table == null ? 'Add Table' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.orange, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[200]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.orange)),
      ),
    );
  }

  Widget _buildStatusDropdown(TableStatus selectedStatus, ValueChanged<TableStatus?> onChanged) {
    return DropdownButtonFormField<TableStatus>(
      value: selectedStatus,
      decoration: InputDecoration(
        labelText: 'Initial Status',
        prefixIcon: const Icon(Icons.info_outline_rounded, color: Colors.orange, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      items: TableStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
      onChanged: onChanged,
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, TableEntity table) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Table?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to remove Table ${table.number}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(waiterDashboardViewModelProvider.notifier).deleteTable(table.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
