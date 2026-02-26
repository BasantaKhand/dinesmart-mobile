import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/admin_stats_model.dart';

final adminDashboardRemoteDataSourceProvider = Provider((ref) {
  return AdminDashboardRemoteDataSource(ref.read(apiClientProvider));
});

class AdminDashboardRemoteDataSource {
  final ApiClient _apiClient;

  AdminDashboardRemoteDataSource(this._apiClient);

  Future<AdminStatisticsModel> getOverview(int days) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.dashboardOverview,
        queryParameters: {'days': days},
      );
      return AdminStatisticsModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SalesDataModel>> getSalesOverview(int days) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.dashboardSalesOverview,
        queryParameters: {'days': days},
      );
      final List data = response.data['data'];
      return data.map((json) => SalesDataModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CategorySalesDataModel>> getCategorySales(int days) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.dashboardCategorySales,
        queryParameters: {'days': days},
      );
      final List data = response.data['data'];
      return data.map((json) => CategorySalesDataModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
