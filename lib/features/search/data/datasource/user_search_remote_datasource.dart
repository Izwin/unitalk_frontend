import 'package:dio/dio.dart';
import 'package:unitalk/features/search/data/model/user_search_response_model.dart';

class UserSearchRemoteDataSource {
  final Dio dio;

  UserSearchRemoteDataSource({required this.dio});

  Future<UserSearchResponseModel> searchUsers({
    required String query,
    String? facultyId,
    String? universityId,
    String? sector,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await dio.get(
      '/auth/search',
      queryParameters: {
        'query': query,
        if (facultyId != null) 'facultyId': facultyId,
        if (universityId != null) 'universityId': universityId,
        if (sector != null) 'sector': sector,
        'limit': limit,
        'offset': offset,
      },
    );

    return UserSearchResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}