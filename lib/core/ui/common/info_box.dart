import 'package:flutter/material.dart';

enum InfoBoxType { info, warning, success, error }

/// Универсальный информационный блок
class InfoBox extends StatelessWidget {
  final String message;
  final InfoBoxType type;
  final IconData? customIcon;

  const InfoBox({
    Key? key,
    required this.message,
    this.type = InfoBoxType.info,
    this.customIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _getColors(isDark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: type == InfoBoxType.info
            ? Border.all(color: colors.borderColor)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            customIcon ?? _getIcon(),
            color: colors.iconColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: colors.textColor,
                height: 1.4,
                fontWeight: type == InfoBoxType.warning || type == InfoBoxType.error
                    ? FontWeight.w500
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (type) {
      case InfoBoxType.info:
        return Icons.info_outline;
      case InfoBoxType.warning:
        return Icons.warning_amber_rounded;
      case InfoBoxType.success:
        return Icons.check_circle_outline;
      case InfoBoxType.error:
        return Icons.error_outline;
    }
  }

  _InfoBoxColors _getColors(bool isDark) {
    switch (type) {
      case InfoBoxType.info:
        return _InfoBoxColors(
          backgroundColor: isDark
              ? Colors.blue.withOpacity(0.15)
              : Colors.blue[50]!,
          borderColor: isDark
              ? Colors.blue.withOpacity(0.3)
              : Colors.blue[200]!,
          iconColor: isDark ? Colors.blue[300]! : Colors.blue[700]!,
          textColor: isDark ? Colors.blue[200]! : Colors.blue[900]!,
        );
      case InfoBoxType.warning:
        return _InfoBoxColors(
          backgroundColor: isDark
              ? Colors.orange.withOpacity(0.15)
              : Colors.orange[50]!,
          borderColor: Colors.transparent,
          iconColor: isDark ? Colors.orange[300]! : Colors.orange[700]!,
          textColor: isDark ? Colors.orange[200]! : Colors.orange[900]!,
        );
      case InfoBoxType.success:
        return _InfoBoxColors(
          backgroundColor: isDark
              ? Colors.green.withOpacity(0.15)
              : Colors.green[50]!,
          borderColor: Colors.transparent,
          iconColor: isDark ? Colors.green[300]! : Colors.green[700]!,
          textColor: isDark ? Colors.green[200]! : Colors.green[900]!,
        );
      case InfoBoxType.error:
        return _InfoBoxColors(
          backgroundColor: isDark
              ? Colors.red.withOpacity(0.15)
              : Colors.red[50]!,
          borderColor: Colors.transparent,
          iconColor: isDark ? Colors.red[300]! : Colors.red[700]!,
          textColor: isDark ? Colors.red[200]! : Colors.red[900]!,
        );
    }
  }
}

class _InfoBoxColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;

  _InfoBoxColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
  });
}