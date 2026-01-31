import 'package:dartz/dartz.dart';
import 'package:unitalk/core/failure/failure.dart';
import 'package:unitalk/features/friendship/data/datasource/friendship_remote_datasource.dart';
import 'package:unitalk/features/friendship/data/model/friendship_model.dart';
import 'package:unitalk/features/friendship/domain/repository/friendship_repository.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';

class FriendshipRepositoryImpl implements FriendshipRepository {
  final FriendshipRemoteDataSource remoteDataSource;

  FriendshipRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, FriendshipModel>> sendFriendRequest(String userId) async {
    try {
      final result = await remoteDataSource.sendFriendRequest(userId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, FriendshipModel>> acceptFriendRequest(String friendshipId) async {
    try {
      final result = await remoteDataSource.acceptFriendRequest(friendshipId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, FriendshipModel>> rejectFriendRequest(String friendshipId) async {
    try {
      final result = await remoteDataSource.rejectFriendRequest(friendshipId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFriendship(String friendshipId) async {
    try {
      await remoteDataSource.removeFriendship(friendshipId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserModel>>> getFriendsList({
    int page = 1,
    int limit = 20,
    String? userId, // ✅ ДОБАВИТЬ

  }) async {
    try {
      final response = await remoteDataSource.getFriendsList(
        page: page,
        limit: limit,
        userId: userId,
      );

      final friends = (response['friends'] as List)
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Right(friends);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FriendRequestModel>>> getIncomingRequests({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await remoteDataSource.getIncomingRequests(
        page: page,
        limit: limit,
      );

      final requests = (response['requests'] as List)
          .map((json) => FriendRequestModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Right(requests);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FriendRequestModel>>> getOutgoingRequests({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await remoteDataSource.getOutgoingRequests(
        page: page,
        limit: limit,
      );

      final requests = (response['requests'] as List)
          .map((json) => FriendRequestModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Right(requests);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, FriendshipStatusResponse>> getFriendshipStatus(String userId) async {
    try {
      final result = await remoteDataSource.getFriendshipStatus(userId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}