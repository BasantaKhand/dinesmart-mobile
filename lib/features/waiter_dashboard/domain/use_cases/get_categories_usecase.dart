import 'package:dartz/dartz.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:dinesmart_app/core/usecase/app_usecases.dart';
import '../entities/category_entity.dart';
import '../repository/waiter_dashboard_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getCategoriesUseCaseProvider = Provider((ref) {
  return GetCategoriesUseCase(ref.read(waiterDashboardRepositoryProvider));
});

class GetCategoriesUseCase implements UsecaseWithoutParms<List<CategoryEntity>> {
  final IWaiterDashboardRepository repository;

  GetCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<CategoryEntity>>> call() {
    return repository.getCategories();
  }
}
