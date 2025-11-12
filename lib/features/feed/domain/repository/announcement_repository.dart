// features/feed/domain/repository/announcement_repository.dart
import 'package:dartz/dartz.dart';
import 'package:unitalk/core/failure/failure.dart';
import 'package:unitalk/features/feed/data/model/announcement_model.dart';

abstract class AnnouncementRepository {
  Future<Either<Failure, List<AnnouncementModel>>> getAnnouncements();
  Future<Either<Failure, void>> markViewed(String announcementId);
  Future<Either<Failure, void>> markClicked(String announcementId);
}