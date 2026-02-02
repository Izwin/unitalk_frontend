// lib/features/friendship/presentation/widgets/friends_stat_button.dart

import 'package:flutter/material.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class FriendsStatButton extends StatelessWidget {
  final int friendsCount;
  final int pendingRequestsCount;
  final VoidCallback onTap;

  const FriendsStatButton({
    Key? key,
    required this.friendsCount,
    this.pendingRequestsCount = 0,
    required this.onTap,
  }) : super(key: key);

  bool get _hasPendingRequests => pendingRequestsCount > 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _hasPendingRequests
                ? cs.error.withOpacity(0.08)
                : cs.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: _hasPendingRequests
                ? Border.all(color: cs.error.withOpacity(0.2), width: 1)
                : null,
          ),
          child: Row(
            children: [
              // Icon with badge
              _IconWithBadge(
                count: pendingRequestsCount,
                hasRequests: _hasPendingRequests,
                theme: theme,
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Friends count
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: _formatCount(friendsCount),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          TextSpan(
                            text: ' ${l10n.friends.toLowerCase()}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Pending requests hint
                    if (_hasPendingRequests) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.newFriendRequests(pendingRequestsCount),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: cs.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: cs.onSurfaceVariant.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }
}

class _IconWithBadge extends StatelessWidget {
  final int count;
  final bool hasRequests;
  final ThemeData theme;

  const _IconWithBadge({
    required this.count,
    required this.hasRequests,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: hasRequests
                ? theme.colorScheme.error.withOpacity(0.12)
                : theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.people_rounded,
            size: 22,
            color: hasRequests
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
          ),
        ),
        if (hasRequests)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              constraints: const BoxConstraints(minWidth: 20),
              height: 20,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}