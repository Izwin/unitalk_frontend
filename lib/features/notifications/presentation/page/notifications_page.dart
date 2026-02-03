import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:unitalk/core/ui/common/confirm_delete_dialog.dart';
import 'package:unitalk/core/ui/common/empty_state_widget.dart';
import 'package:unitalk/core/ui/common/error_state_widget.dart';
import 'package:unitalk/core/ui/common/user_avatar.dart';
import 'package:unitalk/features/notifications/model/notification_model.dart';
import 'package:unitalk/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:unitalk/features/notifications/presentation/bloc/notification_event.dart';
import 'package:unitalk/features/notifications/presentation/bloc/notification_state.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    context.read<NotificationBloc>().add(RefreshNotificationsEvent());

    await context.read<NotificationBloc>().stream.firstWhere(
      (state) => state.status != NotificationStatus.loading,
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final bloc = context.read<NotificationBloc>();
      if (bloc.state.hasMore &&
          bloc.state.status != NotificationStatus.loadingMore) {
        bloc.add(
          GetNotificationsEvent(
            page: bloc.state.currentPage,
            loadMore: true,
          ),
        );
      }
    }
  }

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
          l10n.notifications,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 22),
            onPressed: () => context.push('/notification-settings'),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, size: 22),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(
                      Icons.done_all,
                      size: 20,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.markAllAsRead),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.deleteAll,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              final bloc = context.read<NotificationBloc>();
              if (value == 'mark_all_read') {
                bloc.add(MarkAllNotificationsAsReadEvent());
              } else if (value == 'delete_all') {
                _showDeleteAllDialog(context);
              }
            },
          ),
          const SizedBox(width: 4),
        ],
        // Разделитель как часть AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: theme.colorScheme.onSurface.withOpacity(0.08),
          ),
        ),
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          // Loading state
          if (state.status == NotificationStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error state
          if (state.status == NotificationStatus.failure) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    child: ErrorStateWidget(
                      message: state.errorMessage ?? l10n.errorLoadingNotifications,
                      onRetry: () {
                        context.read<NotificationBloc>().add(
                          RefreshNotificationsEvent(),
                        );
                      },
                      retryButtonText: l10n.retry,
                    ),
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (state.notifications.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    child: EmptyStateWidget(
                      icon: Icons.notifications_off_outlined,
                      title: l10n.noNotifications,
                      subtitle: l10n.allCaughtUp,
                      iconColor: theme.colorScheme.primary.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          // Success state with data
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.separated(
              controller: _scrollController,  // ← Теперь controller работает корректно!
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.notifications.length +
                  (state.status == NotificationStatus.loadingMore ? 1 : 0),
              separatorBuilder: (context, index) => Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color: theme.colorScheme.onSurface.withOpacity(0.06),
              ),
              itemBuilder: (context, index) {
                // Loading more indicator
                if (index == state.notifications.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                final notification = state.notifications[index];
                return Dismissible(
                  key: Key(notification.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: theme.colorScheme.error.withOpacity(0.1),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24.0),
                    child: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                      size: 22,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await ConfirmDeleteDialog.show(
                      context,
                      title: l10n.deleteNotification,
                      content: l10n.deleteNotificationConfirm,
                      onConfirm: () {},
                    );
                  },
                  onDismissed: (direction) {
                    context.read<NotificationBloc>().add(
                      DeleteNotificationEvent(notification.id),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.notificationDeleted),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  child: NotificationTile(notification: notification),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _showDeleteAllDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      title: l10n.deleteAllNotifications,
      content: l10n.deleteAllNotificationsConfirm,
      onConfirm: () {},
    );

    if (confirmed == true && context.mounted) {
      context.read<NotificationBloc>().add(DeleteAllNotificationsEvent());
    }
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const NotificationTile({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Настройка локализации для timeago
    timeago.setLocaleMessages('ru', timeago.RuMessages());
    timeago.setLocaleMessages('az', timeago.AzMessages());

    // Determine display info
    String displayName = 'Anonymous';
    String? avatarUrl;
    String? firstName;
    String? lastName;
    bool isAnonymous = false;

    if (notification.post != null) {
      isAnonymous = notification.post!.isAnonymous;
    }

    if (!isAnonymous && notification.fromUser != null) {
      final user = notification.fromUser!;
      firstName = user.firstName;
      lastName = user.lastName;
      if (firstName != null && lastName != null) {
        displayName = '$firstName $lastName';
      }
      avatarUrl = user.photoUrl;
    }

    return InkWell(
      onTap: () => _navigateToNotificationTarget(context, notification),
      child: Container(
        color: notification.isRead
            ? null
            : theme.colorScheme.primary.withOpacity(0.04),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            UserAvatar(
              photoUrl: isAnonymous ? null : avatarUrl,
              firstName: isAnonymous ? null : firstName,
              lastName: isAnonymous ? null : lastName,
              size: 44,
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: notification.isRead
                          ? FontWeight.w500
                          : FontWeight.w600,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      letterSpacing: 0.1,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (!isAnonymous) ...[
                        Text(
                          displayName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.1,
                          ),
                        ),
                        Text(
                          ' • ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                      Text(
                        timeago.format(
                          notification.createdAt,
                          locale: Localizations
                              .localeOf(context)
                              .languageCode,
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Thumbnail
            if (notification.post?.imageUrl != null) ...[
              const SizedBox(width: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: notification.post!.imageUrl!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorWidget: (context, error, stackTrace) {
                    return Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.image_outlined,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToNotificationTarget(BuildContext context, NotificationModel notification) {
    // Помечаем как прочитанное
    if (!notification.isRead) {
      context.read<NotificationBloc>().add(
        MarkNotificationAsReadEvent(notification.id),
      );
    }

    // Навигация в зависимости от типа
    switch (notification.type) {
      case 'new_post':
      case 'new_comment':
      case 'new_comment_like':
      case 'new_like':
      case 'comment_reply':
      case 'mention':
        if (notification.postId != null && notification.postId!.isNotEmpty) {
          context.push('/post/${notification.postId}');
        } else {
          _showNavigationError(context, 'Post not found');
        }
        break;

      case 'new_chat_message':
      case 'chat_mention':
        context.go('/chat');
        break;

    // ✅ ДОБАВЛЕНО: навигация для друзей
      case 'friend_request':
        context.push('/friends');
        break;

      case 'friend_request_accepted':
        context.push('/friends');
        break;

      default:
        print('Unknown notification type: ${notification.type}');
        _showNavigationError(context, 'Cannot open this notification');
    }
  }

  void _showNavigationError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
