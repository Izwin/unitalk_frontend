// lib/features/auth/domain/repository/user_repository.dart

import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:unitalk/core/failure/failure.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';

abstract class UserRepository {
  Future<Either<Failure, UserModel>> getCurrentUser();

  Future<Either<Failure, UserModel>> getUserById(String userId);

  Future<Either<Failure, UserModel>> updateProfile({
    required String firstName,
    required String lastName,
    required String universityId,
    required String facultyId,
    required Sector sector,
    String? bio,
    String? status,
    String? profileEmoji,
    Course? course,
    String? instagramUsername,
  });

  Future<Either<Failure, String>> updateAvatar(File file);

  Future<Either<Failure, void>> deleteProfile();
}