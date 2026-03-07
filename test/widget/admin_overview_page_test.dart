import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:dinesmart_app/features/admin_dashboard/domain/entities/admin_statistics.dart';
import 'package:dinesmart_app/features/admin_dashboard/domain/use_cases/get_admin_stats_usecase.dart';
import 'package:dinesmart_app/features/admin_dashboard/presentation/pages/admin_overview_page.dart';
import 'package:dinesmart_app/features/admin_dashboard/presentation/state/admin_dashboard_state.dart';
import 'package:dinesmart_app/features/admin_dashboard/presentation/view_model/admin_dashboard_view_model.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/entities/order_entity.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/use_cases/get_orders_usecase.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/use_cases/update_order_status_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_helpers.dart';

void main() {
  late MockGetOrdersUseCase mockGetOrders;
  late MockUpdateOrderStatusUseCase mockUpdateOrderStatus;
  late MockGetAdminStatsUseCase mockGetAdminStats;

  setUp(() {
    mockGetOrders = MockGetOrdersUseCase();
    mockUpdateOrderStatus = MockUpdateOrderStatusUseCase();
    mockGetAdminStats = MockGetAdminStatsUseCase();

    // Default setups
    when(() => mockGetOrders(forceRefresh: any(named: 'forceRefresh'))).thenAnswer((_) async => const Right([]));
    when(() => mockGetAdminStats.getOverview(any())).thenAnswer((_) async => const Right(
      AdminStatistics(
        totalRevenue: 50000,
        totalOrders: 100,
        paidOrders: 80,
        occupiedTables: 5,
        days: 30,
        productsCount: 10,
        customersCount: 10,
        tablesTotal: 20,
      ),
    ));
    when(() => mockGetAdminStats.getSalesOverview(any())).thenAnswer((_) async => const Right([]));
    when(() => mockGetAdminStats.getCategorySales(any())).thenAnswer((_) async => const Right([]));
  });

  Widget createAdminOverviewPage() {
    return ProviderScope(
      overrides: [
        getOrdersUseCaseProvider.overrideWithValue(mockGetOrders),
        updateOrderStatusUseCaseProvider.overrideWithValue(mockUpdateOrderStatus),
        getAdminStatsUseCaseProvider.overrideWithValue(mockGetAdminStats),
      ],
      child: const MaterialApp(
        home: Scaffold(body: AdminOverviewPage()),
      ),
    );
  }

  group('AdminOverviewPage Widget Test', () {
    testWidgets('renders loading state when statistics are null', (tester) async {
      final completer = Completer<Either<Failure, List<OrderEntity>>>();
      when(() => mockGetOrders(forceRefresh: any(named: 'forceRefresh'))).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createAdminOverviewPage());
      await tester.pump(); // Start initialize()
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Clean up
      completer.complete(const Right([]));
      await tester.pump();
    });

    testWidgets('renders statistics cards correctly', (tester) async {
      await tester.pumpWidget(createAdminOverviewPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Net Revenue'), findsOneWidget);
      expect(find.text('NRs. 50000'), findsOneWidget);
      expect(find.text('Paid Orders'), findsOneWidget);
      expect(find.text('80'), findsOneWidget);
      expect(find.text('Occupied Tables'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('renders empty state when no sales data', (tester) async {
      await tester.pumpWidget(createAdminOverviewPage());
      await tester.pumpAndSettle();

      expect(find.text('No sales data'), findsOneWidget);
      expect(find.text('No category data'), findsOneWidget);
    });
  });
}

class MockGetOrdersUseCase extends Mock implements GetOrdersUseCase {}
class MockUpdateOrderStatusUseCase extends Mock implements UpdateOrderStatusUseCase {}
class MockGetAdminStatsUseCase extends Mock implements GetAdminStatsUseCase {}
