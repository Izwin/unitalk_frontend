import 'package:flutter/material.dart';
import 'package:unitalk/core/ui/common/report_dialog.dart';
import 'package:unitalk/features/report/data/model/report_model.dart';
import 'package:unitalk/l10n/app_localizations.dart';

/// Вспомогательный класс для отображения меню модерации контента
class ContentModerationMenu {
  /// Показать меню модерации для поста
  static void showPostMenu({
    required BuildContext context,
    required String postId,
    required bool isOwner,
    VoidCallback? onDelete,
    VoidCallback? onEdit,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Owner actions
              if (isOwner && onEdit != null)
                _buildMenuItem(
                  context: context,
                  icon: Icons.edit_outlined,
                  title: l10n.edit,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onEdit();
                  },
                ),
              if (isOwner && onDelete != null)
                _buildMenuItem(
                  context: context,
                  icon: Icons.delete_outline,
                  title: l10n.delete,
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onDelete();
                  },
                ),

              // Report action (for non-owners)
              if (!isOwner)
                _buildMenuItem(
                  context: context,
                  icon: Icons.flag_outlined,
                  title: l10n.reportPost,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    ReportDialog.show(
                      context,
                      targetType: ReportTargetType.post,
                      targetId: postId,
                    );
                  },
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Показать меню модерации для комментария
  static void showCommentMenu({
    required BuildContext context,
    required String commentId,
    required bool isOwner,
    VoidCallback? onDelete,
    VoidCallback? onEdit,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Owner actions
              if (isOwner && onEdit != null)
                _buildMenuItem(
                  context: context,
                  icon: Icons.edit_outlined,
                  title: l10n.edit,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onEdit();
                  },
                ),
              if (isOwner && onDelete != null)
                _buildMenuItem(
                  context: context,
                  icon: Icons.delete_outline,
                  title: l10n.delete,
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onDelete();
                  },
                ),

              // Report action (for non-owners)
              if (!isOwner)
                _buildMenuItem(
                  context: context,
                  icon: Icons.flag_outlined,
                  title: l10n.reportComment,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    ReportDialog.show(
                      context,
                      targetType: ReportTargetType.comment,
                      targetId: commentId,
                    );
                  },
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Показать меню модерации для сообщения
  static void showMessageMenu({
    required BuildContext context,
    required String messageId,
    required bool isOwner,
    VoidCallback? onReply,
    VoidCallback? onDelete,
    VoidCallback? onEdit,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Reply action (available for everyone)
              if (onReply != null)
                _buildMenuItem(
                  context: context,
                  icon: Icons.reply_rounded,
                  title: l10n.reply,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onReply();
                  },
                ),

              // Owner actions
              if (isOwner && onEdit != null)
                _buildMenuItem(
                  context: context,
                  icon: Icons.edit_outlined,
                  title: l10n.edit,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onEdit();
                  },
                ),
              if (isOwner && onDelete != null)
                _buildMenuItem(
                  context: context,
                  icon: Icons.delete_outline,
                  title: l10n.delete,
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onDelete();
                  },
                ),

              // Report action (for non-owners)
              if (!isOwner)
                _buildMenuItem(
                  context: context,
                  icon: Icons.flag_outlined,
                  title: l10n.reportMessage,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    ReportDialog.show(
                      context,
                      targetType: ReportTargetType.message,
                      targetId: messageId,
                    );
                  },
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final itemColor = color ?? (isDark ? Colors.white70 : Colors.black87);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (color ?? Theme.of(context).primaryColor).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: itemColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: itemColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}