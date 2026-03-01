import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dinesmart_app/core/services/socket/socket_service.dart';
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
import '../../domain/use_cases/update_order_status_usecase.dart';
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
    updateOrderStatusUseCase: ref.read(updateOrderStatusUseCaseProvider),
    socketService: ref.read(socketServiceProvider),
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
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;
  final SocketService socketService;

  WaiterDashboardViewModel({
    required this.ref,
    required this.getTablesUseCase,
    required this.getCategoriesUseCase,
    required this.getMenuItemsUseCase,
    required this.getActiveOrderUseCase,
    required this.createOrderUseCase,
    required this.addItemsUseCase,
    required this.updateOrderStatusUseCase,
    required this.socketService,
  }) : super(const WaiterDashboardState()) {
    _initializeWithSocket();
  }

  void _initializeWithSocket() {
    socketService.connect();
    socketService.addListener(_handleSocketNotification);
    initialize();
  }

  void _handleSocketNotification(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    if (type != null && _isRelevantNotification(type)) {
      debugPrint('Socket: Handling notification type=$type');
      refreshTables();
      if (state.selectedTable != null) {
        _refreshActiveOrder();
      }
    }
  }

  bool _isRelevantNotification(String type) {
    return [
      'NEW_ORDER',
      'ORDER_STATUS_UPDATE',
      'ORDER_READY',
      'ORDER_SERVED',
      'ORDER_COMPLETED',
      'ORDER_CANCELLED',
      'PAYMENT_VERIFIED',
    ].contains(type);
  }

  Future<void> _refreshActiveOrder() async {
    if (state.selectedTable == null) return;
    
    final activeOrderResult = await getActiveOrderUseCase(state.selectedTable!.id);
    activeOrderResult.fold(
      (failure) => state = state.copyWith(activeOrder: null),
      (order) => state = state.copyWith(activeOrder: order),
    );
  }

  @override
  void dispose() {
    socketService.removeListener(_handleSocketNotification);
    super.dispose();
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
              (menuItems) {
                final updatedSelectedTable = state.selectedTable != null
                    ? tables.firstWhere(
                        (t) => t.id == state.selectedTable!.id,
                        orElse: () => state.selectedTable!,
                      )
                    : null;
                state = state.copyWith(
                  status: WaiterDashboardStatus.success,
                  tables: tables,
                  categories: categories,
                  menuItems: menuItems,
                  selectedTable: updatedSelectedTable,
                );
              },
            );
          },
        );
      },
    );

    if (state.selectedTable != null) {
      final activeOrderResult = await getActiveOrderUseCase(state.selectedTable!.id);
      activeOrderResult.fold(
        (failure) => state = state.copyWith(activeOrder: null),
        (order) => state = state.copyWith(activeOrder: order),
      );
    }
  }

  void selectTable(TableEntity table) async {
    state = state.copyWith(
      selectedTable: table,
      cart: [],
      isBillExpanded: true,
      activeOrder: null,
    );
    
    final activeOrderResult = await getActiveOrderUseCase(table.id);
    activeOrderResult.fold(
      (failure) => state = state.copyWith(activeOrder: null), 
      (order) => state = state.copyWith(activeOrder: order),
    );
  }

  Future<void> refreshTables() async {
    final tablesResult = await getTablesUseCase();
    tablesResult.fold(
      (failure) {},
      (tables) {
        final updatedSelectedTable = state.selectedTable != null
            ? tables.firstWhere(
                (t) => t.id == state.selectedTable!.id,
                orElse: () => state.selectedTable!,
              )
            : null;
        state = state.copyWith(
          tables: tables,
          selectedTable: updatedSelectedTable,
        );
      },
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
    final activeStatus = state.activeOrder?.status;
    if (activeStatus == OrderStatus.completed ||
        activeStatus == OrderStatus.cancelled ||
        activeStatus == OrderStatus.billPrinted) {
      return;
    }

    final existingIndex = state.cart.indexWhere((i) => i.menuItemId == item.id);
    if (existingIndex >= 0) {
      final updatedCart = List<OrderItemEntity>.from(state.cart);
      final existingItem = updatedCart[existingIndex];
      updatedCart[existingIndex] = OrderItemEntity(
        menuItemId: existingItem.menuItemId,
        imageUrl: existingItem.imageUrl,
        name: existingItem.name,
        price: existingItem.price,
        quantity: existingItem.quantity + 1,
        total: (existingItem.quantity + 1) * existingItem.price,
        status: existingItem.status,
        notes: existingItem.notes,
      );
      state = state.copyWith(cart: updatedCart, isBillExpanded: true);
    } else {
      state = state.copyWith(cart: [
        ...state.cart,
        OrderItemEntity(
          menuItemId: item.id,
          imageUrl: item.image,
          name: item.name,
          price: item.price,
          quantity: 1,
          total: item.price,
        ),
      ], isBillExpanded: true);
    }
  }

  void updateCartItemNote(String menuItemId, String? note) {
    final updatedCart = state.cart
        .map((item) {
          if (item.menuItemId != menuItemId) return item;
          final normalizedNote = (note ?? '').trim();
          return OrderItemEntity(
            menuItemId: item.menuItemId,
            imageUrl: item.imageUrl,
            name: item.name,
            price: item.price,
            quantity: item.quantity,
            total: item.total,
            status: item.status,
            notes: normalizedNote.isEmpty ? null : normalizedNote,
          );
        })
        .toList();

    state = state.copyWith(cart: updatedCart);
  }

  void toggleBillExpansion() {
    state = state.copyWith(isBillExpanded: !state.isBillExpanded);
  }

  void updateCartItemQuantity(String menuItemId, int delta) {
    final updatedCart = <OrderItemEntity>[];
    for (final item in state.cart) {
      if (item.menuItemId != menuItemId) {
        updatedCart.add(item);
      } else {
        final newQuantity = item.quantity + delta;
        if (newQuantity > 0) {
          updatedCart.add(OrderItemEntity(
            menuItemId: item.menuItemId,
            imageUrl: item.imageUrl,
            name: item.name,
            price: item.price,
            quantity: newQuantity,
            total: newQuantity * item.price,
            status: item.status,
            notes: item.notes,
          ));
        }
      }
    }
    state = state.copyWith(cart: updatedCart);
  }

  void removeFromCart(String menuItemId) {
    final updatedCart = state.cart.where((i) => i.menuItemId != menuItemId).toList();
    state = state.copyWith(cart: updatedCart);
  }

  Future<void> createOrder() async {
    if (state.selectedTable == null || state.cart.isEmpty) return;
    final activeStatus = state.activeOrder?.status;
    if (activeStatus == OrderStatus.completed ||
        activeStatus == OrderStatus.cancelled ||
        activeStatus == OrderStatus.billPrinted) {
      return;
    }

    state = state.copyWith(status: WaiterDashboardStatus.loading);

    final subtotal = state.cart.fold(0.0, (acc, item) => acc + item.total);
    final tax = subtotal * 0.13;
    final total = subtotal + tax;

    final order = OrderEntity(
      id: state.activeOrder?.id ?? '',
      tableId: state.selectedTable!.id,
      items: state.cart,
      status: OrderStatus.cooking,
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
      (success) async {
        state = state.copyWith(status: WaiterDashboardStatus.success, cart: []);
        await refreshTables();
        if (state.selectedTable != null) {
          final activeOrderResult = await getActiveOrderUseCase(state.selectedTable!.id);
          activeOrderResult.fold(
            (failure) {},
            (order) => state = state.copyWith(activeOrder: order),
          );
        }
      },
    );
  }

  Future<void> markOrderServed() async {
    if (state.activeOrder == null || state.selectedTable == null) return;
    if (state.activeOrder!.status != OrderStatus.cooked) return;

    state = state.copyWith(status: WaiterDashboardStatus.loading);
    final result = await updateOrderStatusUseCase(
      state.activeOrder!.id,
      OrderStatus.served,
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: WaiterDashboardStatus.error,
        errorMessage: failure.message,
      ),
      (_) {
        state = state.copyWith(status: WaiterDashboardStatus.success);
        selectTable(state.selectedTable!);
      },
    );
  }

  Future<void> markOrderCompleted() async {
    if (state.activeOrder == null || state.selectedTable == null) return;
    if (state.activeOrder!.status != OrderStatus.served) return;

    state = state.copyWith(status: WaiterDashboardStatus.loading);
    final result = await updateOrderStatusUseCase(
      state.activeOrder!.id,
      OrderStatus.completed,
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: WaiterDashboardStatus.error,
        errorMessage: failure.message,
      ),
      (_) async {
        state = state.copyWith(status: WaiterDashboardStatus.success, activeOrder: null);
        await refreshTables();
      },
    );
  }

  Future<void> cancelPendingOrder() async {
    if (state.activeOrder == null || state.selectedTable == null) return;
    if (state.activeOrder!.status != OrderStatus.pending) return;

    state = state.copyWith(status: WaiterDashboardStatus.loading);
    final result = await updateOrderStatusUseCase(
      state.activeOrder!.id,
      OrderStatus.cancelled,
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: WaiterDashboardStatus.error,
        errorMessage: failure.message,
      ),
      (_) async {
        state = state.copyWith(status: WaiterDashboardStatus.success, cart: [], activeOrder: null);
        await refreshTables();
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
        initialize();
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
        initialize();
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
        initialize();
      },
    );
  }

  Future<void> createMenuItem(MenuItemEntity item) async {
    state = state.copyWith(status: WaiterDashboardStatus.loading);
    final result = await ref.read(waiterDashboardRepositoryProvider).createMenuItem(item);
    result.fold(
      (failure) => state = state.copyWith(status: WaiterDashboardStatus.error, errorMessage: failure.message),
      (success) {
        state = state.copyWith(status: WaiterDashboardStatus.success);
        initialize();
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
        initialize();
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
        initialize();
      },
    );
  }

  Future<void> createTable(TableEntity table) async {
    state = state.copyWith(status: WaiterDashboardStatus.loading);
    final result = await ref.read(waiterDashboardRepositoryProvider).createTable(table);
    result.fold(
      (failure) => state = state.copyWith(status: WaiterDashboardStatus.error, errorMessage: failure.message),
      (success) {
        state = state.copyWith(status: WaiterDashboardStatus.success);
        initialize();
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
        initialize();
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
        initialize();
      },
    );
  }
}

