import 'package:dio/dio.dart';
import '../model/about_config_model.dart';

class AboutConfigRemoteDataSource {
  final Dio dio;

  AboutConfigRemoteDataSource({required this.dio});

  Future<AboutConfigModel> getAboutConfig() async {
    try {
      final response = await dio.get('/config/about');

      if (response.data['success'] == true && response.data['data'] != null) {
        return AboutConfigModel.fromJson(response.data['data']);
      }

      throw Exception('Failed to load about config');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response?.statusCode == 404) {
      return 'Configuration not found';
    }
    return error.message ?? 'An error occurred';
  }
}