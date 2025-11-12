import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:unitalk/core/failure/failure.dart';
import 'package:unitalk/features/auth/data/datasource/verefication_remote_datasource.dart';
import 'package:unitalk/features/auth/data/model/verification_model.dart';
import 'package:unitalk/features/auth/domain/repository/verification_repository.dart';

class VerificationRepositoryImpl implements VerificationRepository {
  final VerificationRemoteDataSource remoteDataSource;

  VerificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, VerificationModel>> uploadStudentCard(
      File file) async {
    try {
      final verification = await remoteDataSource.uploadStudentCard(file);
      return Right(verification);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VerificationModel>> getVerificationStatus() async {
    try {
      final verification = await remoteDataSource.getVerificationStatus();
      return Right(verification);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}