import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/features/report/domain/repository/report_repository.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepository reportRepository;

  ReportBloc({required this.reportRepository}) : super(ReportState.initial()) {
    on<CreateReportEvent>(_onCreateReport);
    on<LoadMyReportsEvent>(_onLoadMyReports);
    on<LoadMoreReportsEvent>(_onLoadMoreReports);
    on<LoadReportEvent>(_onLoadReport);
    on<DeleteReportEvent>(_onDeleteReport);
    on<LoadReportStatsEvent>(_onLoadReportStats);
  }

  Future<void> _onCreateReport(
      CreateReportEvent event,
      Emitter<ReportState> emit,
      ) async {
    emit(state.copyWith(status: ReportBlocStatus.loading));

    final result = await reportRepository.createReport(
      targetType: event.targetType,
      targetId: event.targetId,
      category: event.category,
      description: event.description,
    );

    result.fold(
          (failure) => emit(state.copyWith(
        status: ReportBlocStatus.failure,
        errorMessage: failure.message,
      )),
          (report) {
        final updatedReports = [report, ...state.reports];
        emit(state.copyWith(
          status: ReportBlocStatus.success,
          reports: updatedReports,
          successMessage: 'Report submitted successfully',
        ));
      },
    );
  }

  Future<void> _onLoadMyReports(
      LoadMyReportsEvent event,
      Emitter<ReportState> emit,
      ) async {
    emit(state.copyWith(status: ReportBlocStatus.loading));

    final result = await reportRepository.getMyReports(
      page: event.page,
      status: event.status,
      targetType: event.targetType,
    );

    result.fold(
          (failure) => emit(state.copyWith(
        status: ReportBlocStatus.failure,
        errorMessage: failure.message,
      )),
          (reports) => emit(state.copyWith(
        status: ReportBlocStatus.success,
        reports: reports,
        currentPage: event.page,
        hasMore: reports.length >= 20,
      )),
    );
  }

  Future<void> _onLoadMoreReports(
      LoadMoreReportsEvent event,
      Emitter<ReportState> emit,
      ) async {
    if (!state.hasMore || state.isLoadingMore) return;

    emit(state.copyWith(isLoadingMore: true));

    final nextPage = state.currentPage + 1;
    final result = await reportRepository.getMyReports(page: nextPage);

    result.fold(
          (failure) => emit(state.copyWith(
        isLoadingMore: false,
        errorMessage: failure.message,
      )),
          (reports) {
        final updatedReports = [...state.reports, ...reports];
        emit(state.copyWith(
          status: ReportBlocStatus.success,
          reports: updatedReports,
          currentPage: nextPage,
          hasMore: reports.length >= 20,
          isLoadingMore: false,
        ));
      },
    );
  }

  Future<void> _onLoadReport(
      LoadReportEvent event,
      Emitter<ReportState> emit,
      ) async {
    emit(state.copyWith(status: ReportBlocStatus.loading));

    final result = await reportRepository.getReport(event.reportId);

    result.fold(
          (failure) => emit(state.copyWith(
        status: ReportBlocStatus.failure,
        errorMessage: failure.message,
      )),
          (report) => emit(state.copyWith(
        status: ReportBlocStatus.success,
        selectedReport: report,
      )),
    );
  }

  Future<void> _onDeleteReport(
      DeleteReportEvent event,
      Emitter<ReportState> emit,
      ) async {
    emit(state.copyWith(status: ReportBlocStatus.loading));

    final result = await reportRepository.deleteReport(event.reportId);

    result.fold(
          (failure) => emit(state.copyWith(
        status: ReportBlocStatus.failure,
        errorMessage: failure.message,
      )),
          (_) {
        final updatedReports = state.reports
            .where((report) => report.id != event.reportId)
            .toList();
        emit(state.copyWith(
          status: ReportBlocStatus.success,
          reports: updatedReports,
          successMessage: 'Report deleted successfully',
        ));
      },
    );
  }

  Future<void> _onLoadReportStats(
      LoadReportStatsEvent event,
      Emitter<ReportState> emit,
      ) async {
    final result = await reportRepository.getReportStats();

    result.fold(
          (failure) => emit(state.copyWith(
        status: ReportBlocStatus.failure,
        errorMessage: failure.message,
      )),
          (stats) => emit(state.copyWith(
        status: ReportBlocStatus.success,
        stats: stats,
      )),
    );
  }
}