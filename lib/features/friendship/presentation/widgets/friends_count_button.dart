import 'package:flutter/material.dart';

/// Единый компонент для кнопок-статистик (друзья, запросы и т.д.)
///
/// Использование:
/// ```dart
/// StatCountButton(
///   count: user.friendsCount ?? 0,
///   label: l10n.friends,
///   icon: Icons.people_outlined,
///   onTap: () => context.push('/friends'),
/// )
/// ```
class StatCountButton extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  /// Когда true — кнопка окрашивается в «тревожный» акцент (error),
  /// например при наличии входящих запросов.
  final bool highlight;

  /// Порог: если count >= этого значения — включается highlight.
  /// По умолчанию highlight управляется явно через параметр.
  final int? highlightThreshold;

  const StatCountButton({
    Key? key,
    required this.count,
    required this.label,
    required this.icon,
    required this.onTap,
    this.highlight = false,
    this.highlightThreshold,
  }) : super(key: key);

  bool get _isHighlighted {
    if (highlightThreshold != null) return count >= highlightThreshold!;
    return highlight;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final Color iconColor =
    _isHighlighted ? cs.error : cs.onSurfaceVariant;
    final Color bgColor =
    _isHighlighted
        ? cs.errorContainer.withOpacity(0.18)
        : cs.surfaceVariant.withOpacity(0.45);
    final Color borderColor =
    _isHighlighted
        ? cs.error.withOpacity(0.22)
        : theme.dividerColor.withOpacity(0.3);
    final Color countColor =
    _isHighlighted ? cs.error : cs.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 0.8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _IconWithBadge(
              icon: icon,
              iconColor: iconColor,
              badgeCount: _isHighlighted ? count : null,
              badgeColor: cs.error,
            ),
            const SizedBox(width: 10),

            // ─── Count + label ──────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$count',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      color: countColor,
                    ),
                  ),
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 6),

            // ─── Chevron ────────────────────────────────
            Icon(
              Icons.chevron_right,
              size: 16,
              color: cs.onSurfaceVariant.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Иконка с опциональным баджем ─────────────────────────────────────────
class _IconWithBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final int? badgeCount; // null → бадж не рендерится
  final Color badgeColor;

  const _IconWithBadge({
    Key? key,
    required this.icon,
    required this.iconColor,
    this.badgeCount,
    required this.badgeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (badgeCount == null) {
      return Icon(icon, size: 18, color: iconColor);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, size: 18, color: iconColor),
        Positioned(
          right: -5,
          top: -5,
          child: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              badgeCount! > 9 ? '9+' : '$badgeCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}