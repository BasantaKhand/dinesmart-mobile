import 'package:dartz/dartz.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:dinesmart_app/core/usecase/app_usecases.dart';
import '../entities/table_entity.dart';
import '../repository/waiter_dashboard_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getTablesUseCaseProvider = Provider((ref) {
  return GetTablesUseCase(ref.read(waiterDashboardRepositoryProvider));
});

class GetTablesUseCase implements UsecaseWithoutParms<List<TableEntity>> {
  final IWaiterDashboardRepository repository;

  GetTablesUseCase(this.repository);

  @override
  Future<Either<Failure, List<TableEntity>>> call() {
    return repository.getTables();
  }
}
