import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dinesmart_app/features/staff_management/presentation/view_model/staff_view_model.dart';
import 'package:dinesmart_app/features/staff_management/presentation/state/staff_state.dart';
import 'package:dinesmart_app/features/staff_management/domain/entities/staff_entity.dart';

class AdminStaffPage extends ConsumerWidget {
  const AdminStaffPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(staffViewModelProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final isMobile = availableWidth < 600;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, ref, availableWidth),
            const SizedBox(height: 24),
            _buildSearchBox(ref, isMobile),
            const SizedBox(height: 24),
            Expanded(
              child: _buildStaffList(context, state, ref, isMobile),
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
          'Staff Members',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
                fontSize: isMobile ? 24 : null,
              ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          'Manage your restaurant employees and roles',
          style: TextStyle(color: Colors.grey[600], fontSize: isMobile ? 12 : 13),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context, WidgetRef ref, bool isMobile) {
    return ElevatedButton(
      onPressed: () => _showAddEditStaffSheet(context, ref),
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
              'Add Staff',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBox(WidgetRef ref, bool isMobile) {
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
            Expanded(
              child: TextField(
                onChanged: (val) => ref.read(staffViewModelProvider.notifier).searchStaff(val),
                decoration: InputDecoration(
                  hintText: isMobile ? 'Search staff...' : 'Search staff by name or email...',
                  border: InputBorder.none,
                  hintStyle: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffList(BuildContext context, StaffManagementState state, WidgetRef ref, bool isMobile) {
    if (state.status == StaffStatusState.loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.orange));
    }

    if (state.filteredStaffList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey[200]),
            const SizedBox(height: 16),
            Text('No staff members found', style: TextStyle(color: Colors.grey[400])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      itemCount: state.filteredStaffList.length,
      itemBuilder: (context, index) {
        final staff = state.filteredStaffList[index];
        return _buildStaffCard(context, staff, ref, isMobile);
      },
    );
  }

  Widget _buildStaffCard(BuildContext context, StaffEntity staff, WidgetRef ref, bool isMobile) {
    final isActive = staff.status == StaffStatus.ACTIVE;

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
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: isMobile ? 24 : 28,
                backgroundColor: Colors.orange.withOpacity(0.1),
                child: Text(
                  staff.name[0].toUpperCase(),
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontSize: isMobile ? 16 : 18),
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            staff.name,
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: isMobile ? 15 : 17, letterSpacing: -0.5),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusBadge(isActive),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      staff.email,
                      style: TextStyle(color: Colors.grey[500], fontSize: isMobile ? 11 : 13, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey[50], height: 1),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_outlined, color: Colors.orange[300], size: 16),
                  const SizedBox(width: 8),
                  Text(
                    staff.role.name,
                    style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 13),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionButton(Icons.edit_outlined, Colors.blue, () => _showAddEditStaffSheet(context, ref, staff: staff), isMobile),
                  const SizedBox(width: 8),
                  _buildActionButton(Icons.delete_outline_rounded, Colors.red, () => _handleDelete(context, ref, staff), isMobile),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isActive ? 'ACTIVE' : 'INACTIVE',
        style: TextStyle(
          color: isActive ? Colors.green[700] : Colors.red[700],
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
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

  void _handleDelete(BuildContext context, WidgetRef ref, StaffEntity staff) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Remove Staff Member?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete ${staff.name} from the system?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(staffViewModelProvider.notifier).deleteStaff(staff.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddEditStaffSheet(BuildContext context, WidgetRef ref, {StaffEntity? staff}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => AddEditStaffSheet(staff: staff),
    );
  }
}

class AddEditStaffSheet extends ConsumerStatefulWidget {
  final StaffEntity? staff;
  const AddEditStaffSheet({super.key, this.staff});

  @override
  ConsumerState<AddEditStaffSheet> createState() => _AddEditStaffSheetState();
}

class _AddEditStaffSheetState extends ConsumerState<AddEditStaffSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late StaffRole _selectedRole;
  late StaffStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.staff?.name ?? '');
    _emailController = TextEditingController(text: widget.staff?.email ?? '');
    _phoneController = TextEditingController(text: widget.staff?.phone ?? '');
    _selectedRole = widget.staff?.role ?? StaffRole.WAITER;
    _selectedStatus = widget.staff?.status ?? StaffStatus.ACTIVE;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.staff == null ? 'Add New Staff' : 'Edit Staff',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone (Optional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<StaffRole>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                items: StaffRole.values.map((r) => DropdownMenuItem(value: r, child: Text(r.name))).toList(),
                onChanged: (val) => setState(() => _selectedRole = val!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<StaffStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                items: StaffStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                onChanged: (val) => setState(() => _selectedStatus = val!),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Staff', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final staff = StaffEntity(
        id: widget.staff?.id ?? '',
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        role: _selectedRole,
        status: _selectedStatus,
      );

      if (widget.staff == null) {
        ref.read(staffViewModelProvider.notifier).createStaff(staff);
      } else {
        ref.read(staffViewModelProvider.notifier).updateStaff(staff);
      }
      Navigator.pop(context);
    }
  }
}
