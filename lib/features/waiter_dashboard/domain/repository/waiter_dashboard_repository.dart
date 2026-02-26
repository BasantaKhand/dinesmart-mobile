import 'package:dartz/dartz.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import '../entities/table_entity.dart';
import '../entities/category_entity.dart';
import '../entities/menu_item_entity.dart';
import '../entities/order_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/waiter_dashboard_repository_impl.dart';

abstract class IWaiterDashboardRepository {
  Future<Either<Failure, List<TableEntity>>> getTables();
  Future<Either<Failure, List<CategoryEntity>>> getCategories();
  Future<Either<Failure, List<MenuItemEntity>>> getMenuItems();
  Future<Either<Failure, OrderEntity?>> getActiveOrderByTable(String tableId);
  Future<Either<Failure, bool>> createOrder(OrderEntity order);
  Future<Either<Failure, bool>> addItemsToOrder(OrderEntity order);
  Future<Either<Failure, bool>> markBillPrinted(String orderId);
  Future<Either<Failure, List<OrderEntity>>> getOrders();
  Future<Either<Failure, bool>> createCategory(CategoryEntity category);
  Future<Either<Failure, bool>> updateCategory(String id, CategoryEntity category);
  Future<Either<Failure, bool>> deleteCategory(String id);
  // Menu Items CUD
  Future<Either<Failure, bool>> createMenuItem(MenuItemEntity item);
  Future<Either<Failure, bool>> updateMenuItem(String id, MenuItemEntity item);
  Future<Either<Failure, bool>> deleteMenuItem(String id);
  // Tables CUD
  Future<Either<Failure, bool>> createTable(TableEntity table);
  Future<Either<Failure, bool>> updateTable(String id, TableEntity table);
  Future<Either<Failure, bool>> deleteTable(String id);
  Future<Either<Failure, bool>> updateOrderStatus(String orderId, OrderStatus status);
}

final waiterDashboardRepositoryProvider = Provider<IWaiterDashboardRepository>((ref) {
  return ref.read(waiterDashboardRepositoryImplProvider);
});
