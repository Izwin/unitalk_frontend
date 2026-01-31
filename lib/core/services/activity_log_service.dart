import 'package:dio/dio.dart';

class ActivityLoggerService {
  final Dio _dio;

  ActivityLoggerService(this._dio);

  Future<void> logImageView({
    required String activityType,
    String? targetId,
    String? targetModel,
    required String imageUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _dio.post('/activity/log-image-view', data: {
        'activityType': activityType,
        'targetId': targetId,
        'targetModel': targetModel,
        'imageUrl': imageUrl,
        'metadata': metadata ?? {},
      });
    } catch (e) {
      print('Failed to log image view: $e');
    }
  }

  Future<void> logImageZoom({
    required String imageUrl,
    required double scale,
    String? targetId,
    String? targetModel,
  }) async {
    await logImageView(
      activityType: 'image_zoom',
      targetId: targetId,
      targetModel: targetModel,
      imageUrl: imageUrl,
      metadata: {
        'scale': scale,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}