import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:dinesmart_app/core/services/connectivity/network_info.dart';
import 'package:dinesmart_app/features/cashier_dashboard/domain/entities/cashier_entities.dart';
import 'package:dinesmart_app/features/cashier_dashboard/domain/repository/cashier_dashboard_repository.dart';
import 'package:dinesmart_app/features/cashier_dashboard/data/data_sources/cashier_remote_data_source.dart';
import 'package:dinesmart_app/features/cashier_dashboard/data/data_sources/cashier_local_data_source.dart';

final cashierDashboardRepositoryImplProvider = Provider<ICashierDashboardRepository>((ref) {
  return CashierDashboardRepositoryImpl(
    remoteDataSource: ref.read(cashierRemoteDataSourceProvider),
    localDataSource: ref.read(cashierLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class CashierDashboardRepositoryImpl implements ICashierDashboardRepository {
  final CashierRemoteDataSource remoteDataSource;
  final CashierLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  CashierDashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<PaymentQueueItem>>> getPaymentQueue() async {
    if (await networkInfo.isConnected) {
      try {
        final models = await remoteDataSource.getPaymentQueue();
        await localDataSource.savePaymentQueue(models);
        return Right(models.map((m) => m.toEntity()).toList());
      } on DioException catch (e) {
        return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Failed to fetch payment queue',
          statusCode: e.response?.statusCode,
        ));
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    } else {
      final cached = localDataSource.getPaymentQueue();
      return Right(cached);
    }
  }

  @override
  Future<Either<Failure, List<Settlement>>> getRecentSettlements() async {
    if (await networkInfo.isConnected) {
      try {
        final models = await remoteDataSource.getRecentSettlements();
        await localDataSource.saveRecentSettlements(models);
        return Right(models.map((m) => m.toEntity()).toList());
      } on DioException catch (e) {
        return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Failed to fetch settlements',
          statusCode: e.response?.statusCode,
        ));
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    } else {
      final cached = localDataSource.getRecentSettlements();
      return Right(cached);
    }
  }

  @override
  Future<Either<Failure, TodaySettlement>> getTodaySettlement() async {
    if (await networkInfo.isConnected) {
      try {
        final model = await remoteDataSource.getDailySettlement();
        await localDataSource.saveTodaySettlement(model);
        return Right(model.toEntity());
      } on DioException catch (e) {
        return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Failed to fetch today settlement',
          statusCode: e.response?.statusCode,
        ));
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    } else {
      final cached = localDataSource.getTodaySettlement();
      if (cached != null) return Right(cached);
      return const Left(Failure('No cached settlement data'));
    }
  }

  @override
  Future<Either<Failure, CashDrawerStatus>> getDrawerStatus() async {
    if (await networkInfo.isConnected) {
      try {
        final model = await remoteDataSource.getDrawerStatus();
        await localDataSource.saveDrawerStatus(model);
        return Right(model.toEntity());
      } on DioException catch (e) {
        return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Failed to fetch drawer status',
          statusCode: e.response?.statusCode,
        ));
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    } else {
      final cached = localDataSource.getDrawerStatus();
      if (cached != null) return Right(cached);
      return const Left(Failure('No cached drawer status'));
    }
  }

  @override
  Future<Either<Failure, bool>> settlePayment(
    String orderId,
    String paymentMethod, {
    String? transactionId,
    String? notes,
  }) async {
    try {
      final result = await remoteDataSource.settlePayment(
        orderId,
        paymentMethod,
        transactionId: transactionId,
        notes: notes,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(ApiFailure(
        message: e.response?.data['message'] ?? e.message ?? 'Failed to settle payment',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> openCashDrawer(double openingAmount, {String? notes}) async {
    try {
      final result = await remoteDataSource.openCashDrawer(openingAmount, notes: notes);
      return Right(result);
    } on DioException catch (e) {
      return Left(ApiFailure(
        message: e.response?.data['message'] ?? e.message ?? 'Failed to open cash drawer',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> closeCashDrawer(double closingAmount, {String? notes}) async {
    try {
      final result = await remoteDataSource.closeCashDrawer(closingAmount, notes: notes);
      return Right(result);
    } on DioException catch (e) {
      return Left(ApiFailure(
        message: e.response?.data['message'] ?? e.message ?? 'Failed to close cash drawer',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
