import 'package:mocktail/mocktail.dart';
import 'package:dinesmart_app/core/services/connectivity/network_info.dart';
import 'package:dinesmart_app/core/api/api_client.dart';
import 'package:dinesmart_app/features/cashier_dashboard/domain/repository/cashier_dashboard_repository.dart';
import 'package:dinesmart_app/features/cashier_dashboard/domain/use_cases/cashier_usecases.dart';
import 'package:dinesmart_app/features/cashier_dashboard/domain/entities/cashier_entities.dart';
import 'package:dinesmart_app/features/cashier_dashboard/data/data_sources/cashier_remote_data_source.dart';
import 'package:dinesmart_app/features/cashier_dashboard/data/data_sources/cashier_local_data_source.dart';
import 'package:dinesmart_app/features/staff_management/domain/repository/staff_repository.dart';
import 'package:dinesmart_app/features/staff_management/domain/entities/staff_entity.dart';
import 'package:dinesmart_app/features/staff_management/data/data_sources/staff_remote_data_source.dart';
import 'package:dinesmart_app/features/staff_management/data/data_sources/staff_local_data_source.dart';
import 'package:dinesmart_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:dinesmart_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:dinesmart_app/features/auth/domain/usecases/send_request_usecase.dart';
import 'package:dinesmart_app/features/auth/domain/usecases/update_password_usecase.dart';
import 'package:dinesmart_app/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:dinesmart_app/features/auth/domain/entities/auth_entity.dart';
import 'package:dinesmart_app/core/services/storage/user_session_service.dart';

// ─── Mock Classes ───

class MockCashierDashboardRepository extends Mock implements ICashierDashboardRepository {}

class MockApiClient extends Mock implements ApiClient {}

class MockStaffRepository extends Mock implements IStaffRepository {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockCashierRemoteDataSource extends Mock implements CashierRemoteDataSource {}

class MockCashierLocalDataSource extends Mock implements CashierLocalDataSource {}

class MockStaffRemoteDataSource extends Mock implements StaffRemoteDataSource {}

class MockStaffLocalDataSource extends Mock implements StaffLocalDataSource {}

class MockGetPaymentQueueUseCase extends Mock implements GetPaymentQueueUseCase {}

class MockGetRecentSettlementsUseCase extends Mock implements GetRecentSettlementsUseCase {}

class MockGetTodaySettlementUseCase extends Mock implements GetTodaySettlementUseCase {}

class MockGetDrawerStatusUseCase extends Mock implements GetDrawerStatusUseCase {}

class MockSettlePaymentUseCase extends Mock implements SettlePaymentUseCase {}

class MockOpenCashDrawerUseCase extends Mock implements OpenCashDrawerUseCase {}

class MockCloseCashDrawerUseCase extends Mock implements CloseCashDrawerUseCase {}

// ─── Auth Mocks ───

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

class MockSendRequestUsecase extends Mock implements SendRequestUsecase {}

class MockUpdatePasswordUsecase extends Mock implements UpdatePasswordUsecase {}

class MockUpdateProfileUsecase extends Mock implements UpdateProfileUsecase {}

class MockUserSessionService extends Mock implements UserSessionService {}

// ─── Fake Classes (for registerFallbackValue) ───

class FakeStaffEntity extends Fake implements StaffEntity {}

// ─── Test Data Factories ───

class TestData {
  // ─── Cashier ───

  static PaymentQueueItem paymentQueueItem({
    String id = '1',
    String orderId = 'ord_001',
    String orderNumber = 'ORD-20260302-001',
    String tableNumber = 'T-01',
    double amount = 500,
    double subtotal = 440,
    double tax = 60,
    int itemCount = 3,
    String status = 'COMPLETED',
  }) {
    return PaymentQueueItem(
      id: id,
      orderId: orderId,
      orderNumber: orderNumber,
      tableNumber: tableNumber,
      amount: amount,
      subtotal: subtotal,
      tax: tax,
      itemCount: itemCount,
      items: const [],
      status: status,
      paymentMethod: 'CASH',
      createdAt: DateTime(2026, 3, 2, 10, 30),
    );
  }

  static List<PaymentQueueItem> paymentQueueList() => [
        paymentQueueItem(id: '1', orderNumber: 'ORD-001', tableNumber: 'T-01', amount: 500),
        paymentQueueItem(id: '2', orderNumber: 'ORD-002', tableNumber: 'T-03', amount: 300),
        paymentQueueItem(id: '3', orderNumber: 'ORD-003', tableNumber: 'T-05', amount: 750),
      ];

  static Settlement settlement({
    String id = 's1',
    String orderId = 'ord_s1',
    String orderNumber = 'ORD-20260302-004',
    String tableNumber = 'T-02',
    double totalAmount = 395,
    String paymentMethod = 'CASH',
  }) {
    return Settlement(
      id: id,
      orderId: orderId,
      orderNumber: orderNumber,
      tableNumber: tableNumber,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      settledAt: DateTime(2026, 3, 2, 7, 52),
    );
  }

  static List<Settlement> settlementList() => [
        settlement(id: 's1', orderNumber: 'ORD-004', totalAmount: 395),
        settlement(id: 's2', orderNumber: 'ORD-005', totalAmount: 203),
      ];

  static TodaySettlement todaySettlement() => const TodaySettlement(
        totalCollection: 1819,
        totalBills: 4,
        cashAmount: 1819,
        qrAmount: 0,
        cardAmount: 0,
        openingAmount: 5000,
        expectedCash: 6819,
        variance: 0,
        paymentsSettled: 4,
        amountSettled: 1819,
      );

  static CashDrawerStatus drawerStatusOpen() => CashDrawerStatus(
        id: 'd1',
        isOpen: true,
        openingAmount: 5000,
        openedAt: DateTime(2026, 3, 2, 8, 0),
        notes: 'Morning shift',
      );

  static const CashDrawerStatus drawerStatusClosed = CashDrawerStatus(
    isOpen: false,
    openingAmount: 0,
  );

  // ─── Staff ───

  static StaffEntity staffEntity({
    String id = 'staff_1',
    String name = 'John Doe',
    String email = 'john@restaurant.com',
    StaffRole role = StaffRole.waiter,
    StaffStatus status = StaffStatus.active,
  }) {
    return StaffEntity(
      id: id,
      name: name,
      email: email,
      phone: '9800000000',
      role: role,
      status: status,
    );
  }

  static List<StaffEntity> staffList() => [
        staffEntity(id: 'staff_1', name: 'John Doe', role: StaffRole.waiter),
        staffEntity(id: 'staff_2', name: 'Jane Smith', email: 'jane@restaurant.com', role: StaffRole.cashier),
        staffEntity(id: 'staff_3', name: 'Bob Wilson', email: 'bob@restaurant.com', role: StaffRole.waiter, status: StaffStatus.inactive),
      ];

  // ─── Auth ───

  static AuthEntity authEntity({
    String authId = 'user_1',
    String ownerName = 'Admin User',
    String email = 'admin@dinesmart.com',
    String role = 'admin',
    bool mustChangePassword = false,
  }) {
    return AuthEntity(
      authId: authId,
      restaurantName: 'DineSmart Test',
      ownerName: ownerName,
      email: email,
      phoneNumber: '9800000000',
      address: 'Test Address',
      message: 'Test Message',
      username: 'admin_user',
      role: role,
      restaurantId: 'rest_1',
      mustChangePassword: mustChangePassword,
    );
  }
}
