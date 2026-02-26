import 'package:dartz/dartz.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:dinesmart_app/core/usecase/app_usecases.dart';
import '../entities/order_entity.dart';
import '../repository/waiter_dashboard_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getActiveOrderUseCaseProvider = Provider((ref) {
  return GetActiveOrderUseCase(ref.read(waiterDashboardRepositoryProvider));
});

class GetActiveOrderUseCase implements UsecaseWithParms<OrderEntity?, String> {
  final IWaiterDashboardRepository repository;

  GetActiveOrderUseCase(this.repository);

  @override
  Future<Either<Failure, OrderEntity?>> call(String tableId) {
    return repository.getActiveOrderByTable(tableId);
  }
}
