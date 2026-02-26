import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/staff_entity.dart';
import '../../domain/use_cases/staff_usecases.dart';
import '../../data/repositories/staff_repository_impl.dart';
import '../state/staff_state.dart';

final staffViewModelProvider = StateNotifierProvider<StaffViewModel, StaffManagementState>((ref) {
  final repository = ref.read(staffRepositoryProvider);
  return StaffViewModel(
    getStaffUseCase: GetStaffUseCase(repository),
    createStaffUseCase: CreateStaffUseCase(repository),
    updateStaffUseCase: UpdateStaffUseCase(repository),
    deleteStaffUseCase: DeleteStaffUseCase(repository),
    toggleStaffStatusUseCase: ToggleStaffStatusUseCase(repository),
  );
});

class StaffViewModel extends StateNotifier<StaffManagementState> {
  final GetStaffUseCase getStaffUseCase;
  final CreateStaffUseCase createStaffUseCase;
  final UpdateStaffUseCase updateStaffUseCase;
  final DeleteStaffUseCase deleteStaffUseCase;
  final ToggleStaffStatusUseCase toggleStaffStatusUseCase;

  StaffViewModel({
    required this.getStaffUseCase,
    required this.createStaffUseCase,
    required this.updateStaffUseCase,
    required this.deleteStaffUseCase,
    required this.toggleStaffStatusUseCase,
  }) : super(const StaffManagementState()) {
    getStaff();
  }

  Future<void> getStaff() async {
    state = state.copyWith(status: StaffStatusState.loading);
    final result = await getStaffUseCase();
    result.fold(
      (failure) => state = state.copyWith(status: StaffStatusState.error, errorMessage: failure.message),
      (staff) => state = state.copyWith(
        status: StaffStatusState.success,
        staffList: staff,
        filteredStaffList: _filterStaff(staff, state.searchQuery),
      ),
    );
  }

  void searchStaff(String query) {
    state = state.copyWith(
      searchQuery: query,
      filteredStaffList: _filterStaff(state.staffList, query),
    );
  }

  List<StaffEntity> _filterStaff(List<StaffEntity> staff, String query) {
    if (query.isEmpty) return staff;
    return staff
        .where((s) => s.name.toLowerCase().contains(query.toLowerCase()) || 
                     s.email.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<void> createStaff(StaffEntity staff) async {
    state = state.copyWith(status: StaffStatusState.loading);
    final result = await createStaffUseCase(staff);
    result.fold(
      (failure) => state = state.copyWith(status: StaffStatusState.error, errorMessage: failure.message),
      (_) => getStaff(),
    );
  }

  Future<void> updateStaff(StaffEntity staff) async {
    state = state.copyWith(status: StaffStatusState.loading);
    final result = await updateStaffUseCase(staff);
    result.fold(
      (failure) => state = state.copyWith(status: StaffStatusState.error, errorMessage: failure.message),
      (_) => getStaff(),
    );
  }

  Future<void> deleteStaff(String id) async {
    state = state.copyWith(status: StaffStatusState.loading);
    final result = await deleteStaffUseCase(id);
    result.fold(
      (failure) => state = state.copyWith(status: StaffStatusState.error, errorMessage: failure.message),
      (_) => getStaff(),
    );
  }

  Future<void> toggleStatus(String id) async {
    final result = await toggleStaffStatusUseCase(id);
    result.fold(
      (failure) => state = state.copyWith(status: StaffStatusState.error, errorMessage: failure.message),
      (_) => getStaff(),
    );
  }
}
