import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:dinesmart_app/features/staff_management/domain/entities/staff_entity.dart';
import 'package:dinesmart_app/features/staff_management/domain/use_cases/staff_usecases.dart';
import '../helpers/test_helpers.dart';

void main() {
  late MockStaffRepository mockRepo;

  setUp(() {
    mockRepo = MockStaffRepository();
  });

  setUpAll(() {
    registerFallbackValue(FakeStaffEntity());
  });

  // ─── GetStaffUseCase ───
  group('GetStaffUseCase', () {
    late GetStaffUseCase useCase;
    setUp(() => useCase = GetStaffUseCase(mockRepo));

    test('returns Right(List<StaffEntity>) on success', () async {
      final staff = TestData.staffList();
      when(() => mockRepo.getStaff()).thenAnswer((_) async => Right(staff));

      final result = await useCase();

      expect(result, Right(staff));
      verify(() => mockRepo.getStaff()).called(1);
    });

    test('returns Left(Failure) on error', () async {
      when(() => mockRepo.getStaff())
          .thenAnswer((_) async => const Left(ApiFailure(message: 'Fetch failed')));

      final result = await useCase();

      expect(result.isLeft(), true);
    });
  });

  // ─── CreateStaffUseCase ───
  group('CreateStaffUseCase', () {
    late CreateStaffUseCase useCase;
    setUp(() => useCase = CreateStaffUseCase(mockRepo));

    test('delegates to repository with correct staff entity', () async {
      final staff = TestData.staffEntity();
      final creds = {'email': 'john@restaurant.com', 'password': 'abc123'};
      when(() => mockRepo.createStaff(any()))
          .thenAnswer((_) async => Right((staff: staff, credentials: creds)));

      final result = await useCase(staff);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (data) {
          expect(data.staff, staff);
          expect(data.credentials, creds);
        },
      );
      verify(() => mockRepo.createStaff(staff)).called(1);
    });

    test('returns Left(Failure) on error', () async {
      when(() => mockRepo.createStaff(any()))
          .thenAnswer((_) async => const Left(ApiFailure(message: 'Email exists')));

      final result = await useCase(TestData.staffEntity());

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f.message, 'Email exists'),
        (_) => fail('Expected Left'),
      );
    });
  });

  // ─── UpdateStaffUseCase ───
  group('UpdateStaffUseCase', () {
    late UpdateStaffUseCase useCase;
    setUp(() => useCase = UpdateStaffUseCase(mockRepo));

    test('delegates to repository and returns updated entity', () async {
      final staff = TestData.staffEntity(name: 'Updated Name');
      when(() => mockRepo.updateStaff(any())).thenAnswer((_) async => Right(staff));

      final result = await useCase(staff);

      expect(result, Right(staff));
      verify(() => mockRepo.updateStaff(staff)).called(1);
    });

    test('returns Left(Failure) on error', () async {
      when(() => mockRepo.updateStaff(any()))
          .thenAnswer((_) async => const Left(ApiFailure(message: 'Not found')));

      final result = await useCase(TestData.staffEntity());

      expect(result.isLeft(), true);
    });
  });

  // ─── DeleteStaffUseCase ───
  group('DeleteStaffUseCase', () {
    late DeleteStaffUseCase useCase;
    setUp(() => useCase = DeleteStaffUseCase(mockRepo));

    test('returns Right(true) on success', () async {
      when(() => mockRepo.deleteStaff(any())).thenAnswer((_) async => const Right(true));

      final result = await useCase('staff_1');

      expect(result, const Right(true));
      verify(() => mockRepo.deleteStaff('staff_1')).called(1);
    });

    test('returns Left(Failure) on error', () async {
      when(() => mockRepo.deleteStaff(any()))
          .thenAnswer((_) async => const Left(ApiFailure(message: 'Forbidden')));

      final result = await useCase('staff_1');

      expect(result.isLeft(), true);
    });
  });

  // ─── ToggleStaffStatusUseCase ───
  group('ToggleStaffStatusUseCase', () {
    late ToggleStaffStatusUseCase useCase;
    setUp(() => useCase = ToggleStaffStatusUseCase(mockRepo));

    test('returns Right(StaffEntity) with toggled status', () async {
      final toggled = TestData.staffEntity(status: StaffStatus.inactive);
      when(() => mockRepo.toggleStaffStatus(any())).thenAnswer((_) async => Right(toggled));

      final result = await useCase('staff_1');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (entity) => expect(entity.status, StaffStatus.inactive),
      );
      verify(() => mockRepo.toggleStaffStatus('staff_1')).called(1);
    });

    test('returns Left(Failure) on error', () async {
      when(() => mockRepo.toggleStaffStatus(any()))
          .thenAnswer((_) async => const Left(ApiFailure(message: 'Server error')));

      final result = await useCase('staff_1');

      expect(result.isLeft(), true);
    });
  });
}
