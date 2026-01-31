import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:unitalk/core/failure/failure.dart';
import 'package:unitalk/features/feed/data/model/comment_model.dart';

abstract class CommentRepository {
  Future<Either<Failure, CommentModel>> createComment({
    required String postId,
    required String content,
    String? parentCommentId,
    String? replyToCommentId,
    required bool isAnonymous,
    File? mediaFile,
  });

  Future<Either<Failure, List<CommentModel>>> getPostComments({
    required String postId,
    int page = 1,
    int limit = 50,
  });

  Future<Either<Failure, List<CommentModel>>> getCommentReplies({
    required String commentId,
    int page = 1,
    int limit = 50,
  });

  Future<Either<Failure, void>> deleteComment(String commentId);
}

