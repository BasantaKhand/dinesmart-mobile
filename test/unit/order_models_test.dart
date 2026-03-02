import 'package:flutter_test/flutter_test.dart';
import 'package:dinesmart_app/features/waiter_dashboard/data/models/order_api_model.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/entities/order_entity.dart';

void main() {
  // ─── OrderItemApiModel ───
  group('OrderItemApiModel', () {
    test('fromJson parses with nested menuItemId map', () {
      final json = {
        'menuItemId': {'_id': 'item_1', 'image': 'http://img.jpg'},
        'name': 'Burger',
        'price': 200,
        'quantity': 2,
        'total': 400,
        'status': 'SERVED',
        'notes': 'Extra cheese',
      };
      final model = OrderItemApiModel.fromJson(json);
      expect(model.menuItemId, 'item_1');
      expect(model.imageUrl, 'http://img.jpg');
      expect(model.name, 'Burger');
      expect(model.price, 200.0);
      expect(model.quantity, 2);
      expect(model.total, 400.0);
      expect(model.status, 'SERVED');
      expect(model.notes, 'Extra cheese');
    });

    test('fromJson parses with string menuItemId', () {
      final json = {
        'menuItemId': 'item_str',
        'name': 'Pizza',
        'price': 300,
        'quantity': 1,
        'total': 300,
      };
      final model = OrderItemApiModel.fromJson(json);
      expect(model.menuItemId, 'item_str');
      expect(model.imageUrl, isNull);
    });

    test('toJson produces correct map', () {
      final model = OrderItemApiModel(
        menuItemId: 'item_1',
        name: 'Burger',
        price: 200,
        quantity: 2,
        total: 400,
        status: 'SERVED',
        notes: 'Extra cheese',
      );
      final json = model.toJson();
      expect(json['menuItemId'], 'item_1');
      expect(json['name'], 'Burger');
      expect(json['price'], 200.0);
      expect(json['status'], 'SERVED');
      expect(json['notes'], 'Extra cheese');
    });

    test('toJson omits null status and notes', () {
      final model = OrderItemApiModel(
        menuItemId: 'item_1',
        name: 'Burger',
        price: 200,
        quantity: 1,
        total: 200,
      );
      final json = model.toJson();
      expect(json.containsKey('status'), false);
      expect(json.containsKey('notes'), false);
    });

    test('toEntity maps correctly', () {
      final model = OrderItemApiModel(
        menuItemId: 'item_1',
        imageUrl: 'http://img.jpg',
        name: 'Burger',
        price: 200,
        quantity: 2,
        total: 400,
      );
      final entity = model.toEntity();
      expect(entity, isA<OrderItemEntity>());
      expect(entity.menuItemId, 'item_1');
      expect(entity.imageUrl, 'http://img.jpg');
      expect(entity.name, 'Burger');
    });

    test('fromEntity creates model from entity', () {
      const entity = OrderItemEntity(
        menuItemId: 'item_1',
        imageUrl: 'http://img.jpg',
        name: 'Burger',
        price: 200,
        quantity: 2,
        total: 400,
        status: 'SERVED',
        notes: 'No onion',
      );
      final model = OrderItemApiModel.fromEntity(entity);
      expect(model.menuItemId, 'item_1');
      expect(model.name, 'Burger');
      expect(model.notes, 'No onion');
    });

    test('round-trip: fromJson -> toEntity -> fromEntity preserves data', () {
      final json = {
        'menuItemId': 'rt_1',
        'name': 'Pasta',
        'price': 350,
        'quantity': 1,
        'total': 350,
        'status': 'COOKING',
      };
      final entity = OrderItemApiModel.fromJson(json).toEntity();
      final roundTripped = OrderItemApiModel.fromEntity(entity);
      expect(roundTripped.menuItemId, 'rt_1');
      expect(roundTripped.name, 'Pasta');
      expect(roundTripped.status, 'COOKING');
    });
  });

  // ─── OrderApiModel ───
  group('OrderApiModel', () {
    Map<String, dynamic> _fullOrderJson() => {
          '_id': 'order_1',
          'tableId': {'_id': 'table_1', 'number': 'T-05'},
          'waiterId': {'_id': 'waiter_1', 'name': 'John'},
          'items': [
            {
              'menuItemId': 'item_1',
              'name': 'Burger',
              'price': 200,
              'quantity': 2,
              'total': 400,
            },
          ],
          'status': 'SERVED',
          'paymentStatus': 'PENDING',
          'subtotal': 400,
          'tax': 52,
          'vat': 10,
          'total': 462,
          'notes': 'Rush order',
          'paymentMethod': 'CASH',
          'transactionId': 'txn_123',
          'createdAt': '2026-03-02T10:30:00.000Z',
          'billPrinted': false,
        };

    test('fromJson parses with nested tableId and waiterId', () {
      final model = OrderApiModel.fromJson(_fullOrderJson());
      expect(model.id, 'order_1');
      expect(model.tableId, 'table_1');
      expect(model.tableNumber, 'T-05');
      expect(model.waiterName, 'John');
      expect(model.items.length, 1);
      expect(model.status, 'SERVED');
      expect(model.paymentStatus, 'PENDING');
      expect(model.subtotal, 400);
      expect(model.tax, 52);
      expect(model.vat, 10);
      expect(model.total, 462);
      expect(model.notes, 'Rush order');
      expect(model.billPrinted, false);
    });

    test('fromJson handles string tableId', () {
      final json = _fullOrderJson();
      json['tableId'] = 'simple_table_id';
      json['waiterId'] = 'simple_waiter_id';
      final model = OrderApiModel.fromJson(json);
      expect(model.tableId, 'simple_table_id');
      expect(model.tableNumber, isNull);
      expect(model.waiterName, isNull);
    });

    test('toJson produces correct structure', () {
      final model = OrderApiModel.fromJson(_fullOrderJson());
      final json = model.toJson();
      expect(json['tableId'], 'table_1');
      expect(json['orderType'], 'DINE_IN');
      expect(json['subtotal'], 400);
      expect(json['items'], isA<List>());
      expect(json['notes'], 'Rush order');
      // status should NOT be in toJson (managed by backend)
      expect(json.containsKey('status'), false);
    });

    test('toJson omits null optional fields', () {
      final model = OrderApiModel(
        tableId: 't1',
        items: [],
        status: 'PENDING',
        subtotal: 0,
        tax: 0,
        total: 0,
      );
      final json = model.toJson();
      expect(json.containsKey('notes'), false);
      expect(json.containsKey('paymentMethod'), false);
      expect(json.containsKey('transactionId'), false);
    });

    // ─── toEntity status mapping ───
    test('toEntity maps PENDING status', () {
      final json = _fullOrderJson()..['status'] = 'PENDING';
      final entity = OrderApiModel.fromJson(json).toEntity();
      expect(entity.status, OrderStatus.pending);
    });

    test('toEntity maps COOKING status', () {
      final json = _fullOrderJson()..['status'] = 'COOKING';
      final entity = OrderApiModel.fromJson(json).toEntity();
      expect(entity.status, OrderStatus.cooking);
    });

    test('toEntity maps COOKED status', () {
      final json = _fullOrderJson()..['status'] = 'COOKED';
      final entity = OrderApiModel.fromJson(json).toEntity();
      expect(entity.status, OrderStatus.cooked);
    });

    test('toEntity maps SERVED status', () {
      final entity = OrderApiModel.fromJson(_fullOrderJson()).toEntity();
      expect(entity.status, OrderStatus.served);
    });

    test('toEntity maps COMPLETED status', () {
      final json = _fullOrderJson()..['status'] = 'COMPLETED';
      final entity = OrderApiModel.fromJson(json).toEntity();
      expect(entity.status, OrderStatus.completed);
    });

    test('toEntity maps CANCELLED status', () {
      final json = _fullOrderJson()..['status'] = 'CANCELLED';
      final entity = OrderApiModel.fromJson(json).toEntity();
      expect(entity.status, OrderStatus.cancelled);
    });

    test('toEntity maps unknown status to pending', () {
      final json = _fullOrderJson()..['status'] = 'WEIRD';
      final entity = OrderApiModel.fromJson(json).toEntity();
      expect(entity.status, OrderStatus.pending);
    });

    test('toEntity maps billPrinted=true to OrderStatus.billPrinted', () {
      final json = _fullOrderJson()..['billPrinted'] = true;
      final entity = OrderApiModel.fromJson(json).toEntity();
      expect(entity.status, OrderStatus.billPrinted);
    });

    // ─── toEntity paymentStatus mapping ───
    test('toEntity maps PENDING paymentStatus', () {
      final entity = OrderApiModel.fromJson(_fullOrderJson()).toEntity();
      expect(entity.paymentStatus, PaymentStatus.pending);
    });

    test('toEntity maps PAID paymentStatus', () {
      final json = _fullOrderJson()..['paymentStatus'] = 'PAID';
      final entity = OrderApiModel.fromJson(json).toEntity();
      expect(entity.paymentStatus, PaymentStatus.paid);
    });

    test('toEntity maps PARTIAL paymentStatus', () {
      final json = _fullOrderJson()..['paymentStatus'] = 'PARTIAL';
      final entity = OrderApiModel.fromJson(json).toEntity();
      expect(entity.paymentStatus, PaymentStatus.partial);
    });

    test('toEntity maps null paymentStatus', () {
      final json = _fullOrderJson();
      json.remove('paymentStatus');
      final entity = OrderApiModel.fromJson(json).toEntity();
      expect(entity.paymentStatus, isNull);
    });

    test('toEntity maps unknown paymentStatus to pending', () {
      final json = _fullOrderJson()..['paymentStatus'] = 'UNKNOWN';
      final entity = OrderApiModel.fromJson(json).toEntity();
      expect(entity.paymentStatus, PaymentStatus.pending);
    });

    // ─── fromEntity ───
    test('fromEntity creates model from entity', () {
      final entity = OrderApiModel.fromJson(_fullOrderJson()).toEntity();
      final model = OrderApiModel.fromEntity(entity);
      expect(model.tableId, 'table_1');
      expect(model.subtotal, 400);
      expect(model.total, 462);
    });

    test('fromEntity sets billPrinted correctly for billPrinted status', () {
      final json = _fullOrderJson()..['billPrinted'] = true;
      final entity = OrderApiModel.fromJson(json).toEntity();
      final model = OrderApiModel.fromEntity(entity);
      expect(model.billPrinted, true);
    });

    test('fromEntity sets null id for empty id', () {
      const entity = OrderEntity(
        id: '',
        tableId: 't1',
        items: [],
        status: OrderStatus.pending,
        subtotal: 0,
        tax: 0,
        total: 0,
      );
      final model = OrderApiModel.fromEntity(entity);
      expect(model.id, isNull);
    });
  });

  // ─── OrderItemEntity ───
  group('OrderItemEntity', () {
    test('supports value equality', () {
      const a = OrderItemEntity(menuItemId: '1', name: 'Burger', price: 200, quantity: 1, total: 200);
      const b = OrderItemEntity(menuItemId: '1', name: 'Burger', price: 200, quantity: 1, total: 200);
      expect(a, equals(b));
    });

    test('different items are not equal', () {
      const a = OrderItemEntity(menuItemId: '1', name: 'Burger', price: 200, quantity: 1, total: 200);
      const b = OrderItemEntity(menuItemId: '2', name: 'Pizza', price: 300, quantity: 1, total: 300);
      expect(a, isNot(equals(b)));
    });
  });

  // ─── OrderEntity ───
  group('OrderEntity', () {
    test('supports value equality', () {
      const a = OrderEntity(id: '1', tableId: 't1', items: [], status: OrderStatus.pending, subtotal: 0, tax: 0, total: 0);
      const b = OrderEntity(id: '1', tableId: 't1', items: [], status: OrderStatus.pending, subtotal: 0, tax: 0, total: 0);
      expect(a, equals(b));
    });

    test('default vat is 0.0', () {
      const entity = OrderEntity(id: '1', tableId: 't1', items: [], status: OrderStatus.pending, subtotal: 0, tax: 0, total: 0);
      expect(entity.vat, 0.0);
    });
  });
}
