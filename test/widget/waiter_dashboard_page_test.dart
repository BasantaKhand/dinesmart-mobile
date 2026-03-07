import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:dinesmart_app/core/services/socket/socket_service.dart';
import 'package:dinesmart_app/core/services/storage/user_session_service.dart';
import 'package:dinesmart_app/features/auth/presentation/state/auth_state.dart';
import 'package:dinesmart_app/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/use_cases/add_items_usecase.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/use_cases/create_order_usecase.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/use_cases/get_active_order_usecase.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/use_cases/get_categories_usecase.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/use_cases/get_menu_items_usecase.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/use_cases/get_tables_usecase.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/use_cases/update_order_status_usecase.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/entities/table_entity.dart';
import 'package:dinesmart_app/features/waiter_dashboard/presentation/pages/waiter_dashboard_page.dart';
import 'package:dinesmart_app/features/waiter_dashboard/presentation/state/waiter_dashboard_state.dart';
import 'package:dinesmart_app/features/waiter_dashboard/presentation/view_model/waiter_dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_helpers.dart';

class MockSocketService extends Mock implements SocketService {}

void main() {
  late MockGetTablesUseCase mockGetTables;
  late MockGetCategoriesUseCase mockGetCategories;
  late MockGetMenuItemsUseCase mockGetMenuItems;
  late MockGetActiveOrderUseCase mockGetActiveOrder;
  late MockCreateOrderUseCase mockCreateOrder;
  late MockAddItemsUseCase mockAddItems;
  late MockUpdateOrderStatusUseCase mockUpdateOrderStatus;
  late MockSocketService mockSocketService;
  late MockAuthViewModel mockAuthViewModel;
  late MockUserSessionService mockUserSessionService;

  setUp(() {
    mockGetTables = MockGetTablesUseCase();
    mockGetCategories = MockGetCategoriesUseCase();
    mockGetMenuItems = MockGetMenuItemsUseCase();
    mockGetActiveOrder = MockGetActiveOrderUseCase();
    mockCreateOrder = MockCreateOrderUseCase();
    mockAddItems = MockAddItemsUseCase();
    mockUpdateOrderStatus = MockUpdateOrderStatusUseCase();
    mockSocketService = MockSocketService();
    mockAuthViewModel = MockAuthViewModel();
    mockUserSessionService = MockUserSessionService();

    // Default setups
    when(() => mockSocketService.connect()).thenAnswer((_) async {});
    when(() => mockSocketService.addListener(any())).thenReturn(null);
    when(() => mockSocketService.removeListener(any())).thenReturn(null);
    
    when(() => mockGetTables()).thenAnswer((_) async => Right(TestData.tableList()));
    when(() => mockGetCategories()).thenAnswer((_) async => Right([TestData.categoryEntity()]));
    when(() => mockGetMenuItems()).thenAnswer((_) async => Right([TestData.menuItemEntity()]));
    when(() => mockGetActiveOrder(any())).thenAnswer((_) async => const Left(ApiFailure(message: 'No active order')));

    when(() => mockUserSessionService.getCurrentUserFullName()).thenReturn('John Waiter');
    when(() => mockUserSessionService.getCurrentUserRole()).thenReturn('WAITER');
    when(() => mockUserSessionService.getCurrentUserProfilePicture()).thenReturn(null);
  });

  Widget createWaiterDashboardPage() {
    return ProviderScope(
      overrides: [
        getTablesUseCaseProvider.overrideWithValue(mockGetTables),
        getCategoriesUseCaseProvider.overrideWithValue(mockGetCategories),
        getMenuItemsUseCaseProvider.overrideWithValue(mockGetMenuItems),
        getActiveOrderUseCaseProvider.overrideWithValue(mockGetActiveOrder),
        createOrderUseCaseProvider.overrideWithValue(mockCreateOrder),
        addItemsUseCaseProvider.overrideWithValue(mockAddItems),
        updateOrderStatusUseCaseProvider.overrideWithValue(mockUpdateOrderStatus),
        socketServiceProvider.overrideWithValue(mockSocketService),
        authViewModelProvider.overrideWith(() => mockAuthViewModel),
        userSessionServiceProvider.overrideWithValue(mockUserSessionService),
      ],
      child: const MaterialApp(
        home: WaiterDashboardPage(),
      ),
    );
  }

  group('WaiterDashboardPage Widget Test', () {
    testWidgets('renders loading state initially', (tester) async {
      final completer = Completer<Either<Failure, List<TableEntity>>>();
      when(() => mockGetTables()).thenAnswer((_) => completer.future);
      
      await tester.pumpWidget(createWaiterDashboardPage());
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Clean up: complete the future to avoid pending timer/future issues
      completer.complete(Right(TestData.tableList()));
      await tester.pump();
    });

    testWidgets('renders tables and categories after loading', (tester) async {
      await tester.pumpWidget(createWaiterDashboardPage());
      await tester.pump(); // Start loading
      await tester.pump(const Duration(milliseconds: 100)); // Complete futures
      await tester.pump(const Duration(milliseconds: 500)); // Finish animations

      expect(find.text('Total Tables'), findsOneWidget);
      expect(find.text('DineSmart'), findsOneWidget);
      expect(find.text('John Waiter'), findsOneWidget);
    });

    testWidgets('shows error state when tables fail to load', (tester) async {
      const errorMessage = 'Failed to load tables';
      when(() => mockGetTables()).thenAnswer((_) async => const Left(ApiFailure(message: errorMessage)));

      await tester.pumpWidget(createWaiterDashboardPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.textContaining('Error: $errorMessage'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('selecting a table updates the UI', (tester) async {
      await tester.pumpWidget(createWaiterDashboardPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.textContaining('1'), findsWidgets);

      await tester.tap(find.textContaining('1').first);
      await tester.pump(); // Start selection logic
      await tester.pump(const Duration(milliseconds: 100)); // Process getActiveOrder
      await tester.pump(const Duration(milliseconds: 500)); // Finish animations
      
      expect(find.text('Bill Summary'), findsWidgets);
    });
  });
}

class MockAuthViewModel extends Notifier<AuthState> with Mock implements AuthViewModel {
  @override
  AuthState build() => const AuthState();
}

class MockGetTablesUseCase extends Mock implements GetTablesUseCase {}
class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}
class MockGetMenuItemsUseCase extends Mock implements GetMenuItemsUseCase {}
class MockGetActiveOrderUseCase extends Mock implements GetActiveOrderUseCase {}
class MockCreateOrderUseCase extends Mock implements CreateOrderUseCase {}
class MockAddItemsUseCase extends Mock implements AddItemsUseCase {}
class MockUpdateOrderStatusUseCase extends Mock implements UpdateOrderStatusUseCase {}
