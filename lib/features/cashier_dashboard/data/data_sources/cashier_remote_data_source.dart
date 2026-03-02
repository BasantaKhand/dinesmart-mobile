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

  /// Fetch payment queue: orders that are SERVED/COMPLETED with paymentStatus PENDING
  /// Uses: GET /api/orders?status=SERVED&paymentStatus=PENDING
  Future<List<PaymentQueueItemModel>> getPaymentQueue() async {
    try {
      // Fetch SERVED orders pending payment
      final servedResponse = await _apiClient.get(
        ApiEndpoints.orders,
        queryParameters: {'status': 'SERVED', 'paymentStatus': 'PENDING', 'limit': '50'},
      );
      final List servedData = servedResponse.data['data'] ?? [];

      // Fetch COMPLETED orders pending payment
      final completedResponse = await _apiClient.get(
        ApiEndpoints.orders,
        queryParameters: {'status': 'COMPLETED', 'paymentStatus': 'PENDING', 'limit': '50'},
      );
      final List completedData = completedResponse.data['data'] ?? [];

      final allData = [...servedData, ...completedData];
      return allData.map((json) => PaymentQueueItemModel.fromOrderJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch recent settlements: orders with paymentStatus PAID (today)
  /// Uses: GET /api/orders?paymentStatus=PAID&limit=20
  Future<List<SettlementModel>> getRecentSettlements() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.orders,
        queryParameters: {'paymentStatus': 'PAID', 'limit': '20'},
      );
      final List data = response.data['data'] ?? [];
      return data.map((json) => SettlementModel.fromOrderJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Settle a payment: PUT /api/orders/:id/status
  Future<bool> settlePayment(
    String orderId,
    String paymentMethod, {
    String? transactionId,
    String? notes,
  }) async {
    try {
      await _apiClient.put(
        ApiEndpoints.updateOrderStatus(orderId),
        data: {
          'status': 'COMPLETED',
          'paymentStatus': 'PAID',
          'paymentMethod': paymentMethod,
          'paymentProvider': paymentMethod == 'QR' ? 'ESEWA' : 'MANUAL',
          if (transactionId != null && transactionId.isNotEmpty) 'paymentReference': transactionId,
        },
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Get cash drawer status: GET /api/cash-drawer/status
  Future<CashDrawerStatusModel> getDrawerStatus() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.cashDrawerStatus);
      final data = response.data['data'];
      return CashDrawerStatusModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Open cash drawer: POST /api/cash-drawer/open
  Future<bool> openCashDrawer(double openingAmount, {String? notes}) async {
    try {
      await _apiClient.post(
        ApiEndpoints.cashDrawerOpen,
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

  /// Close cash drawer: POST /api/cash-drawer/close
  Future<bool> closeCashDrawer(double closingAmount, {String? notes}) async {
    try {
      await _apiClient.post(
        ApiEndpoints.cashDrawerClose,
        data: {
          'closingAmount': closingAmount,
          if (notes != null) 'notes': notes,
        },
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Get today's settlement summary: GET /api/audit/daily-settlement
  Future<TodaySettlementModel> getDailySettlement() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.auditDailySettlement,
        queryParameters: {'date': DateTime.now().toIso8601String()},
      );
      final data = response.data['data'];
      if (data == null) return TodaySettlementModel();
      return TodaySettlementModel.fromJson(data);
    } catch (e) {
      // If no settlement exists yet, return empty
      return TodaySettlementModel();
    }
  }

  /// Get my transactions (cashier's activity): GET /api/audit/my-transactions
  Future<Map<String, dynamic>> getMyTransactions() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.auditMyTransactions);
      return {
        'summary': response.data['summary'] ?? {},
        'transactions': response.data['transactions'] ?? [],
      };
    } catch (e) {
      return {'summary': {}, 'transactions': []};
    }
  }
}
