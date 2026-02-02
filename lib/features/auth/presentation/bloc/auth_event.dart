// lib/features/auth/presentation/bloc/auth_event.dart

import 'dart:io';
import 'package:unitalk/features/auth/data/model/user_model.dart';

abstract class AuthEvent {}

class SignInWithGoogleEvent extends AuthEvent {}

class SignInWithAppleEvent extends AuthEvent {}

class SignInWithDemoEvent extends AuthEvent {}

class GetCurrentUserEvent extends AuthEvent {}

class UpdateProfileEvent extends AuthEvent {
  final String? firstName;
  final String? lastName;
  final String? universityId;
  final String? facultyId;
  final Sector? sector;
  // НОВЫЕ ПОЛЯ
  final String? bio;
  final String? status;
  final String? profileEmoji;
  final Course? course;
  final String? instagramUsername;

  UpdateProfileEvent({
    this.firstName,
    this.lastName,
    this.universityId,
    this.facultyId,
    this.sector,
    this.bio,
    this.status,
    this.profileEmoji,
    this.course,
    this.instagramUsername,
  });
}

class UpdateAvatarEvent extends AuthEvent {
  final File file;
  UpdateAvatarEvent(this.file);
}

class UploadStudentCardEvent extends AuthEvent {
  final File file;
  UploadStudentCardEvent(this.file);
}

class DeleteProfileEvent extends AuthEvent {}

class SignOutEvent extends AuthEvent {}