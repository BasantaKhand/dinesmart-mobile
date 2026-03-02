import 'package:flutter_test/flutter_test.dart';
import 'package:dinesmart_app/features/cashier_dashboard/domain/entities/cashier_entities.dart';
import 'package:dinesmart_app/features/cashier_dashboard/presentation/state/cashier_dashboard_state.dart';

void main() {
  group('CashierStats', () {
    test('supports value equality', () {
      const a = CashierStats(collectionsToday: 1000, pendingPayments: 3, avgBillSize: 250, cashCollected: 800);
      const b = CashierStats(collectionsToday: 1000, pendingPayments: 3, avgBillSize: 250, cashCollected: 800);
      expect(a, equals(b));
    });

    test('different values are not equal', () {
      const a = CashierStats(collectionsToday: 1000, pendingPayments: 3, avgBillSize: 250, cashCollected: 800);
      const b = CashierStats(collectionsToday: 2000, pendingPayments: 3, avgBillSize: 250, cashCollected: 800);
      expect(a, isNot(equals(b)));
    });
  });

  group('PaymentQueueItem', () {
    test('supports value equality', () {
      final now = DateTime(2026, 3, 2);
      final a = PaymentQueueItem(id: '1', orderId: 'o1', tableNumber: 'T-01', amount: 500, status: 'COMPLETED', createdAt: now);
      final b = PaymentQueueItem(id: '1', orderId: 'o1', tableNumber: 'T-01', amount: 500, status: 'COMPLETED', createdAt: now);
      expect(a, equals(b));
    });

    test('default values are correct', () {
      final item = PaymentQueueItem(id: '1', orderId: 'o1', tableNumber: 'T-01', amount: 500, status: 'COMPLETED', createdAt: DateTime.now());
      expect(item.orderNumber, '');
      expect(item.subtotal, 0);
      expect(item.tax, 0);
      expect(item.itemCount, 0);
      expect(item.items, isEmpty);
      expect(item.paymentMethod, 'CASH');
    });
  });

  group('Settlement', () {
    test('supports value equality', () {
      final now = DateTime(2026, 3, 2);
      final a = Settlement(id: 's1', orderId: 'o1', tableNumber: 'T-02', totalAmount: 395, paymentMethod: 'CASH', settledAt: now);
      final b = Settlement(id: 's1', orderId: 'o1', tableNumber: 'T-02', totalAmount: 395, paymentMethod: 'CASH', settledAt: now);
      expect(a, equals(b));
    });
  });

  group('TodaySettlement', () {
    test('default values are all zero', () {
      const s = TodaySettlement();
      expect(s.totalCollection, 0);
      expect(s.totalBills, 0);
      expect(s.cashAmount, 0);
      expect(s.qrAmount, 0);
      expect(s.cardAmount, 0);
    });
  });

  group('CashDrawerStatus', () {
    test('defaults to closed', () {
      const status = CashDrawerStatus();
      expect(status.isOpen, false);
      expect(status.openingAmount, 0);
      expect(status.id, isNull);
    });
  });

  group('CashierDashboardState', () {
    test('initial state is correct', () {
      const state = CashierDashboardState();
      expect(state.status, CashierDashboardStatus.initial);
      expect(state.paymentQueue, isEmpty);
      expect(state.recentSettlements, isEmpty);
      expect(state.todaySettlement, isNull);
      expect(state.drawerStatus, isNull);
      expect(state.isOffline, false);
      expect(state.errorMessage, isNull);
      expect(state.isSettling, false);
    });

    test('computed stats returns correct values from todaySettlement', () {
      const state = CashierDashboardState(
        todaySettlement: TodaySettlement(
          totalCollection: 1500,
          totalBills: 5,
          cashAmount: 1200,
        ),
        paymentQueue: [],
        recentSettlements: [],
      );

      final stats = state.stats;
      expect(stats.collectionsToday, 1500);
      expect(stats.billsClosedToday, 5);
      expect(stats.pendingPayments, 0);
      expect(stats.cashCollected, 1200);
      expect(stats.avgBillSize, 0); // no recent settlements
    });

    test('computed stats calculates avgBillSize from recentSettlements', () {
      final now = DateTime(2026, 3, 2);
      final state = CashierDashboardState(
        recentSettlements: [
          Settlement(id: 's1', orderId: 'o1', tableNumber: 'T-01', totalAmount: 200, paymentMethod: 'CASH', settledAt: now),
          Settlement(id: 's2', orderId: 'o2', tableNumber: 'T-02', totalAmount: 400, paymentMethod: 'CASH', settledAt: now),
        ],
      );
      expect(state.stats.avgBillSize, 300); // (200 + 400) / 2
    });

    test('computed stats counts pending payments from queue length', () {
      final now = DateTime(2026, 3, 2);
      final state = CashierDashboardState(
        paymentQueue: [
          PaymentQueueItem(id: '1', orderId: 'o1', tableNumber: 'T-01', amount: 100, status: 'COMPLETED', createdAt: now),
          PaymentQueueItem(id: '2', orderId: 'o2', tableNumber: 'T-02', amount: 200, status: 'COMPLETED', createdAt: now),
        ],
      );
      expect(state.stats.pendingPayments, 2);
    });

    test('copyWith preserves values when no args passed', () {
      const original = CashierDashboardState(
        status: CashierDashboardStatus.success,
        isSettling: true,
      );
      final copy = original.copyWith();
      expect(copy.status, CashierDashboardStatus.success);
      expect(copy.isSettling, true);
    });

    test('copyWith overrides provided values', () {
      const original = CashierDashboardState();
      final copy = original.copyWith(
        status: CashierDashboardStatus.loading,
        isSettling: true,
      );
      expect(copy.status, CashierDashboardStatus.loading);
      expect(copy.isSettling, true);
    });

    test('copyWith clears errorMessage when null passed', () {
      const original = CashierDashboardState(errorMessage: 'Some error');
      final copy = original.copyWith(errorMessage: null);
      expect(copy.errorMessage, isNull);
    });
  });
}
