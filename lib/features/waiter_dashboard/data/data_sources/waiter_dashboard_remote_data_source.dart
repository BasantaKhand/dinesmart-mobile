import 'package:dio/dio.dart';
import 'package:dinesmart_app/core/api/api_client.dart';
import 'package:dinesmart_app/core/api/api_endpoints.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/table_api_model.dart';
import '../models/category_api_model.dart';
import '../models/menu_item_api_model.dart';
import '../models/order_api_model.dart';

final waiterDashboardRemoteDataSourceProvider = Provider((ref) {
  return WaiterDashboardRemoteDataSource(ref.read(apiClientProvider));
});

class WaiterDashboardRemoteDataSource {
  final ApiClient _apiClient;

  WaiterDashboardRemoteDataSource(this._apiClient);

  Future<List<TableApiModel>> getTables() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.tables);
      final List data = response.data['data'];
      return data.map((json) => TableApiModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CategoryApiModel>> getCategories() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.categories);
      final List data = response.data['data'];
      return data.map((json) => CategoryApiModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MenuItemApiModel>> getMenuItems() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.menuItems);
      final List data = response.data['data'];
      return data.map((json) => MenuItemApiModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<OrderApiModel?> getActiveOrderByTable(String tableId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.activeOrderByTable(tableId));
      if (response.data['data'] == null) return null;
      return OrderApiModel.fromJson(response.data['data']);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<bool> createOrder(OrderApiModel order) async {
    try {
      await _apiClient.post(ApiEndpoints.orders, data: order.toJson());
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> addItemsToOrder(String orderId, OrderApiModel order) async {
    try {
      await _apiClient.put(ApiEndpoints.appendItemsToOrder(orderId), data: order.toJson());
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> markBillPrinted(String orderId) async {
    try {
      await _apiClient.patch(ApiEndpoints.markBillPrinted(orderId));
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<OrderApiModel>> getOrders() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.orders);
      final List data = response.data['data'];
      return data.map((json) => OrderApiModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createCategory(CategoryApiModel category) async {
    try {
      await _apiClient.post(ApiEndpoints.categories, data: category.toJson());
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateCategory(String id, CategoryApiModel category) async {
    try {
      await _apiClient.put('${ApiEndpoints.categories}/$id', data: category.toJson());
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      await _apiClient.delete('${ApiEndpoints.categories}/$id');
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // Menu Items CUD
  Future<bool> createMenuItem(MenuItemApiModel item) async {
    try {
      await _apiClient.post(ApiEndpoints.menuItems, data: item.toJson());
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateMenuItem(String id, MenuItemApiModel item) async {
    try {
      await _apiClient.put('${ApiEndpoints.menuItems}/$id', data: item.toJson());
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteMenuItem(String id) async {
    try {
      await _apiClient.delete('${ApiEndpoints.menuItems}/$id');
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // Tables CUD
  Future<bool> createTable(TableApiModel table) async {
    try {
      await _apiClient.post(ApiEndpoints.tables, data: table.toJson());
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateTable(String id, TableApiModel table) async {
    try {
      await _apiClient.put('${ApiEndpoints.tables}/$id', data: table.toJson());
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteTable(String id) async {
    try {
      await _apiClient.delete('${ApiEndpoints.tables}/$id');
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await _apiClient.patch(
        ApiEndpoints.updateOrderStatus(orderId),
        data: {'status': status},
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
