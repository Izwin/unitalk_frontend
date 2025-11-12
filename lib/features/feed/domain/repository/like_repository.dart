import 'package:dartz/dartz.dart';
import 'package:unitalk/core/failure/failure.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/features/feed/data/model/like_response_model.dart';

abstract class LikeRepository {
  Future<Either<Failure, LikeResponseModel>> toggleLike(String postId);

  Future<Either<Failure, List<UserModel>>> getPostLikers({
    required String postId,
    int page = 1,
    int limit = 20,
  });
}