import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:unitalk/core/failure/failure.dart';
import 'package:unitalk/features/feed/data/datasource/comment_remote_datasource.dart';
import 'package:unitalk/features/feed/data/model/comment_model.dart';
import 'package:unitalk/features/feed/domain/repository/comment_repository.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource remoteDataSource;

  CommentRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, CommentModel>> createComment({
    required String postId,
    required String content,
    String? parentCommentId,
    String? replyToCommentId,
    required bool isAnonymous,
    File? mediaFile,
  }) async {
    final comment = await remoteDataSource.createComment(
      postId: postId,
      content: content,
      parentCommentId: parentCommentId,
      replyToCommentId: replyToCommentId,
      isAnonymous: isAnonymous,
      mediaFile: mediaFile,
    );
    return Right(comment);
    try {
      final comment = await remoteDataSource.createComment(
        postId: postId,
        content: content,
        parentCommentId: parentCommentId,
        replyToCommentId: replyToCommentId,
        isAnonymous: isAnonymous,
        mediaFile: mediaFile,
      );
      return Right(comment);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }


  @override
  Future<Either<Failure, List<CommentModel>>> getPostComments({
    required String postId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final data = await remoteDataSource.getPostComments(
        postId: postId,
        page: page,
        limit: limit,
      );
      final comments = (data['comments'] as List)
          .map((c) => CommentModel.fromJson(c as Map<String, dynamic>))
          .toList();
      return Right(comments);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CommentModel>>> getCommentReplies({
    required String commentId,
    int page = 1,
    int limit = 20,
  }) async {
    final data = await remoteDataSource.getCommentReplies(
      commentId: commentId,
      page: page,
      limit: limit,
    );
    final replies = (data['replies'] as List)
        .map((r) => CommentModel.fromJson(r as Map<String, dynamic>))
        .toList();

    return Right(replies);
    try {
      final data = await remoteDataSource.getCommentReplies(
        commentId: commentId,
        page: page,
        limit: limit,
      );
      final replies = (data['replies'] as List)
          .map((r) => CommentModel.fromJson(r as Map<String, dynamic>))
          .toList();

      return Right(replies);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment(String commentId) async {
    try {
      await remoteDataSource.deleteComment(commentId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}