// lib/core/ui/common/avatar_with_badges.dart

import 'package:flutter/material.dart';
import 'package:unitalk/core/ui/common/user_avatar.dart';
import 'package:unitalk/features/auth/data/model/badge_helper.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';

class AvatarWithBadges extends StatelessWidget {
  final UserModel user;
  final double size;
  final VoidCallback? onTap;
  final String? heroTag;

  const AvatarWithBadges({
    super.key,
    required this.user,
    this.size = 80,
    this.onTap,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badges = user.badges ?? [];
    final bestTier = _getBestTier(badges);
    final ringColor = _getTierColor(bestTier);
    final hasRing = bestTier != null;

    // Показываем максимум 3 бейджа
    final displayBadges = badges.take(3).toList();

    Widget avatar = Container(
      padding: EdgeInsets.all(hasRing ? 3 : 0),
      decoration: hasRing
          ? BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: ringColor,
          width: 2.5,
        ),
      )
          : null,
      child: UserAvatar(
        photoUrl: user.photoUrl,
        firstName: user.firstName,
        lastName: user.lastName,
        size: hasRing ? size - 6 : size,
        borderRadius: size,
      ),
    );

    if (heroTag != null) {
      avatar = Hero(tag: heroTag!, child: avatar);
    }

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size + 12,
        height: size + 12,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Аватар по центру
            Positioned(
              left: 6,
              top: 6,
              child: avatar,
            ),

            // Бейджи справа внизу
            if (displayBadges.isNotEmpty)
              Positioned(
                right: 0,
                bottom: 0,
                child: _BadgesCluster(
                  badges: displayBadges,
                  theme: theme,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String? _getBestTier(List<BadgeModel> badges) {
    if (badges.isEmpty) return null;

    const tierPriority = {'gold': 3, 'silver': 2, 'bronze': 1};
    String? bestTier;
    int bestPriority = 0;

    for (final badge in badges) {
      final priority = tierPriority[badge.tier] ?? 0;
      if (priority > bestPriority) {
        bestPriority = priority;
        bestTier = badge.tier;
      }
    }

    return bestTier;
  }

  Color _getTierColor(String? tier) {
    switch (tier) {
      case 'gold':
        return const Color(0xFFD4A017);
      case 'silver':
        return const Color(0xFF9CA3AF);
      case 'bronze':
        return const Color(0xFFB87333);
      default:
        return const Color(0xFF3B82F6);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BADGES CLUSTER - группа бейджей в углу
// ═══════════════════════════════════════════════════════════════════════════

class _BadgesCluster extends StatelessWidget {
  final List<BadgeModel> badges;
  final ThemeData theme;

  const _BadgesCluster({
    required this.badges,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) return const SizedBox.shrink();

    // Один бейдж - просто круг
    if (badges.length == 1) {
      return _SingleBadge(badge: badges[0], theme: theme);
    }

    // Несколько бейджей - стек
    return SizedBox(
      width: 20 + (badges.length - 1) * 10.0,
      height: 24,
      child: Stack(
        children: [
          for (int i = badges.length - 1; i >= 0; i--)
            Positioned(
              left: i * 10.0,
              child: _SingleBadge(badge: badges[i], theme: theme, size: 24),
            ),
        ],
      ),
    );
  }
}

class _SingleBadge extends StatelessWidget {
  final BadgeModel badge;
  final ThemeData theme;
  final double size;

  const _SingleBadge({
    required this.badge,
    required this.theme,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    final icon = BadgeHelper.getIcon(badge.id);
    final tierColor = _getTierColor(badge.tier);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tierColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.scaffoldBackgroundColor,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          icon,
          style: TextStyle(fontSize: size * 0.5),
        ),
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