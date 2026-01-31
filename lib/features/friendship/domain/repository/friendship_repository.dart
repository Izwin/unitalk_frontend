import 'package:dartz/dartz.dart';
import 'package:unitalk/core/failure/failure.dart';
import 'package:unitalk/features/friendship/data/model/friendship_model.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';

abstract class FriendshipRepository {
  // Управление дружбой
  Future<Either<Failure, FriendshipModel>> sendFriendRequest(String userId);
  Future<Either<Failure, FriendshipModel>> acceptFriendRequest(String friendshipId);
  Future<Either<Failure, FriendshipModel>> rejectFriendRequest(String friendshipId);
  Future<Either<Failure, void>> removeFriendship(String friendshipId);

  // Получение данных
  Future<Either<Failure, List<UserModel>>> getFriendsList({
    int page = 1,
    int limit = 20,
    String? userId,
  });

  Future<Either<Failure, List<FriendRequestModel>>> getIncomingRequests({
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, List<FriendRequestModel>>> getOutgoingRequests({
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, FriendshipStatusResponse>> getFriendshipStatus(String userId);
}