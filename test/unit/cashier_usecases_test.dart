import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:dinesmart_app/features/cashier_dashboard/domain/entities/cashier_entities.dart';
import 'package:dinesmart_app/features/cashier_dashboard/domain/use_cases/cashier_usecases.dart';
import '../helpers/test_helpers.dart';

void main() {
  late MockCashierDashboardRepository mockRepo;

  setUp(() {
    mockRepo = MockCashierDashboardRepository();
  });

  // ─── GetPaymentQueueUseCase ───
  group('GetPaymentQueueUseCase', () {
    late GetPaymentQueueUseCase useCase;
    setUp(() => useCase = GetPaymentQueueUseCase(mockRepo));

    test('returns Right(List<PaymentQueueItem>) on success', () async {
      final items = TestData.paymentQueueList();
      when(() => mockRepo.getPaymentQueue()).thenAnswer((_) async => Right(items));

      final result = await useCase();

      expect(result, Right(items));
      verify(() => mockRepo.getPaymentQueue()).called(1);
    });

    test('returns Left(Failure) on error', () async {
      when(() => mockRepo.getPaymentQueue())
          .thenAnswer((_) async => const Left(ApiFailure(message: 'Server error')));

      final result = await useCase();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, 'Server error'),
        (_) => fail('Expected Left'),
      );
    });
  });

  // ─── GetRecentSettlementsUseCase ───
  group('GetRecentSettlementsUseCase', () {
    late GetRecentSettlementsUseCase useCase;
    setUp(() => useCase = GetRecentSettlementsUseCase(mockRepo));

    test('returns Right(List<Settlement>) on success', () async {
      final settlements = TestData.settlementList();
      when(() => mockRepo.getRecentSettlements()).thenAnswer((_) async => Right(settlements));

      final result = await useCase();

      expect(result, Right(settlements));
      verify(() => mockRepo.getRecentSettlements()).called(1);
    });

    test('returns Left(Failure) on error', () async {
      when(() => mockRepo.getRecentSettlements())
          .thenAnswer((_) async => const Left(ApiFailure(message: 'Network error')));

      final result = await useCase();

      expect(result.isLeft(), true);
    });
  });

  // ─── GetTodaySettlementUseCase ───
  group('GetTodaySettlementUseCase', () {
    late GetTodaySettlementUseCase useCase;
    setUp(() => useCase = GetTodaySettlementUseCase(mockRepo));

    test('returns Right(TodaySettlement) on success', () async {
      final today = TestData.todaySettlement();
      when(() => mockRepo.getTodaySettlement()).thenAnswer((_) async => Right(today));

      final result = await useCase();

      expect(result, Right(today));
      verify(() => mockRepo.getTodaySettlement()).called(1);
    });

    test('returns Left(Failure) on error', () async {
      when(() => mockRepo.getTodaySettlement())
          .thenAnswer((_) async => const Left(ApiFailure(message: 'Timeout')));

      final result = await useCase();

      expect(result.isLeft(), true);
    });
  });

  // ─── GetDrawerStatusUseCase ───
  group('GetDrawerStatusUseCase', () {
    late GetDrawerStatusUseCase useCase;
    setUp(() => useCase = GetDrawerStatusUseCase(mockRepo));

    test('returns Right(CashDrawerStatus) on success', () async {
      final status = TestData.drawerStatusOpen();
      when(() => mockRepo.getDrawerStatus()).thenAnswer((_) async => Right(status));

      final result = await useCase();

      expect(result, Right(status));
      verify(() => mockRepo.getDrawerStatus()).called(1);
    });

    test('returns Left(Failure) on error', () async {
      when(() => mockRepo.getDrawerStatus())
          .thenAnswer((_) async => const Left(ApiFailure(message: 'Unauthorized')));

      final result = await useCase();

      expect(result.isLeft(), true);
    });
  });

  // ─── SettlePaymentUseCase ───
  group('SettlePaymentUseCase', () {
    late SettlePaymentUseCase useCase;
    setUp(() => useCase = SettlePaymentUseCase(mockRepo));

    test('calls repository with correct parameters', () async {
      when(() => mockRepo.settlePayment(
        any(),
        any(),
        transactionId: any(named: 'transactionId'),
        notes: any(named: 'notes'),
      )).thenAnswer((_) async => const Right(true));

      final result = await useCase(
        orderId: 'ord_001',
        paymentMethod: 'CASH',
        transactionId: 'txn_123',
        notes: 'Quick settle',
      );

      expect(result, const Right(true));
      verify(() => mockRepo.settlePayment(
        'ord_001',
        'CASH',
        transactionId: 'txn_123',
        notes: 'Quick settle',
      )).called(1);
    });

    test('returns Left(Failure) on error', () async {
      when(() => mockRepo.settlePayment(
        any(),
        any(),
        transactionId: any(named: 'transactionId'),
        notes: any(named: 'notes'),
      )).thenAnswer((_) async => const Left(ApiFailure(message: 'Payment failed')));

      final result = await useCase(orderId: 'ord_001', paymentMethod: 'CASH');

      expect(result.isLeft(), true);
    });
  });

  // ─── OpenCashDrawerUseCase ───
  group('OpenCashDrawerUseCase', () {
    late OpenCashDrawerUseCase useCase;
    setUp(() => useCase = OpenCashDrawerUseCase(mockRepo));

    test('calls repository with correct parameters', () async {
      when(() => mockRepo.openCashDrawer(any(), notes: any(named: 'notes')))
          .thenAnswer((_) async => const Right(true));

      final result = await useCase(5000, notes: 'Morning shift');

      expect(result, const Right(true));
      verify(() => mockRepo.openCashDrawer(5000, notes: 'Morning shift')).called(1);
    });

    test('returns Left(Failure) on error', () async {
      when(() => mockRepo.openCashDrawer(any(), notes: any(named: 'notes')))
          .thenAnswer((_) async => const Left(ApiFailure(message: 'Already open')));

      final result = await useCase(5000);

      expect(result.isLeft(), true);
    });
  });

  // ─── CloseCashDrawerUseCase ───
  group('CloseCashDrawerUseCase', () {
    late CloseCashDrawerUseCase useCase;
    setUp(() => useCase = CloseCashDrawerUseCase(mockRepo));

    test('calls repository with correct parameters', () async {
      when(() => mockRepo.closeCashDrawer(any(), notes: any(named: 'notes')))
          .thenAnswer((_) async => const Right(true));

      final result = await useCase(6819, notes: 'End of shift');

      expect(result, const Right(true));
      verify(() => mockRepo.closeCashDrawer(6819, notes: 'End of shift')).called(1);
    });

    test('returns Left(Failure) on error', () async {
      when(() => mockRepo.closeCashDrawer(any(), notes: any(named: 'notes')))
          .thenAnswer((_) async => const Left(ApiFailure(message: 'Drawer not open')));

      final result = await useCase(0);

      expect(result.isLeft(), true);
    });
  });
}
