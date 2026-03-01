import 'package:equatable/equatable.dart';
import '../../domain/entities/staff_entity.dart';

enum StaffStatusState { initial, loading, success, error }

class StaffManagementState extends Equatable {
  final StaffStatusState status;
  final List<StaffEntity> staffList;
  final List<StaffEntity> filteredStaffList;
  final String? errorMessage;
  final String searchQuery;
  final Map<String, dynamic>? newStaffCredentials;

  const StaffManagementState({
    this.status = StaffStatusState.initial,
    this.staffList = const [],
    this.filteredStaffList = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.newStaffCredentials,
  });

  StaffManagementState copyWith({
    StaffStatusState? status,
    List<StaffEntity>? staffList,
    List<StaffEntity>? filteredStaffList,
    String? errorMessage,
    String? searchQuery,
    Map<String, dynamic>? newStaffCredentials,
    bool clearCredentials = false,
  }) {
    return StaffManagementState(
      status: status ?? this.status,
      staffList: staffList ?? this.staffList,
      filteredStaffList: filteredStaffList ?? this.filteredStaffList,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      newStaffCredentials: clearCredentials ? null : (newStaffCredentials ?? this.newStaffCredentials),
    );
  }

  @override
  List<Object?> get props => [status, staffList, filteredStaffList, errorMessage, searchQuery, newStaffCredentials];
}
