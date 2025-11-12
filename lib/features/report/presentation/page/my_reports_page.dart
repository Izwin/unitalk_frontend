import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:unitalk/features/report/data/model/report_model.dart';
import 'package:unitalk/features/report/presentation/bloc/report_bloc.dart';
import 'package:unitalk/features/report/presentation/bloc/report_event.dart';
import 'package:unitalk/features/report/presentation/bloc/report_state.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class MyReportsPage extends StatefulWidget {
  const MyReportsPage({Key? key}) : super(key: key);

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  final ScrollController _scrollController = ScrollController();
  ReportStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<ReportBloc>().add(LoadMyReportsEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<ReportBloc>().add(LoadMoreReportsEvent());
    }
  }

  Future<void> _onRefresh() async {
    context.read<ReportBloc>().add(LoadMyReportsEvent(status: _filterStatus));
    await context.read<ReportBloc>().stream.first;
  }

  void _showFilterDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(l10n.filterByStatus),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption(null, l10n.all, dialogContext),
            _buildFilterOption(ReportStatus.pending, l10n.pending, dialogContext),
            _buildFilterOption(ReportStatus.underReview, l10n.underReview, dialogContext),
            _buildFilterOption(ReportStatus.resolved, l10n.resolved, dialogContext),
            _buildFilterOption(ReportStatus.rejected, l10n.rejected, dialogContext),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(ReportStatus? status, String label, BuildContext dialogContext) {
    final isSelected = _filterStatus == status;

    return RadioListTile<ReportStatus?>(
      value: status,
      groupValue: _filterStatus,
      title: Text(label),
      selected: isSelected,
      onChanged: (value) {
        setState(() => _filterStatus = value);
        context.read<ReportBloc>().add(LoadMyReportsEvent(status: value));
        Navigator.pop(dialogContext);
      },
    );
  }

  Widget _buildStatusChip(ReportStatus status) {
    Color color;
    IconData icon;

    switch (status) {
      case ReportStatus.pending:
        color = Colors.orange;
        icon = Icons.access_time;
        break;
      case ReportStatus.underReview:
        color = Colors.blue;
        icon = Icons.rate_review_outlined;
        break;
      case ReportStatus.resolved:
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case ReportStatus.rejected:
        color = Colors.red;
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(ReportModel report) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String targetTypeLabel;
    IconData targetIcon;

    switch (report.targetType) {
      case ReportTargetType.user:
        targetTypeLabel = l10n.user;
        targetIcon = Icons.person_outlined;
        break;
      case ReportTargetType.post:
        targetTypeLabel = l10n.post;
        targetIcon = Icons.article_outlined;
        break;
      case ReportTargetType.comment:
        targetTypeLabel = l10n.comment;
        targetIcon = Icons.comment_outlined;
        break;
      case ReportTargetType.message:
        targetTypeLabel = l10n.message;
        targetIcon = Icons.message_outlined;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  targetIcon,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$targetTypeLabel • ${report.category.displayName}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy • HH:mm').format(report.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(report.status),
            ],
          ),
          if (report.description != null && report.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.03)
                    : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                report.description!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          if (report.status == ReportStatus.pending) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(l10n.cancelReport),
                    content: Text(l10n.cancelReportConfirmation),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(l10n.no),
                      ),
                      FilledButton(
                        onPressed: () {
                          context.read<ReportBloc>().add(DeleteReportEvent(report.id));
                          Navigator.pop(dialogContext);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text(l10n.yes),
                      ),
                    ],
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(l10n.cancelReport),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          l10n.myReports,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: l10n.filter,
          ),
        ],
      ),
      body: BlocConsumer<ReportBloc, ReportState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state.status == ReportBlocStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == ReportBlocStatus.loading && state.reports.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2.5),
            );
          }

          if (state.reports.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.report_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noReports,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: Theme.of(context).colorScheme.primary,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: state.reports.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.reports.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  );
                }

                return _buildReportItem(state.reports[index]);
              },
            ),
          );
        },
      ),
    );
  }
}