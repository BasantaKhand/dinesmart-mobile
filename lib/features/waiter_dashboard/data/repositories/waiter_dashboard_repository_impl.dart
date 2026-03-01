import 'package:dartz/dartz.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:dinesmart_app/core/services/connectivity/network_info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/table_entity.dart';
import '../../domain/repository/waiter_dashboard_repository.dart';
import '../data_sources/waiter_dashboard_remote_data_source.dart';
import '../data_sources/waiter_local_data_source.dart';
import 'package:dio/dio.dart';
import '../models/order_api_model.dart';
import '../models/category_api_model.dart';
import '../models/menu_item_api_model.dart';
import '../models/table_api_model.dart';

final waiterDashboardRepositoryImplProvider = Provider<IWaiterDashboardRepository>((ref) {
  return WaiterDashboardRepositoryImpl(
    ref.read(waiterDashboardRemoteDataSourceProvider),
    ref.read(waiterLocalDataSourceProvider),
    ref.read(networkInfoProvider),
  );
});

class WaiterDashboardRepositoryImpl implements IWaiterDashboardRepository {
  final WaiterDashboardRemoteDataSource _remoteDataSource;
  final WaiterLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  WaiterDashboardRepositoryImpl(this._remoteDataSource, this._localDataSource, this._networkInfo);

  @override
  Future<Either<Failure, List<TableEntity>>> getTables() async {
    try {
      // Check cache first for tables (short cache duration)
      if (_localDataSource.isTablesCacheValid()) {
        final cached = _localDataSource.getTables();
        if (cached.isNotEmpty) {
          return Right(cached);
        }
      }
      
      // Fetch from remote
      final models = await _remoteDataSource.getTables();
      final entities = models.map((m) => m.toEntity()).toList();
      
      // Save to cache
      await _localDataSource.saveTables(entities);
      
      return Right(entities);
    } on DioException catch (e) {
      // On network error, try to return cached data
      final cached = _localDataSource.getTables();
      if (cached.isNotEmpty) {
        return Right(cached);
      }
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
      // Check cache first
      if (_localDataSource.isCategoryCacheValid()) {
        final cached = _localDataSource.getCategories();
        if (cached.isNotEmpty) {
          return Right(cached);
        }
      }
      
      // Fetch from remote
      final models = await _remoteDataSource.getCategories();
      final entities = models.map((m) => m.toEntity()).toList();
      
      // Save to cache
      await _localDataSource.saveCategories(entities);
      
      return Right(entities);
    } on DioException catch (e) {
      // On network error, try to return cached data
      final cached = _localDataSource.getCategories();
      if (cached.isNotEmpty) {
        return Right(cached);
      }
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
      // Check cache first
      if (_localDataSource.isMenuItemsCacheValid()) {
        final cached = _localDataSource.getMenuItems();
        if (cached.isNotEmpty) {
          return Right(cached);
        }
      }
      
      // Fetch from remote
      final models = await _remoteDataSource.getMenuItems();
      final entities = models.map((m) => m.toEntity()).toList();
      
      // Save to cache
      await _localDataSource.saveMenuItems(entities);
      
      return Right(entities);
    } on DioException catch (e) {
      // On network error, try to return cached data
      final cached = _localDataSource.getMenuItems();
      if (cached.isNotEmpty) {
        return Right(cached);
      }
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
      if (model != null) {
        final entity = model.toEntity();
        await _localDataSource.saveActiveOrder(entity);
        return Right(entity);
      }
      await _localDataSource.removeActiveOrder(tableId);
      return const Right(null);
    } on DioException catch (e) {
      final cached = _localDataSource.getActiveOrderByTable(tableId);
      if (cached != null) {
        return Right(cached);
      }
      return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Operation failed',
          statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> createOrder(OrderEntity order) async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    
    try {
      final result = await _remoteDataSource.createOrder(OrderApiModel.fromEntity(order));
      _localDataSource.invalidateTablesCache();
      _localDataSource.invalidateOrdersCache();
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
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    
    try {
      final result = await _remoteDataSource.addItemsToOrder(
        order.id,
        OrderApiModel.fromEntity(order),
      );
      _localDataSource.invalidateOrdersCache();
      await _localDataSource.saveActiveOrder(order);
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
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    
    try {
      final result = await _remoteDataSource.markBillPrinted(orderId);
      _localDataSource.invalidateOrdersCache();
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
  Future<Either<Failure, List<OrderEntity>>> getOrders({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        _localDataSource.invalidateOrdersCache();
      } else if (_localDataSource.isOrdersCacheValid()) {
        final cached = _localDataSource.getOrders();
        if (cached.isNotEmpty) {
          return Right(cached);
        }
      }
      
      final result = await _remoteDataSource.getOrders();
      final entities = result.map((m) => m.toEntity()).toList();
      await _localDataSource.saveOrders(entities);
      return Right(entities);
    } on DioException catch (e) {
      final cached = _localDataSource.getOrders();
      if (cached.isNotEmpty) {
        return Right(cached);
      }
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
      _localDataSource.invalidateCategoriesCache();
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
      _localDataSource.invalidateCategoriesCache();
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
      _localDataSource.invalidateCategoriesCache();
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
      _localDataSource.invalidateMenuItemsCache();
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
      _localDataSource.invalidateMenuItemsCache();
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
      _localDataSource.invalidateMenuItemsCache();
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
      _localDataSource.invalidateTablesCache();
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
      _localDataSource.invalidateTablesCache();
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
      _localDataSource.invalidateTablesCache();
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
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    
    final apiStatus = _toApiOrderStatus(status);
    try {
      final result = await _remoteDataSource.updateOrderStatus(orderId, apiStatus);
      _localDataSource.invalidateOrdersCache();
      // Invalidate tables cache for status changes that affect table availability
      if (status == OrderStatus.cancelled || status == OrderStatus.completed) {
        _localDataSource.invalidateTablesCache();
      }
      return Right(result);
    } on DioException catch (e) {
      return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Operation failed',
          statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  String _toApiOrderStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'PENDING';
      case OrderStatus.cooking:
        return 'COOKING';
      case OrderStatus.cooked:
        return 'COOKED';
      case OrderStatus.served:
        return 'SERVED';
      case OrderStatus.completed:
        return 'COMPLETED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
      case OrderStatus.billPrinted:
        return 'COMPLETED';
    }
  }
}
