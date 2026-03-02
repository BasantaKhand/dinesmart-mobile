import 'package:flutter_test/flutter_test.dart';
import 'package:dinesmart_app/features/staff_management/domain/entities/staff_entity.dart';
import 'package:dinesmart_app/features/staff_management/data/models/staff_api_model.dart';
import 'package:dinesmart_app/features/staff_management/presentation/state/staff_state.dart';

void main() {
  // ─── StaffEntity ───
  group('StaffEntity', () {
    test('supports value equality', () {
      const a = StaffEntity(id: '1', name: 'John', email: 'j@test.com', role: StaffRole.waiter, status: StaffStatus.active);
      const b = StaffEntity(id: '1', name: 'John', email: 'j@test.com', role: StaffRole.waiter, status: StaffStatus.active);
      expect(a, equals(b));
    });

    test('different ids are not equal', () {
      const a = StaffEntity(id: '1', name: 'John', email: 'j@test.com', role: StaffRole.waiter, status: StaffStatus.active);
      const b = StaffEntity(id: '2', name: 'John', email: 'j@test.com', role: StaffRole.waiter, status: StaffStatus.active);
      expect(a, isNot(equals(b)));
    });

    test('copyWith creates a copy with overridden fields', () {
      const original = StaffEntity(id: '1', name: 'John', email: 'j@test.com', role: StaffRole.waiter, status: StaffStatus.active);
      final copy = original.copyWith(name: 'Jane', role: StaffRole.cashier);
      expect(copy.id, '1'); // preserved
      expect(copy.name, 'Jane');
      expect(copy.role, StaffRole.cashier);
      expect(copy.email, 'j@test.com'); // preserved
      expect(copy.status, StaffStatus.active); // preserved
    });

    test('copyWith with no args returns equal entity', () {
      const original = StaffEntity(id: '1', name: 'John', email: 'j@test.com', role: StaffRole.waiter, status: StaffStatus.active);
      final copy = original.copyWith();
      expect(copy, equals(original));
    });
  });

  // ─── StaffApiModel ───
  group('StaffApiModel', () {
    test('fromJson creates correct model', () {
      final json = {
        '_id': 'abc123',
        'name': 'John Doe',
        'email': 'john@test.com',
        'phone': '9800000000',
        'role': 'WAITER',
        'status': 'ACTIVE',
      };

      final model = StaffApiModel.fromJson(json);
      expect(model.id, 'abc123');
      expect(model.name, 'John Doe');
      expect(model.email, 'john@test.com');
      expect(model.phone, '9800000000');
      expect(model.role, 'WAITER');
      expect(model.status, 'ACTIVE');
    });

    test('fromJson handles null phone', () {
      final json = {
        '_id': 'abc123',
        'name': 'John Doe',
        'email': 'john@test.com',
        'phone': null,
        'role': 'CASHIER',
        'status': 'INACTIVE',
      };

      final model = StaffApiModel.fromJson(json);
      expect(model.phone, isNull);
    });

    test('toJson produces correct keys', () {
      final model = StaffApiModel(
        id: 'abc123',
        name: 'John Doe',
        email: 'john@test.com',
        phone: '9800000000',
        role: 'waiter',
        status: 'active',
      );

      final json = model.toJson();
      expect(json['name'], 'John Doe');
      expect(json['email'], 'john@test.com');
      expect(json['phone'], '9800000000');
      expect(json['role'], 'WAITER'); // uppercased
      expect(json['status'], 'ACTIVE'); // uppercased
      expect(json.containsKey('_id'), false); // id not in toJson
    });

    test('toJson omits null phone', () {
      final model = StaffApiModel(
        name: 'John',
        email: 'j@test.com',
        role: 'waiter',
        status: 'active',
      );
      final json = model.toJson();
      expect(json.containsKey('phone'), false);
    });

    test('toEntity maps WAITER role correctly', () {
      final model = StaffApiModel(id: '1', name: 'John', email: 'j@test.com', role: 'WAITER', status: 'ACTIVE');
      final entity = model.toEntity();
      expect(entity.role, StaffRole.waiter);
      expect(entity.status, StaffStatus.active);
    });

    test('toEntity maps CASHIER role correctly', () {
      final model = StaffApiModel(id: '1', name: 'Jane', email: 'jane@test.com', role: 'CASHIER', status: 'INACTIVE');
      final entity = model.toEntity();
      expect(entity.role, StaffRole.cashier);
      expect(entity.status, StaffStatus.inactive);
    });

    test('toEntity maps lowercase role correctly', () {
      final model = StaffApiModel(id: '1', name: 'Bob', email: 'bob@test.com', role: 'cashier', status: 'active');
      final entity = model.toEntity();
      expect(entity.role, StaffRole.cashier);
      expect(entity.status, StaffStatus.active);
    });

    test('toEntity defaults unknown role to waiter', () {
      final model = StaffApiModel(id: '1', name: 'X', email: 'x@test.com', role: 'UNKNOWN', status: 'ACTIVE');
      final entity = model.toEntity();
      expect(entity.role, StaffRole.waiter);
    });

    test('fromEntity creates model from entity', () {
      const entity = StaffEntity(id: '1', name: 'John', email: 'j@test.com', phone: '123', role: StaffRole.cashier, status: StaffStatus.active);
      final model = StaffApiModel.fromEntity(entity);
      expect(model.id, '1');
      expect(model.name, 'John');
      expect(model.role, 'cashier');
    });

    test('fromEntity uses null id for empty id', () {
      const entity = StaffEntity(id: '', name: 'New', email: 'n@test.com', role: StaffRole.waiter, status: StaffStatus.active);
      final model = StaffApiModel.fromEntity(entity);
      expect(model.id, isNull);
    });

    test('round-trip: fromJson -> toEntity -> fromEntity preserves data', () {
      final json = {'_id': 'xyz', 'name': 'Test User', 'email': 'test@t.com', 'phone': '555', 'role': 'CASHIER', 'status': 'ACTIVE'};
      final entity = StaffApiModel.fromJson(json).toEntity();
      final model = StaffApiModel.fromEntity(entity);
      expect(model.name, 'Test User');
      expect(model.email, 'test@t.com');
    });
  });

  // ─── StaffManagementState ───
  group('StaffManagementState', () {
    test('initial state has correct defaults', () {
      const state = StaffManagementState();
      expect(state.status, StaffStatusState.initial);
      expect(state.staffList, isEmpty);
      expect(state.filteredStaffList, isEmpty);
      expect(state.errorMessage, isNull);
      expect(state.searchQuery, '');
      expect(state.newStaffCredentials, isNull);
    });

    test('copyWith overrides provided values', () {
      const state = StaffManagementState();
      final copy = state.copyWith(
        status: StaffStatusState.loading,
        searchQuery: 'john',
      );
      expect(copy.status, StaffStatusState.loading);
      expect(copy.searchQuery, 'john');
    });

    test('copyWith clearCredentials sets newStaffCredentials to null', () {
      final state = const StaffManagementState().copyWith(
        newStaffCredentials: {'email': 'test', 'password': '123'},
      );
      expect(state.newStaffCredentials, isNotNull);

      final cleared = state.copyWith(clearCredentials: true);
      expect(cleared.newStaffCredentials, isNull);
    });

    test('supports value equality', () {
      const a = StaffManagementState();
      const b = StaffManagementState();
      expect(a, equals(b));
    });
  });
}
