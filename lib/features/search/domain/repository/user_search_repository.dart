import 'package:dartz/dartz.dart';
import 'package:unitalk/core/failure/failure.dart';
import 'package:unitalk/features/search/data/model/user_search_response_model.dart';

abstract class UserSearchRepository {
  Future<Either<Failure, UserSearchResponseModel>> searchUsers({
    required String query,
    String? facultyId,
    String? universityId,
    String? sector,
    int limit = 20,
    int offset = 0,
  });
}