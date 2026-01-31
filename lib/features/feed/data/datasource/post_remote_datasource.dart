import 'package:dio/dio.dart';
import 'package:unitalk/features/feed/data/model/post_model.dart';
import 'dart:io';

class PostRemoteDataSource {
  final Dio dio;

  PostRemoteDataSource({required this.dio});

  Future<PostModel> createPost({
    required String content,
    required bool isAnonymous,
    File? mediaFile, // Изменено с imageFile на mediaFile
  }) async {
    FormData formData = FormData.fromMap({
      'content': content,
      'isAnonymous': isAnonymous,
      if (mediaFile != null)
        'media': await MultipartFile.fromFile(
          mediaFile.path,
          filename: _getMediaFileName(mediaFile),
        ),
    });

    final response = await dio.post(
      '/posts',
      data: formData,
    );

    return PostModel.fromJson(response.data);
  }

  // Вспомогательный метод для определения имени файла
  String _getMediaFileName(File file) {
    final path = file.path.toLowerCase();
    if (path.endsWith('.mp4') || path.endsWith('.mov')) {
      return 'post_video.mp4';
    }
    return 'post_image.jpg';
  }

  Future<Map<String, dynamic>> getPosts({
    String? universityId,
    String? authorId,
    String sortBy = 'new',
    String? sector,
    String? facultyId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await dio.get(
      '/posts',
      queryParameters: {
        if (universityId != null) 'universityId': universityId,
        if (authorId != null) 'authorId': authorId,
        if (sector != null) 'sector': sector,
        if (facultyId != null) 'facultyId': facultyId,
        'sortBy': sortBy,
        'page': page,
        'limit': limit,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<PostModel> getPost(String postId) async {
    final response = await dio.get('/posts/$postId');
    return PostModel.fromJson(response.data);
  }

  Future<void> deletePost(String postId) async {
    await dio.delete('/posts/$postId');
  }
}