import 'package:dartz/dartz.dart';
import 'package:unitalk/core/failure/failure.dart';
import 'package:unitalk/features/report/data/datasource/report_remote_datasource.dart';
import 'package:unitalk/features/report/data/model/report_model.dart';
import 'package:unitalk/features/report/domain/repository/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;

  ReportRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, ReportModel>> createReport({
    required ReportTargetType targetType,
    required String targetId,
    required ReportCategory category,
    String? description,
  }) async {
    try {
      final report = await remoteDataSource.createReport(
        targetType: targetType,
        targetId: targetId,
        category: category,
        description: description,
      );
      return Right(report);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReportModel>>> getMyReports({
    int page = 1,
    int limit = 20,
    ReportStatus? status,
    ReportTargetType? targetType,
  }) async {
    try {
      final result = await remoteDataSource.getMyReports(
        page: page,
        limit: limit,
        status: status,
        targetType: targetType,
      );
      return Right(result['reports'] as List<ReportModel>);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReportModel>> getReport(String reportId) async {
    try {
      final report = await remoteDataSource.getReport(reportId);
      return Right(report);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReport(String reportId) async {
    try {
      await remoteDataSource.deleteReport(reportId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getReportStats() async {
    try {
      final stats = await remoteDataSource.getReportStats();
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}