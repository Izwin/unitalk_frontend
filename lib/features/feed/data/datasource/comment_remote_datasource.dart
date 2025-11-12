import 'dart:io';
import 'package:dio/dio.dart';
import 'package:unitalk/features/feed/data/model/comment_model.dart';

class CommentRemoteDataSource {
  final Dio dio;

  CommentRemoteDataSource({required this.dio});

  Future<CommentModel> createComment({
    required String postId,
    required String content,
    String? parentCommentId,
    String? replyToCommentId,
    required bool isAnonymous,
    File? imageFile,
  }) async {
    FormData formData = FormData.fromMap({
      'postId': postId,
      'content': content,
      'isAnonymous': isAnonymous,
      if (parentCommentId != null) 'parentCommentId': parentCommentId,
      if (replyToCommentId != null) 'replyToCommentId': replyToCommentId,
      if (imageFile != null)
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'comment_image.jpg',
        ),
    });

    final response = await dio.post(
      '/comments',
      data: formData,
    );

    return CommentModel.fromJson(response.data);
  }

  Future<Map<String, dynamic>> getPostComments({
    required String postId,
    int page = 1,
    int limit = 50,
  }) async {
    final response = await dio.get(
      '/comments/post/$postId',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getCommentReplies({
    required String commentId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await dio.get(
      '/comments/$commentId/replies',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteComment(String commentId) async {
    await dio.delete('/comments/$commentId');
  }
}