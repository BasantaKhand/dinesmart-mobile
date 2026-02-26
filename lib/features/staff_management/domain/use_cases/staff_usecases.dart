import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/staff_entity.dart';
import '../repository/staff_repository.dart';

class GetStaffUseCase {
  final IStaffRepository repository;
  GetStaffUseCase(this.repository);
  Future<Either<Failure, List<StaffEntity>>> call() => repository.getStaff();
}

class CreateStaffUseCase {
  final IStaffRepository repository;
  CreateStaffUseCase(this.repository);
  Future<Either<Failure, StaffEntity>> call(StaffEntity staff) => repository.createStaff(staff);
}

class UpdateStaffUseCase {
  final IStaffRepository repository;
  UpdateStaffUseCase(this.repository);
  Future<Either<Failure, StaffEntity>> call(StaffEntity staff) => repository.updateStaff(staff);
}

class DeleteStaffUseCase {
  final IStaffRepository repository;
  DeleteStaffUseCase(this.repository);
  Future<Either<Failure, bool>> call(String id) => repository.deleteStaff(id);
}

class ToggleStaffStatusUseCase {
  final IStaffRepository repository;
  ToggleStaffStatusUseCase(this.repository);
  Future<Either<Failure, StaffEntity>> call(String id) => repository.toggleStaffStatus(id);
}
