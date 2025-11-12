import 'package:flutter/material.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    Color backgroundColor;
    Color textColor;
    IconData icon;
    String label;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.orange.withOpacity(0.15);
        textColor = Colors.orange;
        icon = Icons.schedule_rounded;
        label = l10n.statusPending;
        break;
      case 'in_progress':
        backgroundColor = Colors.blue.withOpacity(0.15);
        textColor = Colors.blue;
        icon = Icons.refresh_rounded;
        label = l10n.statusInProgress;
        break;
      case 'resolved':
        backgroundColor = Colors.green.withOpacity(0.15);
        textColor = Colors.green;
        icon = Icons.check_circle_rounded;
        label = l10n.statusResolved;
        break;
      case 'closed':
        backgroundColor = theme.colorScheme.onSurface.withOpacity(0.1);
        textColor = theme.colorScheme.onSurface.withOpacity(0.6);
        icon = Icons.cancel_rounded;
        label = l10n.statusClosed;
        break;
      default:
        backgroundColor = theme.colorScheme.primary.withOpacity(0.15);
        textColor = theme.colorScheme.primary;
        icon = Icons.info_outline_rounded;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}