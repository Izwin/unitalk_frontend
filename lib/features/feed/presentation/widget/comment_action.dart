import 'package:flutter/material.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class CommentActions extends StatelessWidget {
  final bool showReplyInput;
  final bool showReplies;
  final int repliesCount;
  final VoidCallback onReplyTap;
  final VoidCallback onRepliesTap;

  const CommentActions({
    super.key,
    required this.showReplyInput,
    required this.showReplies,
    required this.repliesCount,
    required this.onReplyTap,
    required this.onRepliesTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        ActionButton(
          icon: Icons.reply_rounded,
          label: l10n.reply,
          isActive: showReplyInput,
          onTap: onReplyTap,
        ),
        if (repliesCount > 0) ...[
          const SizedBox(width: 12),
          RepliesButton(
            showReplies: showReplies,
            repliesCount: repliesCount,
            onTap: onRepliesTap,
          ),
        ],
      ],
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? colors.primaryContainer.withOpacity(0.5)
              : colors.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? colors.primary : colors.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isActive ? colors.primary : colors.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RepliesButton extends StatelessWidget {
  final bool showReplies;
  final int repliesCount;
  final VoidCallback onTap;

  const RepliesButton({
    super.key,
    required this.showReplies,
    required this.repliesCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: showReplies
              ? colors.secondaryContainer.withOpacity(0.5)
              : colors.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              showReplies ? Icons.expand_less : Icons.expand_more,
              size: 18,
              color: colors.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 6),
            Text(
              l10n.repliesCount(repliesCount),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}