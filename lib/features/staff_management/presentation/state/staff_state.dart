import 'package:equatable/equatable.dart';
import '../../domain/entities/staff_entity.dart';

enum StaffStatusState { initial, loading, success, error }

class StaffManagementState extends Equatable {
  final StaffStatusState status;
  final List<StaffEntity> staffList;
  final List<StaffEntity> filteredStaffList;
  final String? errorMessage;
  final String searchQuery;

  const StaffManagementState({
    this.status = StaffStatusState.initial,
    this.staffList = const [],
    this.filteredStaffList = const [],
    this.errorMessage,
    this.searchQuery = '',
  });

  StaffManagementState copyWith({
    StaffStatusState? status,
    List<StaffEntity>? staffList,
    List<StaffEntity>? filteredStaffList,
    String? errorMessage,
    String? searchQuery,
  }) {
    return StaffManagementState(
      status: status ?? this.status,
      staffList: staffList ?? this.staffList,
      filteredStaffList: filteredStaffList ?? this.filteredStaffList,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [status, staffList, filteredStaffList, errorMessage, searchQuery];
}
