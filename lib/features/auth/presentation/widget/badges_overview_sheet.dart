// lib/features/auth/presentation/widget/badges_overview_sheet.dart

import 'package:flutter/material.dart';
import 'package:unitalk/features/auth/data/model/badge_helper.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/l10n/app_localizations.dart';

const List<String> _allBadgeIds = ['og', 'author', 'popular', 'talkative', 'social'];

class BadgesOverviewSheet extends StatelessWidget {
  final UserModel user;

  const BadgesOverviewSheet({super.key, required this.user});

  static Future<void> show(BuildContext context, {required UserModel user}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BadgesOverviewSheet(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              const SizedBox(height: 12),
              // Handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(
                      l10n.badges,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Spacer(),
                    _CountBadge(
                      earned: user.earnedBadgesCount,
                      total: _allBadgeIds.length,
                      theme: theme,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  l10n.badgesOverviewSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // List
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: _allBadgeIds.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return _BadgeCard(
                      badgeId: _allBadgeIds[index],
                      user: user,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int earned;
  final int total;
  final ThemeData theme;

  const _CountBadge({
    required this.earned,
    required this.total,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$earned / $total',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final String badgeId;
  final UserModel user;

  const _BadgeCard({required this.badgeId, required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final icon = BadgeHelper.getIcon(badgeId);
    final name = BadgeHelper.getName(badgeId, l10n);
    final description = BadgeHelper.getDescription(badgeId, l10n);

    // Find earned badge
    BadgeModel? earnedBadge;
    if (user.badges != null) {
      for (final b in user.badges!) {
        if (b.id == badgeId) {
          earnedBadge = b;
          break;
        }
      }
    }

    final isEarned = earnedBadge != null;
    final tier = earnedBadge?.tier;
    final progress = user.badgeProgress?[badgeId];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEarned
            ? _getTierColor(tier).withOpacity(0.06)
            : theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: isEarned
            ? Border.all(color: _getTierColor(tier).withOpacity(0.2), width: 1)
            : null,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isEarned
                  ? _getTierColor(tier).withOpacity(0.15)
                  : theme.colorScheme.onSurface.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Opacity(
                opacity: isEarned ? 1.0 : 0.4,
                child: Text(icon, style: const TextStyle(fontSize: 22)),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isEarned ? theme.textTheme.bodyLarge?.color : theme.hintColor,
                      ),
                    ),
                    if (tier != null) ...[
                      const SizedBox(width: 8),
                      _TierLabel(tier: tier),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.hintColor,
                  ),
                ),

                // Progress bar
                if (!isEarned && progress != null) ...[
                  const SizedBox(height: 10),
                  _ProgressBar(progress: progress, theme: theme),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Status
          if (isEarned)
            Icon(
              Icons.check_circle_rounded,
              color: _getTierColor(tier),
              size: 24,
            )
          else if (progress != null)
            Text(
              '${(progress.progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.hintColor,
              ),
            ),
        ],
      ),
    );
  }

  Color _getTierColor(String? tier) {
    switch (tier) {
      case 'gold':
        return const Color(0xFFD4A017);
      case 'silver':
        return const Color(0xFF8E99A4);
      case 'bronze':
        return const Color(0xFFB87333);
      default:
        return const Color(0xFF4A90D9);
    }
  }
}

class _TierLabel extends StatelessWidget {
  final String tier;

  const _TierLabel({required this.tier});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _getColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        BadgeHelper.getTierName(tier, l10n).toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getColor() {
    switch (tier) {
      case 'gold':
        return const Color(0xFFD4A017);
      case 'silver':
        return const Color(0xFF8E99A4);
      case 'bronze':
        return const Color(0xFFB87333);
      default:
        return Colors.grey;
    }
  }
}

class _ProgressBar extends StatelessWidget {
  final BadgeProgressModel progress;
  final ThemeData theme;

  const _ProgressBar({required this.progress, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress.progress,
            backgroundColor: theme.dividerColor.withOpacity(0.5),
            valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary.withOpacity(0.7)),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${progress.current} / ${progress.target}',
              style: TextStyle(
                fontSize: 10,
                color: theme.hintColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}