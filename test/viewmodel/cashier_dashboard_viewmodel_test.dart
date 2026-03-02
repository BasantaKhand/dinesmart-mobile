import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:dinesmart_app/features/cashier_dashboard/domain/entities/cashier_entities.dart';
import 'package:dinesmart_app/features/cashier_dashboard/presentation/view_model/cashier_dashboard_view_model.dart';
import 'package:dinesmart_app/features/cashier_dashboard/presentation/state/cashier_dashboard_state.dart';
import '../helpers/test_helpers.dart';

void main() {
  late MockGetPaymentQueueUseCase mockGetPaymentQueue;
  late MockGetRecentSettlementsUseCase mockGetRecentSettlements;
  late MockGetTodaySettlementUseCase mockGetTodaySettlement;
  late MockGetDrawerStatusUseCase mockGetDrawerStatus;
  late MockSettlePaymentUseCase mockSettlePayment;
  late MockOpenCashDrawerUseCase mockOpenCashDrawer;
  late MockCloseCashDrawerUseCase mockCloseCashDrawer;

  setUp(() {
    mockGetPaymentQueue = MockGetPaymentQueueUseCase();
    mockGetRecentSettlements = MockGetRecentSettlementsUseCase();
    mockGetTodaySettlement = MockGetTodaySettlementUseCase();
    mockGetDrawerStatus = MockGetDrawerStatusUseCase();
    mockSettlePayment = MockSettlePaymentUseCase();
    mockOpenCashDrawer = MockOpenCashDrawerUseCase();
    mockCloseCashDrawer = MockCloseCashDrawerUseCase();
  });

  /// Helper: stubs all four GET calls with given data so initialize() succeeds.
  void stubAllSuccess({
    List<PaymentQueueItem>? queue,
    List<Settlement>? settlements,
    TodaySettlement? today,
    CashDrawerStatus? drawer,
  }) {
    when(() => mockGetPaymentQueue()).thenAnswer((_) async => Right(queue ?? TestData.paymentQueueList()));
    when(() => mockGetRecentSettlements()).thenAnswer((_) async => Right(settlements ?? TestData.settlementList()));
    when(() => mockGetTodaySettlement()).thenAnswer((_) async => Right(today ?? TestData.todaySettlement()));
    when(() => mockGetDrawerStatus()).thenAnswer((_) async => Right(drawer ?? TestData.drawerStatusOpen()));
  }

  /// Creates a CashierDashboardViewModel.
  /// NOTE: constructor calls initialize() automatically, so stubs must be set BEFORE this.
  CashierDashboardViewModel createViewModel() {
    return CashierDashboardViewModel(
      getPaymentQueueUseCase: mockGetPaymentQueue,
      getRecentSettlementsUseCase: mockGetRecentSettlements,
      getTodaySettlementUseCase: mockGetTodaySettlement,
      getDrawerStatusUseCase: mockGetDrawerStatus,
      settlePaymentUseCase: mockSettlePayment,
      openCashDrawerUseCase: mockOpenCashDrawer,
      closeCashDrawerUseCase: mockCloseCashDrawer,
    );
  }

  // ─── initialize() ───
  group('initialize()', () {
    test('calls all four use cases', () async {
      stubAllSuccess();
      final vm = createViewModel();
      // wait for initialize() to complete
      await Future.delayed(Duration.zero);

      verify(() => mockGetPaymentQueue()).called(1);
      verify(() => mockGetRecentSettlements()).called(1);
      verify(() => mockGetTodaySettlement()).called(1);
      verify(() => mockGetDrawerStatus()).called(1);

      vm.dispose();
    });

    test('sets status to success when all calls succeed', () async {
      stubAllSuccess();
      final vm = createViewModel();
      await Future.delayed(Duration.zero);

      expect(vm.state.status, CashierDashboardStatus.success);
      expect(vm.state.paymentQueue.length, 3);
      expect(vm.state.recentSettlements.length, 2);
      expect(vm.state.todaySettlement, isNotNull);
      expect(vm.state.drawerStatus, isNotNull);

      vm.dispose();
    });

    test('populates computed stats correctly', () async {
      stubAllSuccess();
      final vm = createViewModel();
      await Future.delayed(Duration.zero);

      final stats = vm.state.stats;
      expect(stats.collectionsToday, 1819);
      expect(stats.pendingPayments, 3);
      // avg = (395 + 203) / 2 = 299
      expect(stats.avgBillSize, 299);
      expect(stats.cashCollected, 1819);

      vm.dispose();
    });

    test('sets error status when queue fails and queue is empty', () async {
      when(() => mockGetPaymentQueue())
          .thenAnswer((_) async => const Left(ApiFailure(message: 'Server error')));
      when(() => mockGetRecentSettlements()).thenAnswer((_) async => Right(TestData.settlementList()));
      when(() => mockGetTodaySettlement()).thenAnswer((_) async => Right(TestData.todaySettlement()));
      when(() => mockGetDrawerStatus()).thenAnswer((_) async => Right(TestData.drawerStatusOpen()));

      final vm = createViewModel();
      await Future.delayed(Duration.zero);

      expect(vm.state.status, CashierDashboardStatus.error);
      expect(vm.state.errorMessage, 'Server error');
      expect(vm.state.paymentQueue, isEmpty);

      vm.dispose();
    });

    test('still succeeds when settlements/today/drawer fail but queue succeeds', () async {
      when(() => mockGetPaymentQueue()).thenAnswer((_) async => Right(TestData.paymentQueueList()));
      when(() => mockGetRecentSettlements())
          .thenAnswer((_) async => const Left(ApiFailure(message: 'fail')));
      when(() => mockGetTodaySettlement())
          .thenAnswer((_) async => const Left(ApiFailure(message: 'fail')));
      when(() => mockGetDrawerStatus())
          .thenAnswer((_) async => const Left(ApiFailure(message: 'fail')));

      final vm = createViewModel();
      await Future.delayed(Duration.zero);

      // queue succeeded so status is success (queue not empty)
      expect(vm.state.status, CashierDashboardStatus.success);
      expect(vm.state.paymentQueue.length, 3);
      expect(vm.state.recentSettlements, isEmpty);
      expect(vm.state.todaySettlement, isNull);

      vm.dispose();
    });
  });

  // ─── markOrderPaid() ───
  group('markOrderPaid()', () {
    test('calls settlePaymentUseCase with correct args', () async {
      stubAllSuccess();
      final vm = createViewModel();
      await Future.delayed(Duration.zero);

      when(() => mockSettlePayment(
        orderId: any(named: 'orderId'),
        paymentMethod: any(named: 'paymentMethod'),
        transactionId: any(named: 'transactionId'),
        notes: any(named: 'notes'),
      )).thenAnswer((_) async => const Right(true));
      // Re-stub gets for the refresh() call inside markOrderPaid
      stubAllSuccess();

      await vm.markOrderPaid('ord_001', paymentMethod: 'QR', transactionId: 'txn_1');
      // Wait for the refresh() chain (initialize()) to complete
      await Future.delayed(const Duration(milliseconds: 50));

      verify(() => mockSettlePayment(
        orderId: 'ord_001',
        paymentMethod: 'QR',
        transactionId: 'txn_1',
        notes: null,
      )).called(1);

      vm.dispose();
    });

    test('sets isSettling to false after success', () async {
      stubAllSuccess();
      final vm = createViewModel();
      await Future.delayed(Duration.zero);

      when(() => mockSettlePayment(
        orderId: any(named: 'orderId'),
        paymentMethod: any(named: 'paymentMethod'),
        transactionId: any(named: 'transactionId'),
        notes: any(named: 'notes'),
      )).thenAnswer((_) async => const Right(true));
      stubAllSuccess();

      await vm.markOrderPaid('ord_001');
      // after refresh completes
      await Future.delayed(Duration.zero);

      expect(vm.state.isSettling, false);

      vm.dispose();
    });

    test('sets error message on failure', () async {
      stubAllSuccess();
      final vm = createViewModel();
      await Future.delayed(Duration.zero);

      when(() => mockSettlePayment(
        orderId: any(named: 'orderId'),
        paymentMethod: any(named: 'paymentMethod'),
        transactionId: any(named: 'transactionId'),
        notes: any(named: 'notes'),
      )).thenAnswer((_) async => const Left(ApiFailure(message: 'Payment failed')));

      await vm.markOrderPaid('ord_001');

      expect(vm.state.isSettling, false);
      expect(vm.state.errorMessage, 'Payment failed');

      vm.dispose();
    });
  });

  // ─── openDrawer() ───
  group('openDrawer()', () {
    test('calls openCashDrawerUseCase and refreshes on success', () async {
      stubAllSuccess();
      final vm = createViewModel();
      await Future.delayed(Duration.zero);

      when(() => mockOpenCashDrawer(any(), notes: any(named: 'notes')))
          .thenAnswer((_) async => const Right(true));
      stubAllSuccess();

      await vm.openDrawer(5000, notes: 'Morning');
      await Future.delayed(Duration.zero);

      verify(() => mockOpenCashDrawer(5000, notes: 'Morning')).called(1);
      expect(vm.state.status, CashierDashboardStatus.success);

      vm.dispose();
    });

    test('sets error on failure', () async {
      stubAllSuccess();
      final vm = createViewModel();
      await Future.delayed(Duration.zero);

      when(() => mockOpenCashDrawer(any(), notes: any(named: 'notes')))
          .thenAnswer((_) async => const Left(ApiFailure(message: 'Already open')));

      await vm.openDrawer(5000);

      expect(vm.state.status, CashierDashboardStatus.error);
      expect(vm.state.errorMessage, 'Already open');

      vm.dispose();
    });
  });

  // ─── closeDrawer() ───
  group('closeDrawer()', () {
    test('calls closeCashDrawerUseCase and refreshes on success', () async {
      stubAllSuccess();
      final vm = createViewModel();
      await Future.delayed(Duration.zero);

      when(() => mockCloseCashDrawer(any(), notes: any(named: 'notes')))
          .thenAnswer((_) async => const Right(true));
      stubAllSuccess();

      await vm.closeDrawer(6819, notes: 'End shift');
      await Future.delayed(Duration.zero);

      verify(() => mockCloseCashDrawer(6819, notes: 'End shift')).called(1);
      expect(vm.state.status, CashierDashboardStatus.success);

      vm.dispose();
    });

    test('sets error on failure', () async {
      stubAllSuccess();
      final vm = createViewModel();
      await Future.delayed(Duration.zero);

      when(() => mockCloseCashDrawer(any(), notes: any(named: 'notes')))
          .thenAnswer((_) async => const Left(ApiFailure(message: 'Not open')));

      await vm.closeDrawer(0);

      expect(vm.state.status, CashierDashboardStatus.error);
      expect(vm.state.errorMessage, 'Not open');

      vm.dispose();
    });
  });
}
