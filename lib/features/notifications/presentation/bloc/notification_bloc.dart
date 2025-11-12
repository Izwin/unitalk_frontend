import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/features/notifications/domain/notifcation_repository.dart';
import 'package:unitalk/features/notifications/presentation/bloc/notification_event.dart';
import 'package:unitalk/features/notifications/presentation/bloc/notification_state.dart';


class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository notificationRepository;

  NotificationBloc({required this.notificationRepository})
      : super(NotificationState.initial()) {
    on<GetNotificationSettingsEvent>(_onGetSettings);
    on<UpdateNotificationSettingsEvent>(_onUpdateSettings);
    on<SaveFcmTokenEvent>(_onSaveFcmToken);
    on<RemoveFcmTokenEvent>(_onRemoveFcmToken);
    on<GetNotificationsEvent>(_onGetNotifications);
    on<MarkNotificationAsReadEvent>(_onMarkAsRead);
    on<MarkAllNotificationsAsReadEvent>(_onMarkAllAsRead);
    on<DeleteNotificationEvent>(_onDeleteNotification);
    on<DeleteAllNotificationsEvent>(_onDeleteAllNotifications);
    on<RefreshNotificationsEvent>(_onRefreshNotifications);
    on<GetUnreadCountEvent>(_onGetUnreadCount);
    on<HandleIncomingNotificationEvent>(_onHandleIncomingNotification);
  }

  Future<void> _onGetSettings(
      GetNotificationSettingsEvent event,
      Emitter<NotificationState> emit,
      ) async {
    emit(state.copyWith(status: NotificationStatus.loading));

    final result = await notificationRepository.getSettings();

    result.fold(
          (failure) => emit(state.copyWith(
        status: NotificationStatus.failure,
        errorMessage: failure.message,
      )),
          (settings) => emit(state.copyWith(
        status: NotificationStatus.success,
        settings: settings,
      )),
    );
  }

  Future<void> _onUpdateSettings(
      UpdateNotificationSettingsEvent event,
      Emitter<NotificationState> emit,
      ) async {
    emit(state.copyWith(status: NotificationStatus.loading));

    final result = await notificationRepository.updateSettings(
      enabled: event.enabled,
      newPosts: event.newPosts,
      newComments: event.newComments,
      newLikes: event.newLikes,
      commentReplies: event.commentReplies,
      mentions: event.mentions,
      chatMessages: event.chatMessages,
      chatMentions: event.chatMentions,
    );

    result.fold(
          (failure) => emit(state.copyWith(
        status: NotificationStatus.failure,
        errorMessage: failure.message,
      )),
          (settings) => emit(state.copyWith(
        status: NotificationStatus.success,
        settings: settings,
      )),
    );
  }

  Future<void> _onSaveFcmToken(
      SaveFcmTokenEvent event,
      Emitter<NotificationState> emit,
      ) async {
    final result = await notificationRepository.saveFcmToken(event.fcmToken);

    result.fold(
          (failure) => emit(state.copyWith(
        status: NotificationStatus.failure,
        errorMessage: failure.message,
      )),
          (_) => null,
    );
  }

  Future<void> _onRemoveFcmToken(
      RemoveFcmTokenEvent event,
      Emitter<NotificationState> emit,
      ) async {
    final result = await notificationRepository.removeFcmToken();

    result.fold(
          (failure) => emit(state.copyWith(
        status: NotificationStatus.failure,
        errorMessage: failure.message,
      )),
          (_) => null,
    );
  }

  Future<void> _onGetNotifications(
      GetNotificationsEvent event,
      Emitter<NotificationState> emit,
      ) async {
    if (event.loadMore) {
      if (!state.hasMore) return;
      emit(state.copyWith(status: NotificationStatus.loadingMore));
    } else {
      emit(state.copyWith(status: NotificationStatus.loading));
    }

    final result = await notificationRepository.getNotifications(
      page: event.page,
      limit: 20,
      unreadOnly: event.unreadOnly,
    );

    result.fold(
          (failure) => emit(state.copyWith(
        status: NotificationStatus.failure,
        errorMessage: failure.message,
      )),
          (response) {
        final newNotifications = event.loadMore
            ? [...state.notifications, ...response.notifications]
            : response.notifications;

        emit(state.copyWith(
          status: NotificationStatus.success,
          notifications: newNotifications,
          unreadCount: response.unreadCount,
          currentPage: state.currentPage + 1,
          hasMore: response.notifications.length >= 20
        ));
      },
    );
  }

  Future<void> _onMarkAsRead(
      MarkNotificationAsReadEvent event,
      Emitter<NotificationState> emit,
      ) async {
    final result =
    await notificationRepository.markAsRead(event.notificationId);

    result.fold(
          (failure) => emit(state.copyWith(
        status: NotificationStatus.failure,
        errorMessage: failure.message,
      )),
          (updatedNotification) {
        final updatedList = state.notifications.map((n) {
          if (n.id == updatedNotification.id) {
            return updatedNotification;
          }
          return n;
        }).toList();

        final newUnreadCount = state.unreadCount > 0 ? state.unreadCount - 1 : 0;

        emit(state.copyWith(
          notifications: updatedList,
          unreadCount: newUnreadCount,
        ));
      },
    );
  }

  Future<void> _onMarkAllAsRead(
      MarkAllNotificationsAsReadEvent event,
      Emitter<NotificationState> emit,
      ) async {
    final result = await notificationRepository.markAllAsRead();

    result.fold(
          (failure) => emit(state.copyWith(
        status: NotificationStatus.failure,
        errorMessage: failure.message,
      )),
          (_) {
        final updatedList = state.notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();

        emit(state.copyWith(
          notifications: updatedList,
          unreadCount: 0,
        ));
      },
    );
  }

  Future<void> _onDeleteNotification(
      DeleteNotificationEvent event,
      Emitter<NotificationState> emit,
      ) async {
    final result =
    await notificationRepository.deleteNotification(event.notificationId);

    result.fold(
          (failure) => emit(state.copyWith(
        status: NotificationStatus.failure,
        errorMessage: failure.message,
      )),
          (_) {
        final notification = state.notifications
            .firstWhere((n) => n.id == event.notificationId);

        final updatedList = state.notifications
            .where((n) => n.id != event.notificationId)
            .toList();

        final newUnreadCount = !notification.isRead && state.unreadCount > 0
            ? state.unreadCount - 1
            : state.unreadCount;

        emit(state.copyWith(
          notifications: updatedList,
          unreadCount: newUnreadCount,
        ));
      },
    );
  }

  Future<void> _onDeleteAllNotifications(
      DeleteAllNotificationsEvent event,
      Emitter<NotificationState> emit,
      ) async {
    emit(state.copyWith(status: NotificationStatus.loading));

    final result = await notificationRepository.deleteAllNotifications();

    result.fold(
          (failure) => emit(state.copyWith(
        status: NotificationStatus.failure,
        errorMessage: failure.message,
      )),
          (_) => emit(state.copyWith(
        status: NotificationStatus.success,
        notifications: [],
        unreadCount: 0,
      )),
    );
  }

  Future<void> _onRefreshNotifications(
      RefreshNotificationsEvent event,
      Emitter<NotificationState> emit,
      ) async {
    print('sdfasfasf');
    final result = await notificationRepository.getNotifications(
      page: 1,
      unreadOnly: false,
    );

    result.fold(
          (failure) => emit(state.copyWith(
        status: NotificationStatus.failure,
        errorMessage: failure.message,
      )),
          (response) {
        emit(state.copyWith(
          status: NotificationStatus.success,
          notifications: response.notifications,
          unreadCount: response.unreadCount,
          currentPage: 1,
          hasMore: response.notifications.length < 20,
        ));
      },
    );
  }

  Future<void> _onGetUnreadCount(
      GetUnreadCountEvent event,
      Emitter<NotificationState> emit,
      ) async {
    final result = await notificationRepository.getUnreadCount();

    result.fold(
          (failure) => null,
          (count) => emit(state.copyWith(unreadCount: count)),
    );
  }

  Future<void> _onHandleIncomingNotification(
      HandleIncomingNotificationEvent event,
      Emitter<NotificationState> emit,
      ) async {
    // Increment unread count when new notification arrives
    emit(state.copyWith(unreadCount: state.unreadCount + 1));

    // Optionally refresh notifications list
    add(RefreshNotificationsEvent());
  }
}