import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/features/report/data/model/report_model.dart';
import 'package:unitalk/features/report/presentation/bloc/report_bloc.dart';
import 'package:unitalk/features/report/presentation/bloc/report_event.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class ReportDialog {
  static void show(
      BuildContext context, {
        required ReportTargetType targetType,
        required String targetId,
      }) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      isDismissible: true,
      enableDrag: true,
      builder: (sheetContext) => _ReportDialogContent(
        targetType: targetType,
        targetId: targetId,
        l10n: l10n,
        parentContext: context,
      ),
    );
  }
}

class _ReportDialogContent extends StatefulWidget {
  final ReportTargetType targetType;
  final String targetId;
  final AppLocalizations l10n;
  final BuildContext parentContext;

  const _ReportDialogContent({
    required this.targetType,
    required this.targetId,
    required this.l10n,
    required this.parentContext,
  });

  @override
  State<_ReportDialogContent> createState() => _ReportDialogContentState();
}

class _ReportDialogContentState extends State<_ReportDialogContent> {
  ReportCategory? _selectedCategory;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitReport() {
    if (_isSubmitting) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.l10n.selectReportCategory),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    context.read<ReportBloc>().add(CreateReportEvent(
      targetType: widget.targetType,
      targetId: widget.targetId,
      category: _selectedCategory!,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    ));

    Navigator.of(context).pop();

    ScaffoldMessenger.of(widget.parentContext).showSnackBar(
      SnackBar(
        content: Text(widget.l10n.reportSubmitted),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildCategoryTile(ReportCategory category, IconData icon) {
    final isSelected = _selectedCategory == category;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => setState(() => _selectedCategory = category),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                    : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : (isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.6)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                _getCategoryDisplayName(category),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  String _getCategoryDisplayName(ReportCategory category) {
    switch (category) {
      case ReportCategory.spam:
        return widget.l10n.spam;
      case ReportCategory.harassment:
        return widget.l10n.harassment;
      case ReportCategory.hateSpeech:
        return widget.l10n.hateSpeech;
      case ReportCategory.violence:
        return widget.l10n.violence;
      case ReportCategory.nudity:
        return widget.l10n.nudity;
      case ReportCategory.falseInformation:
        return widget.l10n.falseInformation;
      case ReportCategory.impersonation:
        return widget.l10n.impersonation;
      case ReportCategory.other:
        return widget.l10n.other;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.5,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header с кнопкой закрытия
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
            child: Row(
              children: [
                // Handle
                Expanded(
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                // Close button
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.6),
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.04),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.l10n.reportTitle,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.l10n.selectReportReason,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Categories
                  _buildCategoryTile(ReportCategory.spam, Icons.message_rounded),
                  const SizedBox(height: 10),
                  _buildCategoryTile(ReportCategory.harassment, Icons.person_off_outlined),
                  const SizedBox(height: 10),
                  _buildCategoryTile(ReportCategory.hateSpeech, Icons.report_outlined),
                  const SizedBox(height: 10),
                  _buildCategoryTile(ReportCategory.violence, Icons.dangerous_outlined),
                  const SizedBox(height: 10),
                  _buildCategoryTile(ReportCategory.nudity, Icons.image_not_supported_outlined),
                  const SizedBox(height: 10),
                  _buildCategoryTile(ReportCategory.falseInformation, Icons.error_outline),
                  const SizedBox(height: 10),
                  _buildCategoryTile(ReportCategory.impersonation, Icons.person_search_outlined),
                  const SizedBox(height: 10),
                  _buildCategoryTile(ReportCategory.other, Icons.more_horiz),
                  const SizedBox(height: 24),

                  // Description (optional)
                  Text(
                    widget.l10n.additionalDetails,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    maxLength: 1000,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.4,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.l10n.describeIssue,
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withOpacity(0.04)
                          : Colors.black.withOpacity(0.02),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit button
                  FilledButton(
                    onPressed: _isSubmitting ? null : _submitReport,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text(
                      widget.l10n.submitReport,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}