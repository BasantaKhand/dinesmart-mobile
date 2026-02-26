import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/staff_entity.dart';

abstract class IStaffRepository {
  Future<Either<Failure, List<StaffEntity>>> getStaff();
  Future<Either<Failure, StaffEntity>> createStaff(StaffEntity staff);
  Future<Either<Failure, StaffEntity>> updateStaff(StaffEntity staff);
  Future<Either<Failure, bool>> deleteStaff(String id);
  Future<Either<Failure, StaffEntity>> toggleStaffStatus(String id);
}
