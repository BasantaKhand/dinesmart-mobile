import 'package:flutter_test/flutter_test.dart';
import 'package:dinesmart_app/features/cashier_dashboard/data/models/cashier_models.dart';
import 'package:dinesmart_app/features/cashier_dashboard/domain/entities/cashier_entities.dart';

void main() {
  // ─── CashierStatsModel ───
  group('CashierStatsModel', () {
    test('fromJson parses correctly', () {
      final json = {
        'collectionsToday': 1819,
        'billsClosedToday': 4,
        'pendingPayments': 3,
        'avgBillSize': 454.75,
        'cashCollected': 1819,
      };

      final model = CashierStatsModel.fromJson(json);
      expect(model.collectionsToday, 1819.0);
      expect(model.billsClosedToday, 4);
      expect(model.pendingPayments, 3);
      expect(model.avgBillSize, 454.75);
      expect(model.cashCollected, 1819.0);
    });

    test('fromJson handles nulls with defaults', () {
      final model = CashierStatsModel.fromJson({});
      expect(model.collectionsToday, 0);
      expect(model.billsClosedToday, 0);
      expect(model.pendingPayments, 0);
      expect(model.avgBillSize, 0);
      expect(model.cashCollected, 0);
    });

    test('toJson produces correct map', () {
      final model = CashierStatsModel(
        collectionsToday: 100,
        billsClosedToday: 2,
        pendingPayments: 1,
        avgBillSize: 50,
        cashCollected: 100,
      );
      final json = model.toJson();
      expect(json['collectionsToday'], 100.0);
      expect(json['billsClosedToday'], 2);
    });

    test('toEntity maps correctly', () {
      final model = CashierStatsModel(
        collectionsToday: 500,
        pendingPayments: 2,
        avgBillSize: 250,
        cashCollected: 500,
      );
      final entity = model.toEntity();
      expect(entity, isA<CashierStats>());
      expect(entity.collectionsToday, 500);
      expect(entity.pendingPayments, 2);
    });
  });

  // ─── PaymentQueueItemModel ───
  group('PaymentQueueItemModel', () {
    test('fromOrderJson parses with nested tableId map', () {
      final json = {
        '_id': 'ord_1',
        'orderNumber': 'ORD-001',
        'tableId': {'_id': 'table_1', 'number': 'T-05'},
        'total': 500,
        'subtotal': 440,
        'tax': 60,
        'items': [
          {
            'menuItemId': 'item_1',
            'name': 'Burger',
            'price': 200,
            'quantity': 2,
            'total': 400,
          },
        ],
        'status': 'COMPLETED',
        'paymentMethod': 'CASH',
        'createdAt': '2026-03-02T10:30:00.000Z',
      };

      final model = PaymentQueueItemModel.fromOrderJson(json);
      expect(model.id, 'ord_1');
      expect(model.tableNumber, 'T-05');
      expect(model.amount, 500);
      expect(model.itemCount, 1);
      expect(model.items.length, 1);
      expect(model.items.first.name, 'Burger');
      expect(model.status, 'COMPLETED');
    });

    test('fromOrderJson handles string tableId', () {
      final json = {
        '_id': 'ord_2',
        'tableId': 'table_string',
        'total': 300,
        'items': [],
        'status': 'SERVED',
        'createdAt': '2026-03-02T10:00:00.000Z',
      };

      final model = PaymentQueueItemModel.fromOrderJson(json);
      expect(model.tableNumber, 'N/A');
    });

    test('fromOrderJson handles missing fields with defaults', () {
      final json = {'_id': 'x', 'tableId': 'y'};
      final model = PaymentQueueItemModel.fromOrderJson(json);
      expect(model.orderNumber, '');
      expect(model.amount, 0);
      expect(model.status, 'SERVED');
      expect(model.paymentMethod, 'CASH');
    });

    test('toJson produces correct keys', () {
      final model = PaymentQueueItemModel(
        id: '1',
        orderId: 'o1',
        orderNumber: 'ORD-1',
        tableNumber: 'T-1',
        amount: 500,
        itemCount: 2,
        status: 'SERVED',
        createdAt: DateTime(2026, 3, 2),
      );
      final json = model.toJson();
      expect(json['_id'], '1');
      expect(json['amount'], 500);
      expect(json['createdAt'], '2026-03-02T00:00:00.000');
    });

    test('fromCacheJson parses flat format', () {
      final json = {
        '_id': 'c1',
        'orderId': 'o1',
        'orderNumber': 'ORD-001',
        'tableNumber': 'T-03',
        'amount': 300,
        'subtotal': 260,
        'tax': 40,
        'itemCount': 2,
        'status': 'COMPLETED',
        'paymentMethod': 'QR',
        'createdAt': '2026-03-02T10:30:00.000',
      };

      final model = PaymentQueueItemModel.fromCacheJson(json);
      expect(model.id, 'c1');
      expect(model.orderId, 'o1');
      expect(model.tableNumber, 'T-03');
      expect(model.amount, 300);
      expect(model.paymentMethod, 'QR');
    });

    test('fromCacheJson falls back orderId to _id', () {
      final json = {'_id': 'fallback_id', 'createdAt': '2026-03-02T10:00:00.000'};
      final model = PaymentQueueItemModel.fromCacheJson(json);
      expect(model.orderId, 'fallback_id');
    });

    test('toEntity maps all fields', () {
      final model = PaymentQueueItemModel(
        id: '1',
        orderId: 'o1',
        orderNumber: 'ORD-1',
        tableNumber: 'T-1',
        amount: 500,
        subtotal: 440,
        tax: 60,
        itemCount: 3,
        status: 'SERVED',
        createdAt: DateTime(2026, 3, 2),
      );
      final entity = model.toEntity();
      expect(entity, isA<PaymentQueueItem>());
      expect(entity.id, '1');
      expect(entity.amount, 500);
      expect(entity.subtotal, 440);
    });

    test('round-trip: toJson -> fromCacheJson preserves data', () {
      final original = PaymentQueueItemModel(
        id: 'rt1',
        orderId: 'o_rt1',
        orderNumber: 'ORD-RT-001',
        tableNumber: 'T-07',
        amount: 999,
        subtotal: 900,
        tax: 99,
        itemCount: 5,
        status: 'COMPLETED',
        paymentMethod: 'CARD',
        createdAt: DateTime(2026, 3, 2, 14, 30),
      );
      final json = original.toJson();
      final restored = PaymentQueueItemModel.fromCacheJson(json);
      expect(restored.id, original.id);
      expect(restored.amount, original.amount);
      expect(restored.paymentMethod, original.paymentMethod);
    });
  });

  // ─── SettlementModel ───
  group('SettlementModel', () {
    test('fromOrderJson parses with nested tableId', () {
      final json = {
        '_id': 's1',
        'orderNumber': 'ORD-004',
        'tableId': {'number': 'T-02'},
        'total': 395,
        'paymentMethod': 'CASH',
        'updatedAt': '2026-03-02T07:52:00.000Z',
      };

      final model = SettlementModel.fromOrderJson(json);
      expect(model.id, 's1');
      expect(model.tableNumber, 'T-02');
      expect(model.totalAmount, 395);
      expect(model.paymentMethod, 'CASH');
    });

    test('fromOrderJson handles string tableId', () {
      final json = {
        '_id': 's2',
        'tableId': 'table_str',
        'total': 200,
        'updatedAt': '2026-03-02T08:00:00.000Z',
      };
      final model = SettlementModel.fromOrderJson(json);
      expect(model.tableNumber, 'N/A');
    });

    test('toJson produces correct keys', () {
      final model = SettlementModel(
        id: 's1',
        orderId: 'o1',
        orderNumber: 'ORD-1',
        tableNumber: 'T-1',
        totalAmount: 500,
        paymentMethod: 'QR',
        settledAt: DateTime(2026, 3, 2, 12, 0),
      );
      final json = model.toJson();
      expect(json['_id'], 's1');
      expect(json['totalAmount'], 500);
      expect(json['settledAt'], '2026-03-02T12:00:00.000');
    });

    test('fromCacheJson parses flat format', () {
      final json = {
        '_id': 'sc1',
        'orderId': 'oc1',
        'orderNumber': 'ORD-C-001',
        'tableNumber': 'T-04',
        'totalAmount': 750,
        'paymentMethod': 'CARD',
        'settledAt': '2026-03-02T09:00:00.000',
      };
      final model = SettlementModel.fromCacheJson(json);
      expect(model.id, 'sc1');
      expect(model.totalAmount, 750);
    });

    test('toEntity maps correctly', () {
      final model = SettlementModel(
        id: 's1',
        orderId: 'o1',
        tableNumber: 'T-1',
        totalAmount: 500,
        paymentMethod: 'CASH',
        settledAt: DateTime(2026, 3, 2),
      );
      final entity = model.toEntity();
      expect(entity, isA<Settlement>());
      expect(entity.totalAmount, 500);
    });
  });

  // ─── TodaySettlementModel ───
  group('TodaySettlementModel', () {
    test('fromJson parses with collectionByMethod', () {
      final json = {
        'totalCollection': 1819,
        'totalBills': 4,
        'collectionByMethod': {'CASH': 1500, 'QR': 200, 'CARD': 119},
        'openingAmount': 5000,
        'expectedCash': 6819,
        'variance': 0,
        'paymentsSettled': 4,
        'amountSettled': 1819,
      };

      final model = TodaySettlementModel.fromJson(json);
      expect(model.totalCollection, 1819);
      expect(model.cashAmount, 1500);
      expect(model.qrAmount, 200);
      expect(model.cardAmount, 119);
      expect(model.expectedCash, 6819);
    });

    test('fromJson handles lowercase collectionByMethod keys', () {
      final json = {
        'totalCollection': 500,
        'collectionByMethod': {'cash': 300, 'qr': 100, 'card': 100},
      };
      final model = TodaySettlementModel.fromJson(json);
      expect(model.cashAmount, 300);
      expect(model.qrAmount, 100);
      expect(model.cardAmount, 100);
    });

    test('fromJson handles missing collectionByMethod', () {
      final model = TodaySettlementModel.fromJson({});
      expect(model.cashAmount, 0);
      expect(model.qrAmount, 0);
      expect(model.totalCollection, 0);
    });

    test('toJson produces correct map', () {
      final model = TodaySettlementModel(
        totalCollection: 1000,
        totalBills: 5,
        cashAmount: 800,
        qrAmount: 200,
      );
      final json = model.toJson();
      expect(json['totalCollection'], 1000);
      expect(json['cashAmount'], 800);
    });

    test('toEntity maps all fields', () {
      final model = TodaySettlementModel(
        totalCollection: 1819,
        totalBills: 4,
        cashAmount: 1819,
        openingAmount: 5000,
        expectedCash: 6819,
      );
      final entity = model.toEntity();
      expect(entity, isA<TodaySettlement>());
      expect(entity.totalCollection, 1819);
      expect(entity.expectedCash, 6819);
    });
  });

  // ─── CashDrawerStatusModel ───
  group('CashDrawerStatusModel', () {
    test('fromJson parses open drawer with status OPEN', () {
      final json = {
        '_id': 'd1',
        'status': 'OPEN',
        'openingAmount': 5000,
        'openedAt': '2026-03-02T08:00:00.000Z',
        'notes': 'Morning shift',
      };
      final model = CashDrawerStatusModel.fromJson(json);
      expect(model.id, 'd1');
      expect(model.isOpen, true);
      expect(model.openingAmount, 5000);
      expect(model.notes, 'Morning shift');
    });

    test('fromJson parses with isOpen boolean', () {
      final json = {'isOpen': true, 'openingAmount': 3000};
      final model = CashDrawerStatusModel.fromJson(json);
      expect(model.isOpen, true);
    });

    test('fromJson returns closed drawer for null json', () {
      final model = CashDrawerStatusModel.fromJson(null);
      expect(model.isOpen, false);
      expect(model.openingAmount, 0);
      expect(model.id, isNull);
    });

    test('fromJson handles closed status', () {
      final json = {'status': 'CLOSED', 'openingAmount': 0};
      final model = CashDrawerStatusModel.fromJson(json);
      expect(model.isOpen, false);
    });

    test('toJson produces correct keys', () {
      final model = CashDrawerStatusModel(
        id: 'd1',
        isOpen: true,
        openingAmount: 5000,
        openedAt: DateTime(2026, 3, 2, 8, 0),
        notes: 'Test',
      );
      final json = model.toJson();
      expect(json['id'], 'd1');
      expect(json['isOpen'], true);
      expect(json['openingAmount'], 5000);
      expect(json['notes'], 'Test');
    });

    test('toEntity maps all fields', () {
      final model = CashDrawerStatusModel(
        id: 'd1',
        isOpen: true,
        openingAmount: 5000,
      );
      final entity = model.toEntity();
      expect(entity, isA<CashDrawerStatus>());
      expect(entity.isOpen, true);
      expect(entity.openingAmount, 5000);
    });
  });
}
