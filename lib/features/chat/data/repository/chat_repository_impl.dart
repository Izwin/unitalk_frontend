import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:unitalk/core/failure/failure.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/features/chat/data/datasource/chat_remote_datasource.dart';
import 'package:unitalk/features/chat/data/model/message_model.dart';
import 'package:unitalk/features/chat/domain/repository/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<MessageModel>>> getMessages({
    int page = 1,
    int limit = 50,
    DateTime? before,
  }) async {
    try {
      final data = await remoteDataSource.getMessages(
        page: page,
        limit: limit,
        before: before,
      );

      final messages = (data['messages'] as List)
          .map((m) => MessageModel.fromJson(m as Map<String, dynamic>))
          .toList();

      return Right(messages);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageModel>> sendMessage({
    required String content,
    File? imageFile,
    File? videoFile,
    String? replyTo,
  }) async {
    try {
      final message = await remoteDataSource.sendMessage(
        content: content,
        imageFile: imageFile,
        videoFile: videoFile,
        replyTo: replyTo,
      );
      return Right(message);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageModel>> editMessage({
    required String messageId,
    required String content,
  }) async {
    try {
      final message = await remoteDataSource.editMessage(
        messageId: messageId,
        content: content,
      );
      return Right(message);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMessage(String messageId) async {
    try {
      await remoteDataSource.deleteMessage(messageId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatInfoModel>> getChatInfo() async {
    try {
      final info = await remoteDataSource.getChatInfo();
      return Right(info);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserModel>>> getParticipants({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final data = await remoteDataSource.getParticipants(
        limit: limit,
        offset: offset,
      );

      return Right(data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}