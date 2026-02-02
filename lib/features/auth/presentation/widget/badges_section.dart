// lib/features/auth/presentation/widget/badges_section.dart

import 'package:flutter/material.dart';
import 'package:unitalk/features/auth/data/model/badge_helper.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/features/auth/presentation/widget/badges_overview_sheet.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class BadgesSection extends StatelessWidget {
  final UserModel user;

  const BadgesSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final badges = user.badges ?? [];
    final earnedCount = user.earnedBadgesCount;
    const totalBadges = 5;
    final nextBadgeProgress = _getNextBadgeProgress(user);

    return GestureDetector(
      onTap: () => BadgesOverviewSheet.show(context, user: user),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _BadgesPreview(badges: badges),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            l10n.badges,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _CountChip(
                            earned: earnedCount,
                            total: totalBadges,
                            theme: theme,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getSubtitle(l10n, earnedCount, totalBadges),
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: theme.hintColor,
                ),
              ],
            ),

            if (nextBadgeProgress != null && earnedCount < totalBadges) ...[
              const SizedBox(height: 14),
              _NextBadgeProgress(
                badgeId: nextBadgeProgress.badgeId,
                progress: nextBadgeProgress.progress,
                current: nextBadgeProgress.current,
                target: nextBadgeProgress.target,
                theme: theme,
                l10n: l10n,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getSubtitle(AppLocalizations l10n, int earned, int total) {
    if (earned == 0) return l10n.noBadgesYet;
    if (earned == total) return l10n.allBadgesEarned;
    return l10n.earnBadgesHint;
  }

  _BadgeProgressInfo? _getNextBadgeProgress(UserModel user) {
    if (user.badgeProgress == null || user.badgeProgress!.isEmpty) return null;

    String? closestBadgeId;
    double highestProgress = 0;
    int current = 0;
    int target = 0;

    for (final entry in user.badgeProgress!.entries) {
      if (!entry.value.achieved && entry.value.progress > highestProgress) {
        highestProgress = entry.value.progress;
        closestBadgeId = entry.key;
        current = entry.value.current;
        target = entry.value.target;
      }
    }

    if (closestBadgeId == null || highestProgress == 0) return null;

    return _BadgeProgressInfo(
      badgeId: closestBadgeId,
      progress: highestProgress,
      current: current,
      target: target,
    );
  }
}

class _BadgeProgressInfo {
  final String badgeId;
  final double progress;
  final int current;
  final int target;

  _BadgeProgressInfo({
    required this.badgeId,
    required this.progress,
    required this.current,
    required this.target,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// BADGES PREVIEW
// ═══════════════════════════════════════════════════════════════════════════

class _BadgesPreview extends StatelessWidget {
  final List<BadgeModel> badges;

  const _BadgesPreview({required this.badges});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (badges.isEmpty) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          Icons.emoji_events_outlined,
          size: 24,
          color: theme.hintColor,
        ),
      );
    }

    final displayBadges = badges.take(3).toList();
    final extraCount = badges.length - 3;

    return SizedBox(
      width: 76,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = displayBadges.length - 1; i >= 0; i--)
            Positioned(
              left: i * 18.0,
              child: _BadgeCircle(badge: displayBadges[i]),
            ),
          if (extraCount > 0)
            Positioned(
              right: -4,
              bottom: -4,
              child: _ExtraCountBadge(count: extraCount, theme: theme),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BADGE CIRCLE
// ═══════════════════════════════════════════════════════════════════════════

class _BadgeCircle extends StatelessWidget {
  final BadgeModel badge;

  const _BadgeCircle({required this.badge});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = BadgeHelper.getIcon(badge.id);
    final tierColor = _getTierColor(badge.tier);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: tierColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.scaffoldBackgroundColor,
          width: 3,
        ),
      ),
      child: Center(
        child: Text(icon, style: const TextStyle(fontSize: 22)),
      ),
    );
  }

  Color _getTierColor(String? tier) {
    switch (tier) {
      case 'gold':
        return const Color(0xFFFFF3CD);
      case 'silver':
        return const Color(0xFFE8E9EB);
      case 'bronze':
        return const Color(0xFFF5E6D3);
      default:
        return const Color(0xFFE3F2FD);
    }
  }
}

class _ExtraCountBadge extends StatelessWidget {
  final int count;
  final ThemeData theme;

  const _ExtraCountBadge({required this.count, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.scaffoldBackgroundColor,
          width: 2,
        ),
      ),
      child: Text(
        '+$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// COUNT CHIP
// ═══════════════════════════════════════════════════════════════════════════

class _CountChip extends StatelessWidget {
  final int earned;
  final int total;
  final ThemeData theme;

  const _CountChip({
    required this.earned,
    required this.total,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = earned == total;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isComplete
            ? const Color(0xFFFFB800)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$earned/$total',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isComplete ? Colors.white : theme.hintColor,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NEXT BADGE PROGRESS
// ═══════════════════════════════════════════════════════════════════════════

class _NextBadgeProgress extends StatelessWidget {
  final String badgeId;
  final double progress;
  final int current;
  final int target;
  final ThemeData theme;
  final AppLocalizations l10n;

  const _NextBadgeProgress({
    required this.badgeId,
    required this.progress,
    required this.current,
    required this.target,
    required this.theme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final icon = BadgeHelper.getIcon(badgeId);
    final name = BadgeHelper.getName(badgeId, l10n);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${l10n.nextBadge}: $name',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    Text(
                      '$current/$target',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: theme.dividerColor,
                    valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}