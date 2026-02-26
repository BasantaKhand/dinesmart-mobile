import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failure.dart';
import '../entities/order_entity.dart';
import '../repository/waiter_dashboard_repository.dart';

final updateOrderStatusUseCaseProvider = Provider((ref) {
  return UpdateOrderStatusUseCase(ref.read(waiterDashboardRepositoryProvider));
});

class UpdateOrderStatusUseCase {
  final IWaiterDashboardRepository _repository;

  UpdateOrderStatusUseCase(this._repository);

  Future<Either<Failure, bool>> call(String orderId, OrderStatus status) {
    return _repository.updateOrderStatus(orderId, status);
  }
}
