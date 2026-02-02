// lib/features/friendship/presentation/widgets/friends_count_button.dart

import 'package:flutter/material.dart';

class StatCountButton extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool highlight;
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isHighlighted
                ? cs.error.withOpacity(0.08)
                : cs.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Icon with optional badge
              _IconBadge(
                icon: icon,
                count: _isHighlighted ? count : null,
                iconColor: _isHighlighted ? cs.error : cs.onSurfaceVariant,
                badgeColor: cs.error,
              ),
              const SizedBox(width: 12),

              // Count + Label
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _isHighlighted ? cs.error : cs.onSurface,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: cs.onSurfaceVariant.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final int? count;
  final Color iconColor;
  final Color badgeColor;

  const _IconBadge({
    required this.icon,
    this.count,
    required this.iconColor,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, size: 22, color: iconColor),
        if (count != null && count! > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              constraints: const BoxConstraints(minWidth: 16),
              height: 16,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  count! > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
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