// features/support/data/repository/support_repository_impl.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:unitalk/core/failure/failure.dart';
import 'package:unitalk/features/support/data/datasource/support_remote_datasource.dart';
import 'package:unitalk/features/support/data/model/support_message_model.dart';
import 'package:unitalk/features/support/domain/repository/support_repository.dart';

class SupportRepositoryImpl implements SupportRepository {
  final SupportRemoteDataSource remoteDataSource;

  SupportRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, SupportMessageModel>> createSupportMessage({
    required String subject,
    required String message,
    required String category,
    File? imageFile,
  }) async {
    try {
      final supportMessage = await remoteDataSource.createSupportMessage(
        subject: subject,
        message: message,
        category: category,
        imageFile: imageFile,
      );
      return Right(supportMessage);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SupportMessageModel>>> getMyMessages({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final data = await remoteDataSource.getMyMessages(
        page: page,
        limit: limit,
        status: status,
      );
      final messages = (data['messages'] as List)
          .map((m) => SupportMessageModel.fromJson(m as Map<String, dynamic>))
          .toList();
      return Right(messages);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SupportMessageModel>> getMessage(
      String messageId) async {
    try {
      final message = await remoteDataSource.getMessage(messageId);
      return Right(message);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}