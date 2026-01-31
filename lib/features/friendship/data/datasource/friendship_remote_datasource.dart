import 'package:dio/dio.dart';
import 'package:unitalk/features/friendship/data/model/friendship_model.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';

class FriendshipRemoteDataSource {
  final Dio dio;

  FriendshipRemoteDataSource({required this.dio});

  // Отправить запрос в друзья
  Future<FriendshipModel> sendFriendRequest(String userId) async {
    try {
      final response = await dio.post('/friends/request/$userId');
      return FriendshipModel.fromJson(response.data['friendship']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Принять запрос
  Future<FriendshipModel> acceptFriendRequest(String friendshipId) async {
    try {
      final response = await dio.put('/friends/accept/$friendshipId');
      return FriendshipModel.fromJson(response.data['friendship']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Отклонить запрос
  Future<FriendshipModel> rejectFriendRequest(String friendshipId) async {
    try {
      final response = await dio.put('/friends/reject/$friendshipId');
      return FriendshipModel.fromJson(response.data['friendship']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Удалить дружбу или отменить запрос
  Future<void> removeFriendship(String friendshipId) async {
    try {
      await dio.delete('/friends/$friendshipId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Получить список друзей с пагинацией
  Future<Map<String, dynamic>> getFriendsList({
    int page = 1,
    int limit = 20,
    String? userId, // ✅ ДОБАВИТЬ
  }) async {
    try {
      final endpoint = userId != null
          ? '/friends/list/$userId' // Друзья другого пользователя
          : '/friends/list'; // Свои друзья

      final response = await dio.get(
        endpoint,
        queryParameters: {'page': page, 'limit': limit},
      );
      return response.data as Map<String,dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Получить входящие запросы
  Future<Map<String, dynamic>> getIncomingRequests({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await dio.get(
        '/friends/requests/incoming',
        queryParameters: {'page': page, 'limit': limit},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Получить исходящие запросы
  Future<Map<String, dynamic>> getOutgoingRequests({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await dio.get(
        '/friends/requests/outgoing',
        queryParameters: {'page': page, 'limit': limit},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Получить статус дружбы с конкретным пользователем
  Future<FriendshipStatusResponse> getFriendshipStatus(String userId) async {
    try {
      final response = await dio.get('/friends/status/$userId');
      return FriendshipStatusResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response?.data != null && error.response!.data['error'] != null) {
      return error.response!.data['error'] as String;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please try again.';

      case DioExceptionType.connectionError:
        return 'No internet connection.';

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) return 'User not found.';
        if (statusCode == 403) return 'Access denied.';
        return 'Request failed. Please try again.';

      default:
        return 'An unexpected error occurred.';
    }
  }
}
