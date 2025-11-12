import 'package:flutter/material.dart';

/// Инструкционный блок с шагами
class InstructionBox extends StatelessWidget {
  final String title;
  final List<String> steps;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;
  final Color? textColor;

  const InstructionBox({
    Key? key,
    required this.title,
    required this.steps,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBgColor = isDark
        ? Colors.blue.withOpacity(0.15)
        : Colors.blue[50];
    final defaultBorderColor = isDark
        ? Colors.blue.withOpacity(0.3)
        : Colors.blue[200]!;
    final Color defaultIconColor = isDark ? Colors.blue[300]! : Colors.blue[700]!;
    final Color defaultTextColor = isDark ? Colors.blue[200]! : Colors.blue[900]!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ?? defaultBorderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: iconColor ?? defaultIconColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? defaultTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < steps.length - 1 ? 8 : 0,
              ),
              child: _InstructionStep(
                number: (index + 1).toString(),
                text: step,
                numberColor: iconColor ?? defaultIconColor,
                textColor: textColor ?? defaultTextColor,
                isDark: isDark,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final String number;
  final String text;
  final Color numberColor;
  final Color textColor;
  final bool isDark;

  const _InstructionStep({
    required this.number,
    required this.text,
    required this.numberColor,
    required this.textColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: numberColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: isDark ? Colors.black : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: textColor,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}