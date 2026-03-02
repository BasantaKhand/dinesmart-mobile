import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dinesmart_app/features/cashier_dashboard/domain/use_cases/cashier_usecases.dart';
import 'package:dinesmart_app/features/cashier_dashboard/presentation/view_model/cashier_dashboard_view_model.dart';
import 'package:dinesmart_app/features/cashier_dashboard/presentation/state/cashier_dashboard_state.dart';
import 'package:dinesmart_app/features/cashier_dashboard/presentation/widgets/payment_queue_section.dart';
import 'package:dinesmart_app/features/cashier_dashboard/presentation/widgets/recent_settlements_section.dart';
import 'package:dinesmart_app/features/cashier_dashboard/presentation/widgets/today_settlement_section.dart';
import '../helpers/test_helpers.dart';

// ─── A simple StateNotifier that lets us control state directly ───

class FakeCashierDashboardViewModel extends StateNotifier<CashierDashboardState>
    implements CashierDashboardViewModel {
  FakeCashierDashboardViewModel(super.initial);

  void emit(CashierDashboardState newState) => state = newState;

  @override
  Future<void> initialize() async {}
  @override
  Future<void> refresh() async {}
  @override
  Future<void> markOrderPaid(String orderId,
      {String? transactionId, String paymentMethod = 'CASH', String? notes}) async {}
  @override
  Future<void> openDrawer(double openingAmount, {String? notes}) async {}
  @override
  Future<void> closeDrawer(double closingAmount, {String? notes}) async {}

  @override
  GetPaymentQueueUseCase get getPaymentQueueUseCase => throw UnimplementedError();
  @override
  GetRecentSettlementsUseCase get getRecentSettlementsUseCase => throw UnimplementedError();
  @override
  GetTodaySettlementUseCase get getTodaySettlementUseCase => throw UnimplementedError();
  @override
  GetDrawerStatusUseCase get getDrawerStatusUseCase => throw UnimplementedError();
  @override
  SettlePaymentUseCase get settlePaymentUseCase => throw UnimplementedError();
  @override
  OpenCashDrawerUseCase get openCashDrawerUseCase => throw UnimplementedError();
  @override
  CloseCashDrawerUseCase get closeCashDrawerUseCase => throw UnimplementedError();
}

void main() {
  /// Wraps [child] in a MaterialApp + ProviderScope with the given [state].
  Widget buildWidget(Widget child, CashierDashboardState state) {
    final fakeVM = FakeCashierDashboardViewModel(state);
    return ProviderScope(
      overrides: [
        cashierDashboardViewModelProvider
            .overrideWith((_) => fakeVM),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  CashierDashboardState _loadedState() {
    return CashierDashboardState(
      status: CashierDashboardStatus.success,
      paymentQueue: TestData.paymentQueueList(),
      recentSettlements: TestData.settlementList(),
      todaySettlement: TestData.todaySettlement(),
      drawerStatus: TestData.drawerStatusOpen(),
    );
  }

  // ─── PaymentQueueSection ───
  group('PaymentQueueSection', () {
    testWidgets('shows payment queue items', (tester) async {
      await tester.pumpWidget(buildWidget(
        const SingleChildScrollView(child: PaymentQueueSection()),
        _loadedState(),
      ));
      await tester.pumpAndSettle();

      // Section header
      expect(find.text('Payment Queue'), findsOneWidget);
      // The 3 queue items' order numbers
      expect(find.textContaining('ORD-001'), findsOneWidget);
      expect(find.textContaining('ORD-002'), findsOneWidget);
      expect(find.textContaining('ORD-003'), findsOneWidget);
    });

    testWidgets('shows empty state when queue is empty', (tester) async {
      final emptyState = _loadedState().copyWith(paymentQueue: []);
      await tester.pumpWidget(buildWidget(
        const SingleChildScrollView(child: PaymentQueueSection()),
        emptyState,
      ));
      await tester.pumpAndSettle();

      // Should still show the header
      expect(find.text('Payment Queue'), findsOneWidget);
      // Queue items should not be there
      expect(find.textContaining('ORD-001'), findsNothing);
    });
  });

  // ─── RecentSettlementsSection ───
  group('RecentSettlementsSection', () {
    testWidgets('shows recent settlements', (tester) async {
      await tester.pumpWidget(buildWidget(
        const SingleChildScrollView(child: RecentSettlementsSection()),
        _loadedState(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Recent Settlements'), findsOneWidget);
      expect(find.textContaining('ORD-004'), findsOneWidget);
      expect(find.textContaining('ORD-005'), findsOneWidget);
    });

    testWidgets('shows empty state when no settlements', (tester) async {
      final emptyState = _loadedState().copyWith(recentSettlements: []);
      await tester.pumpWidget(buildWidget(
        const SingleChildScrollView(child: RecentSettlementsSection()),
        emptyState,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Recent Settlements'), findsOneWidget);
      expect(find.textContaining('ORD-004'), findsNothing);
    });
  });

  // ─── TodaySettlementSection ───
  group('TodaySettlementSection', () {
    testWidgets('shows today settlement summary', (tester) async {
      await tester.pumpWidget(buildWidget(
        const SingleChildScrollView(child: TodaySettlementSection()),
        _loadedState(),
      ));
      await tester.pumpAndSettle();

      // The section should render – check for some known text from settlement data
      // Total collection = 1819
      expect(find.textContaining('1819'), findsWidgets);
    });
  });

  // ─── Loading State ───
  group('Loading State', () {
    testWidgets('shows nothing special in sections during loading', (tester) async {
      const loadingState = CashierDashboardState(
        status: CashierDashboardStatus.loading,
      );
      await tester.pumpWidget(buildWidget(
        const SingleChildScrollView(
          child: Column(
            children: [
              PaymentQueueSection(),
              RecentSettlementsSection(),
              TodaySettlementSection(),
            ],
          ),
        ),
        loadingState,
      ));
      await tester.pump();

      // Sections should render (no crash)
      expect(find.text('Payment Queue'), findsOneWidget);
      expect(find.text('Recent Settlements'), findsOneWidget);
    });
  });
}
