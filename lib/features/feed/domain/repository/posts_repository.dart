// features/feed/domain/repository/posts_repository.dart

import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:unitalk/core/failure/failure.dart';
import 'package:unitalk/features/feed/data/model/post_model.dart';
import 'package:unitalk/features/feed/data/model/posts_response_model.dart';

abstract class PostRepository {
  Future<Either<Failure, PostModel>> createPost({
    required String content,
    required bool isAnonymous,
    File? mediaFile,
  });

  // ✅ Изменён тип возврата
  Future<Either<Failure, PostsResponseModel>> getPosts({
    String? universityId,
    String? authorId,
    String sortBy = 'new',
    String? sector,
    String? facultyId,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, PostModel>> getPost(String postId);

  Future<Either<Failure, void>> deletePost(String postId);
}