import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/core/ui/common/report_dialog.dart';
import 'package:unitalk/features/block/data/model/block_model.dart';
import 'package:unitalk/features/block/presentation/bloc/block_bloc.dart';
import 'package:unitalk/features/block/presentation/bloc/block_event.dart';
import 'package:unitalk/features/report/data/model/report_model.dart';
import 'package:unitalk/l10n/app_localizations.dart';

/// Widget для отображения действий модерации (блокировка и жалоба)
class UserModerationActions extends StatelessWidget {
  final String userId;
  final BlockStatusModel? blockStatus;
  final String userName;

  const UserModerationActions({
    Key? key,
    required this.userId,
    this.blockStatus,
    required this.userName,
  }) : super(key: key);

  void _showBlockDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.block,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      l10n.blockUser,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                l10n.blockUserConfirmation(userName),
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      context.read<BlockBloc>().add(BlockUserEvent(userId));
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.userBlocked),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      l10n.block,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUnblockDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.unblockUser,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.unblockUserConfirmation(userName),
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      context.read<BlockBloc>().add(UnblockUserEvent(userId));
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.userUnblocked),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      l10n.unblock,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Если пользователь заблокирован текущим пользователем
    if (blockStatus?.isBlocked == true) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.block,
              color: Colors.red.shade400,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.youBlockedThisUser,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.red.shade400,
                ),
              ),
            ),
            TextButton(
              onPressed: () => _showUnblockDialog(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.unblock,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade400,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Если текущий пользователь заблокирован этим пользователем
    if (blockStatus?.isBlockedBy == true) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade400,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.thisUserBlockedYou,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.orange.shade400,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Обычные действия
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showBlockDialog(context),
            icon: const Icon(Icons.block, size: 18),
            label: Text(l10n.block),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(
                color: Colors.red.withOpacity(0.3),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ReportDialog.show(
                context,
                targetType: ReportTargetType.user,
                targetId: userId,
              );
            },
            icon: const Icon(Icons.flag_outlined, size: 18),
            label: Text(l10n.report),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? Colors.white70 : Colors.black87,
              side: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.15)
                    : Colors.black.withOpacity(0.15),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }
}