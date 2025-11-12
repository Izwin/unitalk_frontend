import 'package:dio/dio.dart';
import 'package:unitalk/features/report/data/model/report_model.dart';

class ReportRemoteDataSource {
  final Dio dio;

  ReportRemoteDataSource({required this.dio});

  // Создать жалобу
  Future<ReportModel> createReport({
    required ReportTargetType targetType,
    required String targetId,
    required ReportCategory category,
    String? description,
  }) async {
    final response = await dio.post(
      '/reports',
      data: {
        'targetType': targetType.name,
        'targetId': targetId,
        'category': _categoryToString(category),
        if (description != null) 'description': description,
      },
    );
    return ReportModel.fromJson(response.data['report']);
  }

  // Получить свои жалобы
  Future<Map<String, dynamic>> getMyReports({
    int page = 1,
    int limit = 20,
    ReportStatus? status,
    ReportTargetType? targetType,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (status != null) {
      queryParams['status'] = status.name;
    }
    if (targetType != null) {
      queryParams['targetType'] = targetType.name;
    }

    final response = await dio.get(
      '/reports/my-reports',
      queryParameters: queryParams,
    );

    final reports = (response.data['reports'] as List)
        .map((json) => ReportModel.fromJson(json))
        .toList();

    return {
      'reports': reports,
      'pagination': response.data['pagination'],
    };
  }

  // Получить конкретную жалобу
  Future<ReportModel> getReport(String reportId) async {
    final response = await dio.get('/reports/$reportId');
    return ReportModel.fromJson(response.data);
  }

  // Отменить жалобу
  Future<void> deleteReport(String reportId) async {
    await dio.delete('/reports/$reportId');
  }

  // Получить статистику по жалобам
  Future<Map<String, dynamic>> getReportStats() async {
    final response = await dio.get('/reports/stats/my');
    return response.data;
  }

  String _categoryToString(ReportCategory category) {
    switch (category) {
      case ReportCategory.spam:
        return 'spam';
      case ReportCategory.harassment:
        return 'harassment';
      case ReportCategory.hateSpeech:
        return 'hate_speech';
      case ReportCategory.violence:
        return 'violence';
      case ReportCategory.nudity:
        return 'nudity';
      case ReportCategory.falseInformation:
        return 'false_information';
      case ReportCategory.impersonation:
        return 'impersonation';
      case ReportCategory.other:
        return 'other';
    }
  }
}