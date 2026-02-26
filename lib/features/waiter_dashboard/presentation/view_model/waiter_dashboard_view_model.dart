import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/table_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/use_cases/get_tables_usecase.dart';
import '../../domain/use_cases/get_categories_usecase.dart';
import '../../domain/use_cases/get_menu_items_usecase.dart';
import '../../domain/use_cases/get_active_order_usecase.dart';
import '../../domain/use_cases/create_order_usecase.dart';
import '../../domain/use_cases/add_items_usecase.dart';
import '../../domain/use_cases/mark_bill_printed_usecase.dart';
import '../state/waiter_dashboard_state.dart';

import 'package:dinesmart_app/features/waiter_dashboard/domain/repository/waiter_dashboard_repository.dart';

final waiterDashboardViewModelProvider =
    StateNotifierProvider<WaiterDashboardViewModel, WaiterDashboardState>((ref) {
  return WaiterDashboardViewModel(
    ref: ref,
    getTablesUseCase: ref.read(getTablesUseCaseProvider),
    getCategoriesUseCase: ref.read(getCategoriesUseCaseProvider),
    getMenuItemsUseCase: ref.read(getMenuItemsUseCaseProvider),
    getActiveOrderUseCase: ref.read(getActiveOrderUseCaseProvider),
    createOrderUseCase: ref.read(createOrderUseCaseProvider),
    addItemsUseCase: ref.read(addItemsUseCaseProvider),
    markBillPrintedUseCase: ref.read(markBillPrintedUseCaseProvider),
  );
});

class WaiterDashboardViewModel extends StateNotifier<WaiterDashboardState> {
  final Ref ref;
  final GetTablesUseCase getTablesUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetMenuItemsUseCase getMenuItemsUseCase;
  final GetActiveOrderUseCase getActiveOrderUseCase;
  final CreateOrderUseCase createOrderUseCase;
  final AddItemsUseCase addItemsUseCase;
  final MarkBillPrintedUseCase markBillPrintedUseCase;

  WaiterDashboardViewModel({
    required this.ref,
    required this.getTablesUseCase,
    required this.getCategoriesUseCase,
    required this.getMenuItemsUseCase,
    required this.getActiveOrderUseCase,
    required this.createOrderUseCase,
    required this.addItemsUseCase,
    required this.markBillPrintedUseCase,
  }) : super(const WaiterDashboardState()) {
    initialize();
  }

  Future<void> initialize() async {
    state = state.copyWith(status: WaiterDashboardStatus.loading);
    
    final tablesResult = await getTablesUseCase();
    final categoriesResult = await getCategoriesUseCase();
    final menuItemsResult = await getMenuItemsUseCase();

    tablesResult.fold(
      (failure) => state = state.copyWith(status: WaiterDashboardStatus.error, errorMessage: failure.message),
      (tables) {
        categoriesResult.fold(
          (failure) => state = state.copyWith(status: WaiterDashboardStatus.error, errorMessage: failure.message),
          (categories) {
            menuItemsResult.fold(
              (failure) => state = state.copyWith(status: WaiterDashboardStatus.error, errorMessage: failure.message),
              (menuItems) => state = state.copyWith(
                status: WaiterDashboardStatus.success,
                tables: tables,
                categories: categories,
                menuItems: menuItems,
              ),
            );
          },
        );
      },
    );
  }

  void selectTable(TableEntity table) async {
    state = state.copyWith(selectedTable: table, cart: [], isBillExpanded: true);
    
    final activeOrderResult = await getActiveOrderUseCase(table.id);
    activeOrderResult.fold(
      (failure) => state = state.copyWith(activeOrder: null), 
      (order) => state = state.copyWith(activeOrder: order),
    );
  }

