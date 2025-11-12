import 'dart:io';
import 'dart:ui';

import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/l10n/data/model/language_model.dart';

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
  final Language? language;

  UpdateProfileEvent({
    this.firstName,
    this.lastName,
    this.universityId,
    this.facultyId,
    this.sector,
    this.language,
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