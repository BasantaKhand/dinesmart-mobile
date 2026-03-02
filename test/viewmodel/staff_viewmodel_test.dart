import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:dinesmart_app/features/staff_management/domain/entities/staff_entity.dart';
import 'package:dinesmart_app/features/staff_management/domain/use_cases/staff_usecases.dart';
import 'package:dinesmart_app/features/staff_management/presentation/view_model/staff_view_model.dart';
import 'package:dinesmart_app/features/staff_management/presentation/state/staff_state.dart';
import '../helpers/test_helpers.dart';

void main() {
  late MockStaffRepository mockRepo;

  setUp(() {
    mockRepo = MockStaffRepository();
  });

  setUpAll(() {
    registerFallbackValue(FakeStaffEntity());
  });

  /// Stubs getStaff success so the constructor's auto-call works.
  void stubGetStaffSuccess([List<StaffEntity>? staff]) {
    when(() => mockRepo.getStaff())
        .thenAnswer((_) async => Right(staff ?? TestData.staffList()));
  }

  StaffViewModel createViewModel() {
    return StaffViewModel(
      getStaffUseCase: GetStaffUseCase(mockRepo),
      createStaffUseCase: CreateStaffUseCase(mockRepo),
      updateStaffUseCase: UpdateStaffUseCase(mockRepo),
      deleteStaffUseCase: DeleteStaffUseCase(mockRepo),
      toggleStaffStatusUseCase: ToggleStaffStatusUseCase(mockRepo),
    );
  }

  // ─── getStaff() ───
  group('getStaff()', () {
    test('sets status to success and populates staffList', () async {
      stubGetStaffSuccess();
      final vm = createViewModel();
      await Future.delayed(Duration.zero);

      expect(vm.state.status, StaffStatusState.success);
      expect(vm.state.staffList.length, 3);
      expect(vm.state.filteredStaffList.length, 3);

      vm.dispose();
    });

    test('sets status to error on failure', () async {
      when(() => mockRepo.getStaff())
          .thenAnswer((_) async => const Left(ApiFailure(message: 'Network error')));
      final vm = createViewModel();
      await Future.delayed(Duration.zero);

      expect(vm.state.status, StaffStatusState.error);
      expect(vm.state.errorMessage, 'Network error');
      expect(vm.state.staffList, isEmpty);

      vm.dispose();
    });
  });

  // ─── searchStaff() ───
  group('searchStaff()', () {
    test('filters by name (case insensitive)', () async {
      stubGetStaffSuccess();
      final vm = createViewModel();
      await Future.delayed(Duration.zero);

      vm.searchStaff('john');

      expect(vm.state.searchQuery, 'john');
      expect(vm.state.filteredStaffList.length, 1);
      expect(vm.state.filteredStaffList.first.name, 'John Doe');

      vm.dispose();
    });

    test('filters by email', () async {
      stubGetStaffSuccess();
      final vm = createViewModel();
      await Future.delayed(Duration.zero);

      vm.searchStaff('jane@');

      expect(vm.state.filteredStaffList.length, 1);
      expect(vm.state.filteredStaffList.first.name, 'Jane Smith');

      vm.dispose();
    });

    test('empty query returns all staff', () async {
      stubGetStaffSuccess();
      final vm = createViewModel();
      await Future.delayed(Duration.zero);

      vm.searchStaff('john');
      expect(vm.state.filteredStaffList.length, 1);

      vm.searchStaff('');
      expect(vm.state.filteredStaffList.length, 3);

      vm.dispose();
    });

    test('returns empty when no match', () async {
      stubGetStaffSuccess();
      final vm = createViewModel();
      await Future.delayed(Duration.zero);

      vm.searchStaff('zzzzz');
      expect(vm.state.filteredStaffList, isEmpty);

      vm.dispose();
    });
  });

  // ─── createStaff() ───
  group('createStaff()', () {
    test('calls repository and sets credentials on success', () async {
      stubGetStaffSuccess();
      final vm = createViewModel();
      await Future.delayed(Duration.zero);

      final newStaff = TestData.staffEntity(id: '', name: 'New Staff', email: 'new@test.com');
      final creds = {'email': 'new@test.com', 'password': 'generated123'};
      when(() => mockRepo.createStaff(any()))
          .thenAnswer((_) async => Right((staff: newStaff.copyWith(), credentials: creds)));
      stubGetStaffSuccess(); // for the auto getStaff() call after create

      await vm.createStaff(newStaff);
      await Future.delayed(Duration.zero);

      expect(vm.state.newStaffCredentials, creds);
      verify(() => mockRepo.createStaff(any())).called(1);

      vm.dispose();
    });

    test('sets error on failure', () async {
      stubGetStaffSuccess();
      final vm = createViewModel();
      await Future.delayed(Duration.zero);

      when(() => mockRepo.createStaff(any()))
          .thenAnswer((_) async => const Left(ApiFailure(message: 'Duplicate email')));

      await vm.createStaff(TestData.staffEntity());

      expect(vm.state.status, StaffStatusState.error);
      expect(vm.state.errorMessage, 'Duplicate email');

      vm.dispose();
    });
  });

  // ─── clearCredentials() ───
  group('clearCredentials()', () {
    test('sets newStaffCredentials to null', () async {
      stubGetStaffSuccess();
      final vm = createViewModel();
      await Future.delayed(Duration.zero);

      // Simulate credentials being set
      final staff = TestData.staffEntity();
      final creds = {'email': 'a@b.com', 'password': 'xyz'};
      when(() => mockRepo.createStaff(any()))
          .thenAnswer((_) async => Right((staff: staff, credentials: creds)));
      stubGetStaffSuccess();
      await vm.createStaff(staff);
      await Future.delayed(Duration.zero);
      expect(vm.state.newStaffCredentials, isNotNull);

      vm.clearCredentials();
      expect(vm.state.newStaffCredentials, isNull);

      vm.dispose();
    });
  });

  // ─── updateStaff() ───
  group('updateStaff()', () {
    test('calls repository and refreshes list', () async {
      stubGetStaffSuccess();
      final vm = createViewModel();
      await Future.delayed(Duration.zero);

      final updated = TestData.staffEntity(name: 'Updated Name');
      when(() => mockRepo.updateStaff(any())).thenAnswer((_) async => Right(updated));
      stubGetStaffSuccess();

      await vm.updateStaff(updated);
      await Future.delayed(Duration.zero);

      verify(() => mockRepo.updateStaff(any())).called(1);
      expect(vm.state.status, StaffStatusState.success);

      vm.dispose();
    });

    test('sets error on failure', () async {
      stubGetStaffSuccess();
      final vm = createViewModel();
      await Future.delayed(Duration.zero);

      when(() => mockRepo.updateStaff(any()))
          .thenAnswer((_) async => const Left(ApiFailure(message: 'Not found')));

      await vm.updateStaff(TestData.staffEntity());

      expect(vm.state.status, StaffStatusState.error);
      expect(vm.state.errorMessage, 'Not found');

      vm.dispose();
    });
  });

  // ─── deleteStaff() ───
  group('deleteStaff()', () {
    test('calls repository and refreshes list', () async {
      stubGetStaffSuccess();
      final vm = createViewModel();
      await Future.delayed(Duration.zero);

      when(() => mockRepo.deleteStaff(any())).thenAnswer((_) async => const Right(true));
      stubGetStaffSuccess();

      await vm.deleteStaff('staff_1');
      await Future.delayed(Duration.zero);

      verify(() => mockRepo.deleteStaff('staff_1')).called(1);
      expect(vm.state.status, StaffStatusState.success);

      vm.dispose();
    });

    test('sets error on failure', () async {
      stubGetStaffSuccess();
      final vm = createViewModel();
      await Future.delayed(Duration.zero);

      when(() => mockRepo.deleteStaff(any()))
          .thenAnswer((_) async => const Left(ApiFailure(message: 'Forbidden')));

      await vm.deleteStaff('staff_1');

      expect(vm.state.status, StaffStatusState.error);

      vm.dispose();
    });
  });

  // ─── toggleStatus() ───
  group('toggleStatus()', () {
    test('calls repository and refreshes list', () async {
      stubGetStaffSuccess();
      final vm = createViewModel();
      await Future.delayed(Duration.zero);

      final toggled = TestData.staffEntity(status: StaffStatus.inactive);
      when(() => mockRepo.toggleStaffStatus(any())).thenAnswer((_) async => Right(toggled));
      stubGetStaffSuccess();

      await vm.toggleStatus('staff_1');
      await Future.delayed(Duration.zero);

      verify(() => mockRepo.toggleStaffStatus('staff_1')).called(1);

      vm.dispose();
    });

    test('sets error on failure', () async {
      stubGetStaffSuccess();
      final vm = createViewModel();
      await Future.delayed(Duration.zero);

      when(() => mockRepo.toggleStaffStatus(any()))
          .thenAnswer((_) async => const Left(ApiFailure(message: 'Server error')));

      await vm.toggleStatus('staff_1');

      expect(vm.state.status, StaffStatusState.error);
      expect(vm.state.errorMessage, 'Server error');

      vm.dispose();
    });
  });
}
