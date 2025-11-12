import 'package:dio/dio.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/features/feed/data/model/like_response_model.dart';

class LikeRemoteDataSource {
  final Dio dio;

  LikeRemoteDataSource({required this.dio});

  Future<LikeResponseModel> toggleLike(String postId) async {
    final response = await dio.put('/posts/$postId/like');
    return LikeResponseModel.fromJson(response.data);
  }

  Future<List<UserModel>> getPostLikers({
    required String postId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await dio.get(
      '/posts/$postId/likes',
      queryParameters: {'page': page, 'limit': limit},
    );
    return (response.data['likers'] as List)
        .map((e) => UserModel.fromJson(e))
        .toList();
  }
}