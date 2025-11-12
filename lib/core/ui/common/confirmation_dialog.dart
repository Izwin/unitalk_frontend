import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Универсальный диалог подтверждения
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => context.pop(false),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  cancelText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.pop(true);
                  onConfirm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  confirmText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
    );
  }

  /// Показать диалог предупреждения о верификации
  static Future<bool> showVerificationWarning(
      BuildContext context,
      String title,
      String message,
      String confirmText,
      String cancelText,
      ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (dialogContext) => ConfirmationDialog(
        title: title,
        message: message,
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.orange.shade600,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: () {
          // Действие выполняется после закрытия диалога
        },
      ),
    );
    return result ?? false;
  }
}