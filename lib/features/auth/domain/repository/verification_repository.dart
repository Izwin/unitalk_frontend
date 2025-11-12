import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:unitalk/core/failure/failure.dart';
import 'package:unitalk/features/auth/data/model/verification_model.dart';

abstract class VerificationRepository {
  Future<Either<Failure, VerificationModel>> uploadStudentCard(File file);
}