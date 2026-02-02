// lib/core/ui/common/common_text_field.dart

import 'package:flutter/material.dart';

/// Общий компонент текстового поля с единообразным стилем
class CommonTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final String? hintText; // НОВОЕ: отдельно от hint для placeholder
  final IconData? icon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;
  // НОВЫЕ ПАРАМЕТРЫ
  final int maxLines;
  final int? maxLength;
  final String? prefixText;
  final TextInputType? keyboardType;

  const CommonTextField({
    Key? key,
    required this.controller,
    this.label,
    this.hint,
    this.hintText,
    this.icon,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.maxLength,
    this.prefixText,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText ?? hint,
        labelStyle: const TextStyle(fontSize: 14),
        hintStyle: TextStyle(
          color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
        ),
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        prefixText: prefixText,
        prefixStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: theme.textTheme.bodyMedium?.color,
        ),
        counterText: maxLength != null ? null : '', // Показывать счётчик только если есть maxLength
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        filled: true,
        fillColor: theme.cardColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: maxLines > 1 ? 16 : 16,
        ),
      ),
    );
  }
}