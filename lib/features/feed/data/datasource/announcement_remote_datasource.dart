// features/feed/data/datasource/announcement_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:unitalk/features/feed/data/model/announcement_model.dart';

class AnnouncementRemoteDataSource {
  final Dio dio;

  AnnouncementRemoteDataSource({required this.dio});

  Future<List<AnnouncementModel>> getAnnouncements() async {
    final response = await dio.get('/announcements');
    return (response.data as List)
        .map((json) => AnnouncementModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAnnouncementViewed(String announcementId) async {
    await dio.post('/announcements/$announcementId/view');
  }

  Future<void> markAnnouncementClicked(String announcementId) async {
    await dio.post('/announcements/$announcementId/click');
  }
}