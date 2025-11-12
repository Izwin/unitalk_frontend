// features/support/data/datasource/support_remote_datasource.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:unitalk/features/support/data/model/support_message_model.dart';

class SupportRemoteDataSource {
  final Dio dio;

  SupportRemoteDataSource({required this.dio});

  Future<SupportMessageModel> createSupportMessage({
    required String subject,
    required String message,
    required String category,
    File? imageFile,
  }) async {
    FormData formData = FormData.fromMap({
      'subject': subject,
      'message': message,
      'category': category,
      if (imageFile != null)
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'support_image.jpg',
        ),
    });

    final response = await dio.post(
      '/support',
      data: formData,
    );

    return SupportMessageModel.fromJson(response.data);
  }

  Future<Map<String, dynamic>> getMyMessages({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final response = await dio.get(
      '/support/my-messages',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<SupportMessageModel> getMessage(String messageId) async {
    final response = await dio.get('/support/$messageId');
    return SupportMessageModel.fromJson(response.data);
  }
}