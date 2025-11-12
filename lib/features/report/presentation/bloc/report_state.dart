import 'package:unitalk/features/report/data/model/report_model.dart';

enum ReportBlocStatus { initial, loading, success, failure }

class ReportState {
  final ReportBlocStatus status;
  final List<ReportModel> reports;
  final ReportModel? selectedReport;
  final Map<String, dynamic>? stats;
  final String? errorMessage;
  final String? successMessage;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  ReportState({
    required this.status,
    this.reports = const [],
    this.selectedReport,
    this.stats,
    this.errorMessage,
    this.successMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  factory ReportState.initial() => ReportState(
    status: ReportBlocStatus.initial,
    reports: [],
    currentPage: 1,
    hasMore: true,
  );

  ReportState copyWith({
    ReportBlocStatus? status,
    List<ReportModel>? reports,
    ReportModel? selectedReport,
    Map<String, dynamic>? stats,
    String? errorMessage,
    String? successMessage,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ReportState(
      status: status ?? this.status,
      reports: reports ?? this.reports,
      selectedReport: selectedReport ?? this.selectedReport,
      stats: stats ?? this.stats,
      errorMessage: errorMessage,
      successMessage: successMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
