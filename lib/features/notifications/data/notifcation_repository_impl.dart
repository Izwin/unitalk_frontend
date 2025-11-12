import 'package:dartz/dartz.dart';
import 'package:unitalk/core/failure/failure.dart';
import 'package:unitalk/features/notifications/data/notifcation_remote_datasource.dart';
import 'package:unitalk/features/notifications/domain/notifcation_repository.dart';
import 'package:unitalk/features/notifications/model/notification_model.dart';
import 'package:unitalk/features/notifications/model/notification_response_model.dart';
import 'package:unitalk/features/notifications/model/notification_settings_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, NotificationSettingsModel>> getSettings() async {
    try {
      final settings = await remoteDataSource.getSettings();
      return Right(settings);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationSettingsModel>> updateSettings({
    bool? enabled,
    bool? newPosts,
    bool? newComments,
    bool? newLikes,
    bool? commentReplies,
    bool? mentions,
    bool? chatMessages,
    bool? chatMentions,
  }) async {
    try {
      final settings = await remoteDataSource.updateSettings(
        enabled: enabled,
        newPosts: newPosts,
        newComments: newComments,
        newLikes: newLikes,
        commentReplies: commentReplies,
        mentions: mentions,
        chatMessages: chatMessages,
        chatMentions: chatMentions,
      );
      return Right(settings);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveFcmToken(String fcmToken) async {
    try {
      await remoteDataSource.saveFcmToken(fcmToken);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFcmToken() async {
    try {
      await remoteDataSource.removeFcmToken();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationsResponseModel>> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    try {
      final response = await remoteDataSource.getNotifications(
        page: page,
        limit: limit,
        unreadOnly: unreadOnly,
      );
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationModel>> markAsRead(
      String notificationId) async {
    try {
      final notification = await remoteDataSource.markAsRead(notificationId);
      return Right(notification);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await remoteDataSource.markAllAsRead();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(
      String notificationId) async {
    try {
      await remoteDataSource.deleteNotification(notificationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllNotifications() async {
    try {
      await remoteDataSource.deleteAllNotifications();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final count = await remoteDataSource.getUnreadCount();
      return Right(count);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}