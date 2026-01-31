import 'package:dartz/dartz.dart';
import 'package:unitalk/core/failure/failure.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/features/feed/data/datasource/like_remote_datasource.dart';
import 'package:unitalk/features/feed/data/model/like_response_model.dart';
import 'package:unitalk/features/feed/domain/repository/like_repository.dart';

class LikeRepositoryImpl implements LikeRepository {
  final LikeRemoteDataSource remoteDataSource;

  LikeRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, LikeResponseModel>> toggleLike(String postId) async {
    try {
      final likesCount = await remoteDataSource.toggleLike(postId);
      return Right(likesCount);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserModel>>> getPostLikers({
    required String postId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final data = await remoteDataSource.getPostLikers(
        postId: postId,
        page: page,
        limit: limit,
      );
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserModel>>> getCommentLikers({required String commentId, int page = 1, int limit = 20}) async {
    try {
      final data = await remoteDataSource.getCommentLikers(
        comment: commentId,
        page: page,
        limit: limit,
      );
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LikeResponseModel>> toggleCommentLike(String commentId) async {
    try {
      final likesCount = await remoteDataSource.toggleCommentLike(commentId);
      return Right(likesCount);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}