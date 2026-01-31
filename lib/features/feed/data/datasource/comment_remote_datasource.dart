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
    File? mediaFile, // Изменено с imageFile на mediaFile
  }) async {
    FormData formData = FormData.fromMap({
      'postId': postId,
      'content': content,
      'isAnonymous': isAnonymous,
      if (parentCommentId != null) 'parentCommentId': parentCommentId,
      if (replyToCommentId != null) 'replyToCommentId': replyToCommentId,
      if (mediaFile != null)
        'media': await MultipartFile.fromFile(
          mediaFile.path,
          filename: _getMediaFileName(mediaFile),
        ),
    });

    final response = await dio.post(
      '/comments',
      data: formData,
    );

    return CommentModel.fromJson(response.data);
  }

  String _getMediaFileName(File file) {
    final path = file.path.toLowerCase();
    if (path.endsWith('.mp4') || path.endsWith('.mov') || path.endsWith('.avi')) {
      return 'comment_video.mp4';
    }
    return 'comment_image.jpg';
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