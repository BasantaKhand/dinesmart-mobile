import 'package:dinesmart_app/core/api/api_client.dart';
import 'package:dinesmart_app/core/api/api_endpoints.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/staff_api_model.dart';

final staffRemoteDataSourceProvider = Provider((ref) {
  return StaffRemoteDataSource(ref.read(apiClientProvider));
});

class StaffRemoteDataSource {
  final ApiClient _apiClient;

  StaffRemoteDataSource(this._apiClient);

  Future<List<StaffApiModel>> getStaff() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.staff);
      final List data = response.data['data'];
      return data.map((json) => StaffApiModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<StaffApiModel> createStaff(StaffApiModel staff) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.staff, data: staff.toJson());
      return StaffApiModel.fromJson(response.data['data']['staff']);
    } catch (e) {
      rethrow;
    }
  }

  Future<StaffApiModel> updateStaff(String id, StaffApiModel staff) async {
    try {
      final response = await _apiClient.put(ApiEndpoints.staffById(id), data: staff.toJson());
      return StaffApiModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteStaff(String id) async {
    try {
      await _apiClient.delete(ApiEndpoints.staffById(id));
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<StaffApiModel> toggleStaffStatus(String id) async {
    try {
      final response = await _apiClient.patch(ApiEndpoints.toggleStaffStatus(id));
      return StaffApiModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }
}
