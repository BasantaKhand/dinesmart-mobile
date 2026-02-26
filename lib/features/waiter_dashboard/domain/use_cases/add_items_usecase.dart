import 'package:dartz/dartz.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:dinesmart_app/core/usecase/app_usecases.dart';
import '../entities/order_entity.dart';
import '../repository/waiter_dashboard_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final addItemsUseCaseProvider = Provider((ref) {
  return AddItemsUseCase(ref.read(waiterDashboardRepositoryProvider));
});

class AddItemsUseCase implements UsecaseWithParms<bool, OrderEntity> {
  final IWaiterDashboardRepository repository;

  AddItemsUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(OrderEntity order) {
    return repository.addItemsToOrder(order);
  }
}
