import 'package:dartz/dartz.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/table_entity.dart';
import '../../domain/repository/waiter_dashboard_repository.dart';
import '../data_sources/waiter_dashboard_remote_data_source.dart';
import 'package:dio/dio.dart';
import '../models/order_api_model.dart';
import '../models/category_api_model.dart';
import '../models/menu_item_api_model.dart';
import '../models/table_api_model.dart';

final waiterDashboardRepositoryImplProvider = Provider<IWaiterDashboardRepository>((ref) {
  return WaiterDashboardRepositoryImpl(ref.read(waiterDashboardRemoteDataSourceProvider));
});

class WaiterDashboardRepositoryImpl implements IWaiterDashboardRepository {
  final WaiterDashboardRemoteDataSource _remoteDataSource;

  WaiterDashboardRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<TableEntity>>> getTables() async {
    try {
      final models = await _remoteDataSource.getTables();
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Operation failed',
          statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final models = await _remoteDataSource.getCategories();
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Operation failed',
          statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MenuItemEntity>>> getMenuItems() async {
    try {
      final models = await _remoteDataSource.getMenuItems();
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Operation failed',
          statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity?>> getActiveOrderByTable(String tableId) async {
    try {
      final model = await _remoteDataSource.getActiveOrderByTable(tableId);
      return Right(model?.toEntity());
    } on DioException catch (e) {
      return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Operation failed',
          statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> createOrder(OrderEntity order) async {
    try {
      final result = await _remoteDataSource.createOrder(OrderApiModel.fromEntity(order));
      return Right(result);
    } on DioException catch (e) {
      return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Operation failed',
          statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> addItemsToOrder(OrderEntity order) async {
    try {
      final result = await _remoteDataSource.addItemsToOrder(
        order.id,
        OrderApiModel.fromEntity(order),
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Operation failed',
          statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> markBillPrinted(String orderId) async {
    try {
      final result = await _remoteDataSource.markBillPrinted(orderId);
      return Right(result);
    } on DioException catch (e) {
      return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Operation failed',
          statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrders() async {
    try {
      final result = await _remoteDataSource.getOrders();
      return Right(result.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Operation failed',
          statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> createCategory(CategoryEntity category) async {
    try {
      final result = await _remoteDataSource.createCategory(CategoryApiModel.fromEntity(category));
      return Right(result);
    } on DioException catch (e) {
      return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Operation failed',
          statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateCategory(String id, CategoryEntity category) async {
    try {
      final result = await _remoteDataSource.updateCategory(id, CategoryApiModel.fromEntity(category));
      return Right(result);
    } on DioException catch (e) {
      return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Operation failed',
          statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCategory(String id) async {
    try {
      final result = await _remoteDataSource.deleteCategory(id);
      return Right(result);
    } on DioException catch (e) {
      return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Operation failed',
          statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> createMenuItem(MenuItemEntity item) async {
    try {
      final result = await _remoteDataSource.createMenuItem(MenuItemApiModel.fromEntity(item));
      return Right(result);
    } on DioException catch (e) {
      return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Operation failed',
          statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateMenuItem(String id, MenuItemEntity item) async {
    try {
      final result = await _remoteDataSource.updateMenuItem(id, MenuItemApiModel.fromEntity(item));
      return Right(result);
    } on DioException catch (e) {
      return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Operation failed',
          statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteMenuItem(String id) async {
    try {
      final result = await _remoteDataSource.deleteMenuItem(id);
      return Right(result);
    } on DioException catch (e) {
      return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Operation failed',
          statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> createTable(TableEntity table) async {
    try {
      final result = await _remoteDataSource.createTable(TableApiModel.fromEntity(table));
      return Right(result);
    } on DioException catch (e) {
      return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Operation failed',
          statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateTable(String id, TableEntity table) async {
    try {
      final result = await _remoteDataSource.updateTable(id, TableApiModel.fromEntity(table));
      return Right(result);
    } on DioException catch (e) {
      return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Operation failed',
          statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteTable(String id) async {
    try {
      final result = await _remoteDataSource.deleteTable(id);
      return Right(result);
    } on DioException catch (e) {
      return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Operation failed',
          statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final result = await _remoteDataSource.updateOrderStatus(orderId, status.name);
      return Right(result);
    } on DioException catch (e) {
      return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Operation failed',
          statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
