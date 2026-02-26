import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dinesmart_app/core/api/api_client.dart';
import 'package:dinesmart_app/core/api/api_endpoints.dart';
import 'package:dinesmart_app/features/cashier_dashboard/data/models/cashier_models.dart';

final cashierRemoteDataSourceProvider = Provider((ref) {
  return CashierRemoteDataSource(ref.read(apiClientProvider));
});

class CashierRemoteDataSource {
  final ApiClient _apiClient;

  CashierRemoteDataSource(this._apiClient);

  Future<CashierStatsModel> getCashierStats() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.paymentQueueStatus);
      return CashierStatsModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PaymentQueueItemModel>> getPaymentQueue() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.paymentQueue);
      final List data = response.data['data'];
      return data.map((json) => PaymentQueueItemModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> settlePayment(String orderId, String paymentMethod, {String? transactionId, String? notes}) async {
    try {
      await _apiClient.put(
        ApiEndpoints.updateOrderStatus(orderId),
        data: {
          'status': 'COMPLETED',
          'paymentStatus': 'PAID',
          'paymentMethod': paymentMethod,
          if (transactionId != null) 'transactionId': transactionId,
          if (notes != null) 'notes': notes,
        },
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> openCashDrawer(double openingAmount, {String? notes}) async {
    try {
      await _apiClient.post(
        ApiEndpoints.cashDrawerStatus, // Need to double check endpoint logic, usually /api/cash-drawer/open
        data: {
          'openingAmount': openingAmount,
          if (notes != null) 'notes': notes,
        },
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