  void selectCategory(CategoryEntity? category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setSortPriceOrder(SortOrder order) {
    state = state.copyWith(sortPriceOrder: order);
  }

  void toggleSortPriceOrder() {
    final nextOrder = state.sortPriceOrder == SortOrder.none
        ? SortOrder.ascending
        : (state.sortPriceOrder == SortOrder.ascending
            ? SortOrder.descending
            : SortOrder.none);
    state = state.copyWith(sortPriceOrder: nextOrder);
  }

  void addToCart(MenuItemEntity item) {
    if (state.selectedTable == null) return;

    final existingIndex = state.cart.indexWhere((i) => i.menuItemId == item.id);
    if (existingIndex >= 0) {
      final updatedCart = List<OrderItemEntity>.from(state.cart);
      final existingItem = updatedCart[existingIndex];
      updatedCart[existingIndex] = OrderItemEntity(
        menuItemId: existingItem.menuItemId,
        name: existingItem.name,
        price: existingItem.price,
        quantity: existingItem.quantity + 1,
        total: (existingItem.quantity + 1) * existingItem.price,
      );
      state = state.copyWith(cart: updatedCart, isBillExpanded: true);
    } else {
      state = state.copyWith(cart: [
        ...state.cart,
        OrderItemEntity(
          menuItemId: item.id,
          name: item.name,
          price: item.price,
          quantity: 1,
          total: item.price,
        ),
      ], isBillExpanded: true);
    }
  }

  void toggleBillExpansion() {
    state = state.copyWith(isBillExpanded: !state.isBillExpanded);
  }

  void removeFromCart(String menuItemId) {
    final updatedCart = state.cart.where((i) => i.menuItemId != menuItemId).toList();
    state = state.copyWith(cart: updatedCart);
  }

  Future<void> createOrder() async {
    if (state.selectedTable == null || state.cart.isEmpty) return;

    state = state.copyWith(status: WaiterDashboardStatus.loading);

    final subtotal = state.cart.fold(0.0, (acc, item) => acc + item.total);
    final tax = subtotal * 0.13;
    final total = subtotal + tax;

    final order = OrderEntity(
      id: state.activeOrder?.id ?? '',
      tableId: state.selectedTable!.id,
      items: state.cart,
      status: OrderStatus.COOKING,
      subtotal: subtotal,
      tax: tax,
      vat: tax,
      total: total,
    );

    final result = state.activeOrder != null
        ? await addItemsUseCase(order)
        : await createOrderUseCase(order);

    result.fold(
      (failure) => state = state.copyWith(status: WaiterDashboardStatus.error, errorMessage: failure.message),
      (success) {
        state = state.copyWith(status: WaiterDashboardStatus.success, cart: []);
        // Refresh to update table status and active order
        selectTable(state.selectedTable!);
      },
    );
  }

  Future<void> printBill() async {
    if (state.activeOrder == null) return;

    state = state.copyWith(status: WaiterDashboardStatus.loading);
    
    final result = await markBillPrintedUseCase(state.activeOrder!.id);
    
    result.fold(
      (failure) => state = state.copyWith(status: WaiterDashboardStatus.error, errorMessage: failure.message),
      (success) {
        state = state.copyWith(status: WaiterDashboardStatus.success);
        selectTable(state.selectedTable!); // Refresh
      },
    );
  }

  Future<void> createCategory(CategoryEntity category) async {
    state = state.copyWith(status: WaiterDashboardStatus.loading);
    final result = await ref.read(waiterDashboardRepositoryProvider).createCategory(category);
    result.fold(
      (failure) => state = state.copyWith(status: WaiterDashboardStatus.error, errorMessage: failure.message),
      (success) {
        state = state.copyWith(status: WaiterDashboardStatus.success);
        initialize(); // Refresh items
      },
    );
  }

  Future<void> updateCategory(String id, CategoryEntity category) async {
    state = state.copyWith(status: WaiterDashboardStatus.loading);
    final result = await ref.read(waiterDashboardRepositoryProvider).updateCategory(id, category);
    result.fold(
      (failure) => state = state.copyWith(status: WaiterDashboardStatus.error, errorMessage: failure.message),
      (success) {
        state = state.copyWith(status: WaiterDashboardStatus.success);
        initialize(); // Refresh items
      },
    );
  }

  Future<void> deleteCategory(String id) async {
    state = state.copyWith(status: WaiterDashboardStatus.loading);
    final result = await ref.read(waiterDashboardRepositoryProvider).deleteCategory(id);
    result.fold(
      (failure) => state = state.copyWith(status: WaiterDashboardStatus.error, errorMessage: failure.message),
      (success) {
        state = state.copyWith(status: WaiterDashboardStatus.success);
        initialize(); // Refresh items
      },
    );
  }

  // Menu Items CRUD
  Future<void> createMenuItem(MenuItemEntity item) async {
    state = state.copyWith(status: WaiterDashboardStatus.loading);
    final result = await ref.read(waiterDashboardRepositoryProvider).createMenuItem(item);
    result.fold(
      (failure) => state = state.copyWith(status: WaiterDashboardStatus.error, errorMessage: failure.message),
      (success) {
        state = state.copyWith(status: WaiterDashboardStatus.success);
        initialize(); // Refresh items
      },
    );
  }

  Future<void> updateMenuItem(String id, MenuItemEntity item) async {
    state = state.copyWith(status: WaiterDashboardStatus.loading);
    final result = await ref.read(waiterDashboardRepositoryProvider).updateMenuItem(id, item);
    result.fold(
      (failure) => state = state.copyWith(status: WaiterDashboardStatus.error, errorMessage: failure.message),
      (success) {
        state = state.copyWith(status: WaiterDashboardStatus.success);
        initialize(); // Refresh items
      },
    );
  }

  Future<void> deleteMenuItem(String id) async {
    state = state.copyWith(status: WaiterDashboardStatus.loading);
    final result = await ref.read(waiterDashboardRepositoryProvider).deleteMenuItem(id);
    result.fold(
      (failure) => state = state.copyWith(status: WaiterDashboardStatus.error, errorMessage: failure.message),
      (success) {
        state = state.copyWith(status: WaiterDashboardStatus.success);
        initialize(); // Refresh items
      },
    );
  }

  // Tables CRUD
  Future<void> createTable(TableEntity table) async {
    state = state.copyWith(status: WaiterDashboardStatus.loading);
    final result = await ref.read(waiterDashboardRepositoryProvider).createTable(table);
    result.fold(
      (failure) => state = state.copyWith(status: WaiterDashboardStatus.error, errorMessage: failure.message),
      (success) {
        state = state.copyWith(status: WaiterDashboardStatus.success);
        initialize(); // Refresh items
      },
    );
  }

  Future<void> updateTable(String id, TableEntity table) async {
    state = state.copyWith(status: WaiterDashboardStatus.loading);
    final result = await ref.read(waiterDashboardRepositoryProvider).updateTable(id, table);
    result.fold(
      (failure) => state = state.copyWith(status: WaiterDashboardStatus.error, errorMessage: failure.message),
      (success) {
        state = state.copyWith(status: WaiterDashboardStatus.success);
        initialize(); // Refresh items
      },
    );
  }

  Future<void> deleteTable(String id) async {
    state = state.copyWith(status: WaiterDashboardStatus.loading);
    final result = await ref.read(waiterDashboardRepositoryProvider).deleteTable(id);
    result.fold(
      (failure) => state = state.copyWith(status: WaiterDashboardStatus.error, errorMessage: failure.message),
      (success) {
        state = state.copyWith(status: WaiterDashboardStatus.success);
        initialize(); // Refresh items
      },
    );
  }
}

