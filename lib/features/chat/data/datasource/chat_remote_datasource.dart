import 'dart:io';
import 'package:dio/dio.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';


import '../model/message_model.dart';

class ChatRemoteDataSource {
  final Dio dio;

  ChatRemoteDataSource({required this.dio});

  // Get message history
  Future<Map<String, dynamic>> getMessages({
    int page = 1,
    int limit = 50,
    DateTime? before,
  }) async {
    final response = await dio.get(
      '/chat/messages',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (before != null) 'before': before.toIso8601String(),
      },
    );
    return response.data as Map<String, dynamic>;
  }

  // Send message
  Future<MessageModel> sendMessage({
    required String content,
    File? imageFile,
    String? replyTo,
  }) async {
    FormData formData = FormData.fromMap({
      'content': content,
      if (replyTo != null) 'replyTo': replyTo,
      if (imageFile != null)
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'message_image.jpg',
        ),
    });

    final response = await dio.post(
      '/chat/messages',
      data: formData,
    );

    return MessageModel.fromJson(response.data);
  }

  // Edit message
  Future<MessageModel> editMessage({
    required String messageId,
    required String content,
  }) async {
    final response = await dio.put(
      '/chat/messages/$messageId',
      data: {'content': content},
    );

    return MessageModel.fromJson(response.data);
  }

  // Delete message
  Future<void> deleteMessage(String messageId) async {
    await dio.delete('/chat/messages/$messageId');
  }

  // Get chat info
  Future<ChatInfoModel> getChatInfo() async {
    final response = await dio.get('/chat/info');
    return ChatInfoModel.fromJson(response.data);
  }


  Future<List<UserModel>> getParticipants({
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await dio.get(
      '/chat/participants',
      queryParameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    return (response.data['participants'] as List).map((e) => UserModel.fromJson(e)).toList();
  }
}