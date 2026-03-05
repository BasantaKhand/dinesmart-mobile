import 'package:cached_network_image/cached_network_image.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/entities/order_entity.dart';
import 'package:dinesmart_app/features/waiter_dashboard/presentation/state/waiter_dashboard_state.dart';
import 'package:dinesmart_app/features/waiter_dashboard/presentation/view_model/waiter_dashboard_view_model.dart';
import 'package:dinesmart_app/features/waiter_dashboard/presentation/widgets/bill_summary_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_helpers.dart';

class MockWaiterDashboardViewModel extends StateNotifier<WaiterDashboardState>
    with Mock
    implements WaiterDashboardViewModel {
  MockWaiterDashboardViewModel(super.state);
}

void main() {
  setUpAll(() {
    // Mock CachedNetworkImage to avoid network requests during tests
    // In a real project, you might use a mock package or a custom image provider
  });

  Widget buildWidget(WaiterDashboardState state, {VoidCallback? onCreateOrder}) {
    final mockVM = MockWaiterDashboardViewModel(state);
    return ProviderScope(
      overrides: [
        waiterDashboardViewModelProvider.overrideWith((ref) => mockVM),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: BillSummarySheet(
            state: state,
            onCreateOrder: onCreateOrder ?? () {},
          ),
        ),
      ),
    );
  }

  group('BillSummarySheet', () {
    testWidgets('renders empty state when no items', (tester) async {
      const state = WaiterDashboardState(
        isBillExpanded: true,
        selectedTable: null,
        activeOrder: null,
        cart: [],
      );

      await tester.pumpWidget(buildWidget(state));
      await tester.pump();

      expect(find.text('No items yet'), findsOneWidget);
      expect(find.text('Bill Summary'), findsOneWidget);
    });

    testWidgets('renders cart items correctly', (tester) async {
      final cartItem = TestData.orderItemEntity(name: 'Pizza', price: 500, quantity: 1);
      final state = WaiterDashboardState(
        isBillExpanded: true,
        selectedTable: TestData.tableEntity(number: '5'),
        activeOrder: null,
        cart: [cartItem],
      );

      await tester.pumpWidget(buildWidget(state));
      await tester.pump();

      expect(find.text('New Items (1)'), findsOneWidget);
      expect(find.text('Pizza'), findsOneWidget);
      expect(find.textContaining('500'), findsWidgets);
      expect(find.text('Recipient : Table 5'), findsOneWidget);
    });

    testWidgets('renders active order items correctly', (tester) async {
      final activeItem = TestData.orderItemEntity(name: 'Burger', price: 300, quantity: 2);
      final activeOrder = TestData.orderEntity(
        items: [activeItem],
        status: OrderStatus.cooking,
      );
      final state = WaiterDashboardState(
        isBillExpanded: true,
        selectedTable: TestData.tableEntity(number: '2'),
        activeOrder: activeOrder,
        cart: [],
      );

      await tester.pumpWidget(buildWidget(state));
      await tester.pump();

      expect(find.text('Order Items (1)'), findsOneWidget);
      expect(find.text('Burger'), findsOneWidget);
      expect(find.text('COOKING'), findsWidgets); // Status card and badge
    });

    testWidgets('shows totals correctly', (tester) async {
      final cartItem = TestData.orderItemEntity(name: 'Pizza', price: 1000, quantity: 1);
      final state = WaiterDashboardState(
        isBillExpanded: true,
        selectedTable: TestData.tableEntity(number: '5'),
        activeOrder: null,
        cart: [cartItem],
      );

      await tester.pumpWidget(buildWidget(state));
      await tester.pump();

      // Subtotal: 1000
      // Tax (13%): 130
      // Total: 1130
      expect(find.text('NRs. 1000'), findsAtLeastNWidgets(1));
      expect(find.text('NRs. 130'), findsAtLeastNWidgets(1));
      expect(find.text('NRs. 1130'), findsAtLeastNWidgets(1));
    });

    testWidgets('calls toggleBillExpansion when header is tapped (expanded)', (tester) async {
      final state = WaiterDashboardState(
        isBillExpanded: true,
        selectedTable: TestData.tableEntity(number: '5'),
        activeOrder: null,
        cart: [],
      );

      final mockVM = MockWaiterDashboardViewModel(state);
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            waiterDashboardViewModelProvider.overrideWith((ref) => mockVM),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BillSummarySheet(
                state: state,
                onCreateOrder: () {},
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Bill Summary'));
      await tester.pump();

      verify(() => mockVM.toggleBillExpansion()).called(1);
    });
  });
}
