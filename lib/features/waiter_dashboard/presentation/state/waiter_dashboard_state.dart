import 'package:equatable/equatable.dart';
import '../../domain/entities/table_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/entities/order_entity.dart';

enum WaiterDashboardStatus { initial, loading, success, error }
enum SortOrder { none, ascending, descending }

class WaiterDashboardState extends Equatable {
  final WaiterDashboardStatus status;
  final List<TableEntity> tables;
  final List<CategoryEntity> categories;
  final List<MenuItemEntity> menuItems;
  final TableEntity? selectedTable;
  final CategoryEntity? selectedCategory;
  final SortOrder sortPriceOrder;
  final OrderEntity? activeOrder;
  final List<OrderItemEntity> cart;
  final bool isBillExpanded;
  final String? errorMessage;

  const WaiterDashboardState({
    this.status = WaiterDashboardStatus.initial,
    this.tables = const [],
    this.categories = const [],
    this.menuItems = const [],
    this.selectedTable,
    this.selectedCategory,
    this.sortPriceOrder = SortOrder.none,
    this.activeOrder,
    this.cart = const [],
    this.isBillExpanded = false,
    this.errorMessage,
  });

  WaiterDashboardState copyWith({
    WaiterDashboardStatus? status,
    List<TableEntity>? tables,
    List<CategoryEntity>? categories,
    List<MenuItemEntity>? menuItems,
    TableEntity? selectedTable,
    CategoryEntity? selectedCategory,
    SortOrder? sortPriceOrder,
    OrderEntity? activeOrder,
    List<OrderItemEntity>? cart,
    bool? isBillExpanded,
    String? errorMessage,
  }) {
    return WaiterDashboardState(
      status: status ?? this.status,
      tables: tables ?? this.tables,
      categories: categories ?? this.categories,
      menuItems: menuItems ?? this.menuItems,
      selectedTable: selectedTable ?? this.selectedTable,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      sortPriceOrder: sortPriceOrder ?? this.sortPriceOrder,
      activeOrder: activeOrder ?? this.activeOrder,
      cart: cart ?? this.cart,
      isBillExpanded: isBillExpanded ?? this.isBillExpanded,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        tables,
        categories,
        menuItems,
        selectedTable,
        selectedCategory,
        sortPriceOrder,
        activeOrder,
        cart,
        isBillExpanded,
        errorMessage,
      ];
}
