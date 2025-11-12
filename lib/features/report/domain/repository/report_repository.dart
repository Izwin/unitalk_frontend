import 'package:dartz/dartz.dart';
import 'package:unitalk/core/failure/failure.dart';
import 'package:unitalk/features/report/data/model/report_model.dart';

abstract class ReportRepository {
  Future<Either<Failure, ReportModel>> createReport({
    required ReportTargetType targetType,
    required String targetId,
    required ReportCategory category,
    String? description,
  });

  Future<Either<Failure, List<ReportModel>>> getMyReports({
    int page = 1,
    int limit = 20,
    ReportStatus? status,
    ReportTargetType? targetType,
  });

  Future<Either<Failure, ReportModel>> getReport(String reportId);

  Future<Either<Failure, void>> deleteReport(String reportId);

  Future<Either<Failure, Map<String, dynamic>>> getReportStats();
}