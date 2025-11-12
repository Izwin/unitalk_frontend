import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Универсальный виджет аватара с поддержкой:
/// - Загрузки изображений из сети
/// - Отображения инициалов
/// - Настраиваемого размера
/// - Placeholder'ов
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? firstName;
  final String? lastName;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;

  const AppAvatar({
    Key? key,
    this.imageUrl,
    this.firstName,
    this.lastName,
    this.size = 40,
    this.backgroundColor,
    this.textColor,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2,
  }) : super(key: key);

  String get _initials {
    final first = firstName?.trim() ?? '';
    final last = lastName?.trim() ?? '';

    if (first.isEmpty && last.isEmpty) return '?';

    String result = '';
    if (first.isNotEmpty) result += first[0];
    if (last.isNotEmpty) result += last[0];

    return result.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = backgroundColor ??
        (isDark
            ? theme.cardColor.withOpacity(0.3)
            : theme.textTheme.bodySmall?.color?.withOpacity(0.05));

    final txtColor = textColor ??
        theme.textTheme.bodySmall?.color?.withOpacity(0.7);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        border: showBorder
            ? Border.all(
          color: borderColor ?? theme.colorScheme.primary,
          width: borderWidth,
        )
            : null,
      ),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildInitials(txtColor),
          errorWidget: (context, url, error) => _buildInitials(txtColor),
        ),
      )
          : _buildInitials(txtColor),
    );
  }

  Widget _buildInitials(Color? textColor) {
    return Center(
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}