import 'package:dartz/dartz.dart';
import 'package:unitalk/core/failure/failure.dart';
import 'package:unitalk/features/block/data/model/block_model.dart';

abstract class BlockRepository {
  Future<Either<Failure, BlockModel>> blockUser(String userId);

  Future<Either<Failure, void>> unblockUser(String userId);

  Future<Either<Failure, List<BlockModel>>> getBlockedUsers({
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, BlockStatusModel>> getBlockStatus(String userId);
}