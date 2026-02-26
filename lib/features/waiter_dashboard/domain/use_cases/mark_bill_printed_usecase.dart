import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failure.dart';
import '../repository/waiter_dashboard_repository.dart';

final markBillPrintedUseCaseProvider = Provider((ref) {
  return MarkBillPrintedUseCase(ref.read(waiterDashboardRepositoryProvider));
});

class MarkBillPrintedUseCase {
  final IWaiterDashboardRepository _repository;

  MarkBillPrintedUseCase(this._repository);

  Future<Either<Failure, bool>> call(String orderId) {
    return _repository.markBillPrinted(orderId);
  }
}
