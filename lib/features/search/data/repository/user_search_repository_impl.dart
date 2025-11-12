import 'package:dartz/dartz.dart';
import 'package:unitalk/core/failure/failure.dart';
import 'package:unitalk/features/search/data/datasource/user_search_remote_datasource.dart';
import 'package:unitalk/features/search/data/model/user_search_response_model.dart';
import 'package:unitalk/features/search/domain/repository/user_search_repository.dart';

class UserSearchRepositoryImpl implements UserSearchRepository {
  final UserSearchRemoteDataSource remoteDataSource;

  UserSearchRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UserSearchResponseModel>> searchUsers({
    required String query,
    String? facultyId,
    String? universityId,
    String? sector,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final result = await remoteDataSource.searchUsers(
        query: query,
        facultyId: facultyId,
        universityId: universityId,
        sector: sector,
        limit: limit,
        offset: offset,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}