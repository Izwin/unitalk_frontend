import 'package:dartz/dartz.dart';
import 'package:unitalk/core/failure/failure.dart';
import '../../domain/repository/about_config_repository.dart';
import '../datasource/about_config_remote_datasource.dart';
import '../model/about_config_model.dart';

class AboutConfigRepositoryImpl implements AboutConfigRepository {
  final AboutConfigRemoteDataSource remoteDataSource;

  AboutConfigRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, AboutConfigModel>> getAboutConfig() async {
    final config = await remoteDataSource.getAboutConfig();
    return Right(config);
    try {
      final config = await remoteDataSource.getAboutConfig();
      return Right(config);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}