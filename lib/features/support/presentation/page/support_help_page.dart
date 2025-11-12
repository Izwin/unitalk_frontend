import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/core/ui/common/common_text_field.dart';
import 'package:unitalk/core/ui/common/empty_state_widget.dart';
import 'package:unitalk/core/ui/common/image_source_picker.dart';
import 'package:unitalk/core/ui/common/info_box.dart';
import 'package:unitalk/core/ui/common/selector_card.dart';
import 'package:unitalk/features/support/presentation/page/create_support_message_page.dart';
import 'package:unitalk/features/support/presentation/widget/status_badge.dart';
import 'package:unitalk/l10n/app_localizations.dart';
import 'package:unitalk/features/support/presentation/bloc/support_bloc.dart';
import 'package:unitalk/features/support/presentation/bloc/support_event.dart';
import 'package:unitalk/features/support/presentation/bloc/support_state.dart';
import 'package:unitalk/features/support/data/model/support_message_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../../auth/presentation/edit_profile_page.dart';
import 'support_message_details_page.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({Key? key}) : super(key: key);

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final _scrollController = ScrollController();
  String? _selectedStatusFilter;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    context.read<SupportBloc>().add(GetMyMessagesEvent(
      page: 1,
      limit: 20,
      status: _selectedStatusFilter,
    ));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final state = context.read<SupportBloc>().state;
      if (state.status != SupportStatus.loading && !state.messagesLastPage) {
        context.read<SupportBloc>().add(GetMyMessagesEvent(
          page: state.messagesPage,
          limit: 20,
          status: _selectedStatusFilter,
        ));
      }
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _FilterBottomSheet(
        selectedStatus: _selectedStatusFilter,
        onStatusSelected: (status) {
          setState(() => _selectedStatusFilter = status);
          _loadMessages();
          context.pop();
        },
      ),
    );
  }

  void _createNewMessage() {
    context.push('/support/create').then((created) {
      if (created == true) {
        _loadMessages();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.helpSupport),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list_rounded,
              color: _selectedStatusFilter != null
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: BlocConsumer<SupportBloc, SupportState>(
        listener: (context, state) {
          if (state.status == SupportStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? l10n.errorOccurred),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == SupportStatus.loading && state.messages.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.messages.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.support_agent_rounded,
              title: l10n.noMessagesYet,
              subtitle: l10n.createFirstSupportMessage,
              iconColor: theme.colorScheme.primary,
              actionButton: ElevatedButton.icon(
                onPressed: _createNewMessage,
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.createMessage),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadMessages(),
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: state.messages.length +
                  (state.status == SupportStatus.loading ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index >= state.messages.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final message = state.messages[index];
                return _SupportMessageCard(
                  message: message,
                  onTap: () => _openMessageDetails(message),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewMessage,
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.newMessage),
        elevation: 2,
      ),
    );
  }

  void _openMessageDetails(SupportMessageModel message) {
    context.push('/support/${message.id}');
  }
}

class _SupportMessageCard extends StatelessWidget {
  final SupportMessageModel message;
  final VoidCallback onTap;

  const _SupportMessageCard({
    required this.message,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  StatusBadge(status: message.status),
                  const Spacer(),
                  Text(
                    _formatDate(context, message.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                message.subject,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                message.message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    _getCategoryIcon(message.category),
                    size: 16,
                    color: theme.colorScheme.primary.withOpacity(0.7),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getCategoryLabel(context, message.category),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return l10n.yesterday;
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
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
        return l10n.categoryTechnical;
      case 'account':
        return l10n.categoryAccount;
      case 'verification':
        return l10n.categoryVerification;
      case 'content':
        return l10n.categoryContent;
      case 'other':
      default:
        return l10n.categoryOther;
    }
  }
}


class _FilterBottomSheet extends StatelessWidget {
  final String? selectedStatus;
  final Function(String?) onStatusSelected;

  const _FilterBottomSheet({
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final statuses = [
      {'value': null, 'label': l10n.allMessages, 'icon': Icons.all_inclusive_rounded},
      {'value': 'pending', 'label': l10n.statusPending, 'icon': Icons.schedule_rounded},
      {'value': 'in_progress', 'label': l10n.statusInProgress, 'icon': Icons.refresh_rounded},
      {'value': 'resolved', 'label': l10n.statusResolved, 'icon': Icons.check_circle_rounded},
      {'value': 'closed', 'label': l10n.statusClosed, 'icon': Icons.cancel_rounded},
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  l10n.filterByStatus,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (selectedStatus != null)
                  TextButton(
                    onPressed: () => onStatusSelected(null),
                    child: Text(l10n.clear),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            itemCount: statuses.length,
            itemBuilder: (context, index) {
              final item = statuses[index];
              final value = item['value'] as String?;
              final label = item['label'] as String;
              final icon = item['icon'] as IconData;
              final isSelected = selectedStatus == value;

              return RadioSelectorItem(
                title: label,
                isSelected: isSelected,
                onTap: () => onStatusSelected(value),
                icon: icon,
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}