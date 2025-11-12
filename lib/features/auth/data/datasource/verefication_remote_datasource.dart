import 'dart:io';
import 'package:dio/dio.dart';
import 'package:unitalk/features/auth/data/model/verification_model.dart';

class VerificationRemoteDataSource {
  final Dio dio;

  VerificationRemoteDataSource({required this.dio});

  Future<VerificationModel> uploadStudentCard(File file) async {
    final formData = FormData.fromMap({
      'studentCard': await MultipartFile.fromFile(
        file.path,
        filename: 'student_card.jpg',
      ),
    });

    final response = await dio.post(
      '/auth/verification/upload',
      data: formData,
    );

    return VerificationModel.fromJson(response.data['verification']);
  }

  Future<VerificationModel> getVerificationStatus() async {
    final response = await dio.get('/auth/verification/status');

    return VerificationModel.fromJson(response.data);
  }
}