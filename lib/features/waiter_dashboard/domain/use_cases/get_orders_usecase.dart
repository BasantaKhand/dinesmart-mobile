import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failure.dart';
import '../entities/order_entity.dart';
import '../repository/waiter_dashboard_repository.dart';

final getOrdersUseCaseProvider = Provider((ref) {
  return GetOrdersUseCase(ref.read(waiterDashboardRepositoryProvider));
});

class GetOrdersUseCase {
  final IWaiterDashboardRepository repository;

  GetOrdersUseCase(this.repository);

  Future<Either<Failure, List<OrderEntity>>> call() {
    return repository.getOrders();
  }
}
