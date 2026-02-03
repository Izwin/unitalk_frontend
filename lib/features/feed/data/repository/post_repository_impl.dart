import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:unitalk/core/failure/failure.dart';
import 'package:unitalk/features/feed/data/datasource/post_remote_datasource.dart';
import 'package:unitalk/features/feed/data/model/post_model.dart';
import 'package:unitalk/features/feed/data/model/posts_response_model.dart';
import 'package:unitalk/features/feed/domain/repository/posts_repository.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;

  PostRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, PostModel>> createPost({
    required String content,
    required bool isAnonymous,
    File? mediaFile, // Изменено с imageFile на mediaFile
  }) async {
    try {
      final post = await remoteDataSource.createPost(
        content: content,
        isAnonymous: isAnonymous,
        mediaFile: mediaFile,
      );
      return Right(post);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // features/feed/data/repository/post_repository_impl.dart

  @override
  Future<Either<Failure, PostsResponseModel>> getPosts({
    String? universityId,
    String? authorId,
    String sortBy = 'new',
    String? sector,
    String? facultyId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final data = await remoteDataSource.getPosts(
        universityId: universityId,
        authorId: authorId,
        sortBy: sortBy,
        sector: sector,
        facultyId: facultyId,
        page: page,
        limit: limit,
      );

      final response = PostsResponseModel.fromJson(data);
      return Right(response);
    } on DioException catch (e){
      return Left(ServerFailure(message: e.response?.data['error']));
    }
    catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostModel>> getPost(String postId) async {
    try {
      final post = await remoteDataSource.getPost(postId);
      return Right(post);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePost(String postId) async {
    try {
      await remoteDataSource.deletePost(postId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}