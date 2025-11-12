import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/core/ui/common/error_state_widget.dart';
import 'package:unitalk/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:unitalk/features/notifications/presentation/bloc/notification_event.dart';
import 'package:unitalk/features/notifications/presentation/bloc/notification_state.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        title: Text(
          l10n.notificationSettings,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 1,
            color: theme.colorScheme.onSurface.withOpacity(0.08),
          ),
          Expanded(
            child: BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state.status == NotificationStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.settings == null) {
                  return ErrorStateWidget(
                    message: l10n.errorLoadingSettings,
                    onRetry: () {
                      context
                          .read<NotificationBloc>()
                          .add(GetNotificationSettingsEvent());
                    },
                    retryButtonText: l10n.retry,
                  );
                }

                final settings = state.settings!;

                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    // Master switch
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: settings.enabled
                            ? theme.colorScheme.primary.withOpacity(0.08)
                            : theme.colorScheme.onSurface.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: settings.enabled
                              ? theme.colorScheme.primary.withOpacity(0.2)
                              : theme.colorScheme.onSurface.withOpacity(0.08),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: settings.enabled
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              settings.enabled
                                  ? Icons.notifications_active
                                  : Icons.notifications_off_outlined,
                              color: settings.enabled
                                  ? Colors.white
                                  : theme.colorScheme.onSurface.withOpacity(0.4),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.enableNotifications,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.enableNotificationsDescription,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                    letterSpacing: 0.1,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Switch(
                            value: settings.enabled,
                            onChanged: (value) {
                              context
                                  .read<NotificationBloc>()
                                  .add(UpdateNotificationSettingsEvent(enabled: value));
                            },
                            activeColor: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Posts section
                    _buildSectionHeader(context, l10n.posts, Icons.post_add_rounded),
                    _buildSettingsGroup(
                      context,
                      settings,
                      [
                        _SettingData(
                          title: l10n.newPosts,
                          subtitle: l10n.newPostsDescription,
                          value: settings.newPosts,
                          onChanged: (value) {
                            context
                                .read<NotificationBloc>()
                                .add(UpdateNotificationSettingsEvent(newPosts: value));
                          },
                        ),
                        _SettingData(
                          title: l10n.newComments,
                          subtitle: l10n.newCommentsDescription,
                          value: settings.newComments,
                          onChanged: (value) {
                            context
                                .read<NotificationBloc>()
                                .add(UpdateNotificationSettingsEvent(newComments: value));
                          },
                        ),
                        _SettingData(
                          title: l10n.newLikes,
                          subtitle: l10n.newLikesDescription,
                          value: settings.newLikes,
                          onChanged: (value) {
                            context
                                .read<NotificationBloc>()
                                .add(UpdateNotificationSettingsEvent(newLikes: value));
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Comments section
                    _buildSectionHeader(context, l10n.comments, Icons.chat_bubble_outline),
                    _buildSettingsGroup(
                      context,
                      settings,
                      [
                        _SettingData(
                          title: l10n.commentReplies,
                          subtitle: l10n.commentRepliesDescription,
                          value: settings.commentReplies,
                          onChanged: (value) {
                            context.read<NotificationBloc>().add(
                                UpdateNotificationSettingsEvent(commentReplies: value));
                          },
                        ),
                        _SettingData(
                          title: l10n.mentions,
                          subtitle: l10n.mentionsDescription,
                          value: settings.mentions,
                          onChanged: (value) {
                            context
                                .read<NotificationBloc>()
                                .add(UpdateNotificationSettingsEvent(mentions: value));
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Chat section
                    _buildSectionHeader(context, l10n.chat, Icons.forum_outlined),
                    _buildSettingsGroup(
                      context,
                      settings,
                      [
                        _SettingData(
                          title: l10n.chatMessages,
                          subtitle: l10n.chatMessagesDescription,
                          value: settings.chatMessages,
                          onChanged: (value) {
                            context
                                .read<NotificationBloc>()
                                .add(UpdateNotificationSettingsEvent(chatMessages: value));
                          },
                        ),
                        _SettingData(
                          title: l10n.chatMentions,
                          subtitle: l10n.chatMentionsDescription,
                          value: settings.chatMentions,
                          onChanged: (value) {
                            context
                                .read<NotificationBloc>()
                                .add(UpdateNotificationSettingsEvent(chatMentions: value));
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(
      BuildContext context,
      dynamic settings,
      List<_SettingData> items,
      ) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _buildSettingTile(
              context: context,
              data: items[i],
              enabled: settings.enabled,
            ),
            if (i < items.length - 1)
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color: theme.colorScheme.onSurface.withOpacity(0.06),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required _SettingData data,
    required bool enabled,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: enabled ? () => data.onChanged(!data.value) : null,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                      color: enabled
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: enabled
                          ? theme.colorScheme.onSurface.withOpacity(0.6)
                          : theme.colorScheme.onSurface.withOpacity(0.3),
                      letterSpacing: 0.1,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Switch(
              value: data.value,
              onChanged: enabled ? data.onChanged : null,
              activeColor: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingData {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  _SettingData({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
}