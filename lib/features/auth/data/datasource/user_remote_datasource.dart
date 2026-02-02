// lib/features/auth/data/datasource/user_remote_datasource.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';

class UserRemoteDataSource {
  final Dio dio;

  UserRemoteDataSource({required this.dio});

  Future<UserModel> getCurrentUser() async {
    try {
      final response = await dio.get('/auth/me');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<UserModel> getUserById(String userId) async {
    try {
      final response = await dio.get('/auth/$userId');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<UserModel> updateProfile({
    required String firstName,
    required String lastName,
    required String universityId,
    required String facultyId,
    required String sector,
    String? language,
    String? bio,
    String? status,
    String? profileEmoji,
    String? course,
    String? instagramUsername,
  }) async {
    try {
      final data = <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'universityId': universityId,
        'facultyId': facultyId,
        'sector': sector,
      };

      if (language != null) data['language'] = language;

      // Новые поля (null удаляет значение)
      data['bio'] = bio;
      data['status'] = status;
      data['profileEmoji'] = profileEmoji;
      data['course'] = course;
      data['instagramUsername'] = instagramUsername;

      final response = await dio.put('/auth/profile', data: data);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<UserModel> updateLanguage(String language) async {
    try {
      final response = await dio.put(
        '/auth/profile',
        data: {'language': language},
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<String> updateAvatar({required File file}) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(file.path, filename: 'avatar.jpg'),
      });

      final response = await dio.post('/auth/avatar', data: formData);
      return response.data['photoUrl'] as String;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> deleteProfile() async {
    try {
      await dio.delete('/auth/profile');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';

      case DioExceptionType.connectionError:
        if (error.error is SocketException) {
          return 'No internet connection. Please check your network.';
        }
        return 'Connection error. Please check your internet connection.';

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return 'Session expired. Please login again.';
        } else if (statusCode == 403) {
          return 'Access denied.';
        } else if (statusCode == 404) {
          return 'Resource not found.';
        } else if (statusCode != null && statusCode >= 500) {
          return 'Server error. Please try again later.';
        }
        return error.response?.data?['message'] ?? 'Request failed.';

      case DioExceptionType.cancel:
        return 'Request cancelled.';

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return 'No internet connection. Please check your network.';
        }
        return 'An unexpected error occurred.';

      default:
        return 'An error occurred. Please try again.';
    }
  }
}