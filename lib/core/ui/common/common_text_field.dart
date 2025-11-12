import 'package:flutter/material.dart';

/// Общий компонент текстового поля с единообразным стилем
class CommonTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final IconData? icon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;

  const CommonTextField({
    Key? key,
    required this.controller,
    this.label,
    this.hint,
    this.icon,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
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
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(fontSize: 14),
        hintStyle: TextStyle(
          color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
        ),
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}