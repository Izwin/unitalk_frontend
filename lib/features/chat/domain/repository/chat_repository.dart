import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:unitalk/core/failure/failure.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/features/chat/data/model/message_model.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<MessageModel>>> getMessages({
    int page = 1,
    int limit = 50,
    DateTime? before,
  });

  Future<Either<Failure, MessageModel>> sendMessage({
    required String content,
    File? imageFile,
    String? replyTo,
  });

  Future<Either<Failure, MessageModel>> editMessage({
    required String messageId,
    required String content,
  });

  Future<Either<Failure, void>> deleteMessage(String messageId);

  Future<Either<Failure, ChatInfoModel>> getChatInfo();

  Future<Either<Failure, List<UserModel>>> getParticipants({
    int limit = 50,
    int offset = 0,
  });
}