
import 'package:unitalk/features/report/data/model/report_model.dart';

abstract class ReportEvent {}

class CreateReportEvent extends ReportEvent {
  final ReportTargetType targetType;
  final String targetId;
  final ReportCategory category;
  final String? description;

  CreateReportEvent({
    required this.targetType,
    required this.targetId,
    required this.category,
    this.description,
  });
}

class LoadMyReportsEvent extends ReportEvent {
  final int page;
  final ReportStatus? status;
  final ReportTargetType? targetType;

  LoadMyReportsEvent({
    this.page = 1,
    this.status,
    this.targetType,
  });
}

class LoadMoreReportsEvent extends ReportEvent {}

class LoadReportEvent extends ReportEvent {
  final String reportId;

  LoadReportEvent(this.reportId);
}

class DeleteReportEvent extends ReportEvent {
  final String reportId;

  DeleteReportEvent(this.reportId);
}

class LoadReportStatsEvent extends ReportEvent {}