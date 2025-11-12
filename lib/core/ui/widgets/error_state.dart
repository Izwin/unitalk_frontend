import 'package:flutter/material.dart';

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final double iconSize;

  const ErrorState({
    Key? key,
    required this.message,
    this.onRetry,
    this.retryLabel,
    this.iconSize = 64,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: iconSize,
              color: theme.colorScheme.error,
            ),
            SizedBox(height: iconSize * 0.25),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(retryLabel ?? 'Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}