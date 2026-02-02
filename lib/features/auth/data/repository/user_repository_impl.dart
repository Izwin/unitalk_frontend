// lib/features/auth/data/repository/user_repository_impl.dart

import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:unitalk/core/failure/failure.dart';
import 'package:unitalk/features/auth/data/datasource/user_remote_datasource.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/features/auth/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UserModel>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> getUserById(String userId) async {
    try {
      final user = await remoteDataSource.getUserById(userId);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> updateProfile({
    required String firstName,
    required String lastName,
    required String universityId,
    required String facultyId,
    required Sector sector,
    // НОВЫЕ ПОЛЯ
    String? bio,
    String? status,
    String? profileEmoji,
    Course? course,
    String? instagramUsername,
  }) async {
    try {
      final user = await remoteDataSource.updateProfile(
        firstName: firstName,
        lastName: lastName,
        universityId: universityId,
        facultyId: facultyId,
        sector: sector.code,
        bio: bio,
        status: status,
        profileEmoji: profileEmoji,
        course: course?.code,
        instagramUsername: instagramUsername,
      );
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> updateAvatar(File file) async {
    try {
      final photoUrl = await remoteDataSource.updateAvatar(file: file);
      return Right(photoUrl);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProfile() async {
    try {
      await remoteDataSource.deleteProfile();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}