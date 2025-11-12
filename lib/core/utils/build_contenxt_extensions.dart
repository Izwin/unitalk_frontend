import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/l10n/app_localizations.dart';

/// Расширения для BuildContext
extension BuildContextExtensions on BuildContext {
  // Theme shortcuts
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;

  // Localization
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  String get locale => Localizations.localeOf(this).languageCode;

  // Navigation helpers
  void pushNamed(String route, {Object? extra}) {
    GoRouter.of(this).push(route, extra: extra);
  }

  void goNamed(String route, {Object? extra}) {
    GoRouter.of(this).go(route, extra: extra);
  }

  void pop<T>([T? result]) {
    GoRouter.of(this).pop(result);
  }

  // Snackbar helpers
  void showSnackBar(
      String message, {
        Duration duration = const Duration(seconds: 3),
        SnackBarAction? action,
        Color? backgroundColor,
      }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void showErrorSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: colors.error,
    );
  }

  void showSuccessSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.green,
    );
  }

  // Dialog helpers
  Future<bool?> showConfirmDialog({
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    bool isDanger = false,
  }) {
    return showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => GoRouterHelper(context).pop(false),
            child: Text(
              cancelText ?? l10n.cancel,
              style: TextStyle(
                color: colors.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () => GoRouterHelper(context).pop( true),
            child: Text(
              confirmText ?? l10n.delete,
              style: TextStyle(
                color: isDanger ? colors.error : colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Loading dialog
  void showLoadingDialog() {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  void hideLoadingDialog() {
    GoRouterHelper(this).pop();
  }

  // MediaQuery shortcuts
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get viewPadding => MediaQuery.of(this).viewPadding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
}