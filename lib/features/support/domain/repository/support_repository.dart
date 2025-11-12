// features/support/domain/repository/support_repository.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:unitalk/core/failure/failure.dart';
import 'package:unitalk/features/support/data/model/support_message_model.dart';

abstract class SupportRepository {
  Future<Either<Failure, SupportMessageModel>> createSupportMessage({
    required String subject,
    required String message,
    required String category,
    File? imageFile,
  });

  Future<Either<Failure, List<SupportMessageModel>>> getMyMessages({
    int page = 1,
    int limit = 20,
    String? status,
  });

  Future<Either<Failure, SupportMessageModel>> getMessage(String messageId);
}