import 'package:flutter/material.dart';
import 'package:unitalk/l10n/app_localizations.dart';

/// Универсальная карточка-селектор с иконкой
///
/// Используется для выбора различных опций (факультет, курс, группа и т.д.).
/// Поддерживает состояния: активное, неактивное, с выбранным значением и плейсхолдером.
class SelectorCard extends StatelessWidget {
  /// Метка (label) карточки
  final String label;

  /// Текущее выбранное значение
  final String? value;

  /// Иконка
  final IconData icon;

  /// Обработчик нажатия
  final VoidCallback? onTap;

  /// Активна ли карточка
  final bool isEnabled;

  /// Цвет иконки (по умолчанию primaryColor)
  final Color? iconColor;

  /// Размер иконки
  final double iconSize;

  /// Показывать ли стрелку справа
  final bool showChevron;

  const SelectorCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
    this.isEnabled = true,
    this.iconColor,
    this.iconSize = 20,
    this.showChevron = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    // Определяем, выбрано ли значение
    final hasValue = value != null && value!.isNotEmpty;

    // Получаем отображаемое значение или плейсхолдер
    final displayValue = hasValue ? value! : l10n.select(label);

    // Цвет для плейсхолдера
    final isPlaceholder = !hasValue;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: '$label: ${isPlaceholder ? l10n.notSelected : displayValue}',
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onTap : null,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border.all(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  // Иконка
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color:
                      (iconColor ?? theme.primaryColor).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: iconSize,
                      color: iconColor ?? theme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Текст
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayValue,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isPlaceholder
                                ? (isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade500)
                                : theme.textTheme.bodyLarge?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Стрелка
                  if (showChevron)
                    Icon(
                      Icons.chevron_right,
                      color: isDark
                          ? Colors.grey.shade600
                          : Colors.grey.shade400,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}