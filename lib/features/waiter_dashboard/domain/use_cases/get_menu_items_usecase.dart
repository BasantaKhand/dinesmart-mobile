import 'package:dartz/dartz.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:dinesmart_app/core/usecase/app_usecases.dart';
import '../entities/menu_item_entity.dart';
import '../repository/waiter_dashboard_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getMenuItemsUseCaseProvider = Provider((ref) {
  return GetMenuItemsUseCase(ref.read(waiterDashboardRepositoryProvider));
});

class GetMenuItemsUseCase implements UsecaseWithoutParms<List<MenuItemEntity>> {
  final IWaiterDashboardRepository repository;

  GetMenuItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<MenuItemEntity>>> call() {
    return repository.getMenuItems();
  }
}
