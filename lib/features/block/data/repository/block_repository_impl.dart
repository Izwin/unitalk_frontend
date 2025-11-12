import 'package:dartz/dartz.dart';
import 'package:unitalk/core/failure/failure.dart';
import 'package:unitalk/features/block/data/datasource/block_remote_datasource.dart';
import 'package:unitalk/features/block/data/model/block_model.dart';
import 'package:unitalk/features/block/domain/repository/block_repository.dart';

class BlockRepositoryImpl implements BlockRepository {
  final BlockRemoteDataSource remoteDataSource;

  BlockRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, BlockModel>> blockUser(String userId) async {
    try {
      final block = await remoteDataSource.blockUser(userId);
      return Right(block);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unblockUser(String userId) async {
    try {
      await remoteDataSource.unblockUser(userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BlockModel>>> getBlockedUsers({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await remoteDataSource.getBlockedUsers(
        page: page,
        limit: limit,
      );
      return Right(result['blocks'] as List<BlockModel>);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BlockStatusModel>> getBlockStatus(String userId) async {
    final status = await remoteDataSource.getBlockStatus(userId);
    return Right(status);
    try {
      final status = await remoteDataSource.getBlockStatus(userId);
      return Right(status);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}