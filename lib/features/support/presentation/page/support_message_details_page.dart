import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart' show StatelessWidget;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/features/support/data/model/support_message_model.dart';
import 'package:unitalk/features/support/presentation/bloc/support_bloc.dart';
import 'package:unitalk/features/support/presentation/bloc/support_event.dart';
import 'package:unitalk/features/support/presentation/bloc/support_state.dart';
import 'package:unitalk/features/support/presentation/widget/status_badge.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class SupportMessageDetailsPage extends StatefulWidget {
  final String messageId;

  const SupportMessageDetailsPage({
    Key? key,
    required this.messageId,
  }) : super(key: key);

  @override
  State<SupportMessageDetailsPage> createState() =>
      _SupportMessageDetailsPageState();
}

class _SupportMessageDetailsPageState extends State<SupportMessageDetailsPage> {

  @override
  void initState() {
    super.initState();
    context.read<SupportBloc>().add(GetMessageEvent(widget.messageId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.messageDetails),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: BlocBuilder<SupportBloc, SupportState>(
        builder: (context, state)
        {
          if(state.currentMessage == null){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          var message = state.currentMessage!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              StatusBadge(status: message.status),
              const SizedBox(height: 24),
              Text(
                message.subject,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    _getCategoryIcon(message.category),
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getCategoryLabel(context, message.category),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDateTime(context, message.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.1),
                  ),
                ),
                child: Text(
                  message.message,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              if (message.imageUrl != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: message.imageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: theme.colorScheme.surface,
                        child: const Center(
                          child: Icon(Icons.broken_image_rounded),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _formatDateTime(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    return l10n.dateTimeFormat(
      date.day,
      date.month,
      date.year,
      date.hour.toString().padLeft(2, '0'),
      date.minute.toString().padLeft(2, '0'),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'technical':
        return Icons.build_rounded;
      case 'account':
        return Icons.person_rounded;
      case 'verification':
        return Icons.verified_user_rounded;
      case 'content':
        return Icons.article_rounded;
      case 'other':
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _getCategoryLabel(BuildContext context, String category) {
    final l10n = AppLocalizations.of(context)!;

    switch (category.toLowerCase()) {
      case 'technical':
        return l10n.categoryTechnicalIssue;
      case 'account':
        return l10n.categoryAccountIssue;
      case 'verification':
        return l10n.categoryVerification;
      case 'content':
        return l10n.categoryContentIssue;
      case 'other':
      default:
        return l10n.categoryOther;
    }
  }
}