// features/feed/data/repository/announcement_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:unitalk/core/failure/failure.dart';
import 'package:unitalk/features/feed/data/datasource/announcement_remote_datasource.dart';
import 'package:unitalk/features/feed/data/model/announcement_model.dart';
import 'package:unitalk/features/feed/domain/repository/announcement_repository.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  final AnnouncementRemoteDataSource remoteDataSource;

  AnnouncementRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<AnnouncementModel>>> getAnnouncements() async {
    final announcements = await remoteDataSource.getAnnouncements();
    return Right(announcements);
    try {
      final announcements = await remoteDataSource.getAnnouncements();
      return Right(announcements);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markViewed(String announcementId) async {
    try {
      await remoteDataSource.markAnnouncementViewed(announcementId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markClicked(String announcementId) async {
    try {
      await remoteDataSource.markAnnouncementClicked(announcementId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}