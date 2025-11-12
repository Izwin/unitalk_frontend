import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Заголовок для модальных окон с handle bar и кнопкой закрытия
class BottomSheetHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showCloseButton;
  final VoidCallback? onClose;

  const BottomSheetHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.showCloseButton = true,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header content
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (showCloseButton)
                IconButton(
                  onPressed: onClose ?? () => context.pop(),
                  icon: const Icon(Icons.close_rounded),
                  iconSize: 22,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}