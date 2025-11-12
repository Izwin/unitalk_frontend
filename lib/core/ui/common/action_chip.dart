import 'package:flutter/material.dart';
import 'package:unitalk/l10n/app_localizations.dart';

/// Компактная кнопка-чип для действий (лайк, комментарий, ответ)
///
/// Используется для интерактивных элементов в постах, комментариях и других местах.
/// Поддерживает анимацию нажатия, счетчик, активное состояние и отдельные обработчики
/// для иконки и текста. Поддерживает локализацию через l10n.
class ActionChip extends StatefulWidget {
  /// Иконка действия
  final IconData icon;

  /// Ключ локализации для текста кнопки
  /// Если не указан, используется [label]
  final String? labelKey;

  /// Текст кнопки (используется если [labelKey] не указан)
  final String? label;

  /// Обработчик нажатия на всю кнопку
  final VoidCallback? onTap;

  /// Обработчик нажатия только на текст (label)
  /// Полезно для случаев, когда нужно разделить действия:
  /// например, лайк по иконке и просмотр списка лайкнувших по тексту
  final VoidCallback? onLabelTap;

  /// Активное состояние (например, пост уже лайкнут)
  final bool isActive;

  /// Цвет в активном состоянии
  final Color? activeColor;

  /// Счетчик (количество лайков, комментариев и т.д.)
  final int? count;

  const ActionChip({
    Key? key,
    required this.icon,
    this.labelKey,
    this.label,
    this.onTap,
    this.onLabelTap,
    this.isActive = false,
    this.activeColor,
    this.count,
  })  : assert(labelKey != null || label != null,
  'Either labelKey or label must be provided'),
        super(key: key);

  @override
  State<ActionChip> createState() => _ActionChipState();
}

class _ActionChipState extends State<ActionChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap != null) {
      _controller.forward().then((_) => _controller.reverse());
      widget.onTap!();
    }
  }

  void _handleLabelTap() {
    if (widget.onLabelTap != null) {
      _controller.forward().then((_) => _controller.reverse());
      widget.onLabelTap!();
    }
  }

  String _getLocalizedLabel(BuildContext context) {
    if (widget.labelKey != null) {
      final l10n = AppLocalizations.of(context)!;

      // Маппинг ключей на методы локализации
      switch (widget.labelKey) {
        case 'like':
          return l10n.like;
        case 'comment':
          return l10n.comment;
        case 'reply':
          return l10n.reply;
        case 'share':
          return l10n.share;
        case 'repost':
          return l10n.repost;
        case 'save':
          return l10n.save;
        default:
          return widget.labelKey!;
      }
    }
    return widget.label!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeColor = widget.activeColor ?? theme.primaryColor;
    final inactiveColor = isDark ? Colors.grey[400]! : Colors.grey[700]!;
    final iconColor = widget.isActive ? activeColor : inactiveColor;
    final textColor = widget.isActive ? activeColor : inactiveColor;

    // Цвет фона
    final Color backgroundColor;
    if (widget.isActive) {
      backgroundColor = isDark
          ? activeColor.withOpacity(0.15)
          : activeColor.withOpacity(0.1);
    } else {
      backgroundColor = isDark ? const Color(0xFF2A2A2A) : Colors.grey[100]!;
    }

    final localizedLabel = _getLocalizedLabel(context);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: widget.onTap != null ? _handleTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: iconColor,
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: widget.onLabelTap != null ? _handleLabelTap : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      localizedLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    if (widget.count != null && widget.count! > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        widget.count! > 999 ? '999+' : widget.count.toString(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}