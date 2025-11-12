import 'package:flutter/material.dart';

/// Элемент списка с радио-кнопкой для выбора
class RadioSelectorItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const RadioSelectorItem({
    Key? key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.primaryColor.withOpacity(0.1)
                : theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.primaryColor
                  : theme.colorScheme.outline.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Radio button
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? theme.primaryColor
                        : theme.colorScheme.outline.withOpacity(0.5),
                    width: 2,
                  ),
                  color: isSelected ? theme.primaryColor : null,
                ),
                child: isSelected
                    ? Icon(
                  Icons.check,
                  size: 16,
                  color: theme.colorScheme.onPrimary,
                )
                    : null,
              ),
              const SizedBox(width: 16),
              if (icon != null) ...[
                Icon(icon, size: 20, color: theme.primaryColor),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}