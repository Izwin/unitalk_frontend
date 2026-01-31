import 'package:json_annotation/json_annotation.dart';
import 'package:unitalk/features/block/data/model/block_model.dart';
import 'package:unitalk/features/faculty/data/models/faculty_model.dart';
import 'package:unitalk/features/university/data/models/university_model.dart';
import 'verification_model.dart';

part 'user_model.g.dart';

enum Sector {
  @JsonValue('en')
  english,
  @JsonValue('ru')
  russian,
  @JsonValue('az')
  azerbaijani;

  String get code {
    switch (this) {
      case Sector.english:
        return 'en';
      case Sector.russian:
        return 'ru';
      case Sector.azerbaijani:
        return 'az';
    }
  }

  String get displayName {
    switch (this) {
      case Sector.english:
        return 'English';
      case Sector.russian:
        return 'Russian';
      case Sector.azerbaijani:
        return 'Azerbaijani';
    }
  }

  String get flagEmoji {
    switch (this) {
      case Sector.english:
        return '🇬🇧';
      case Sector.russian:
        return '🇷🇺';
      case Sector.azerbaijani:
        return '🇦🇿';
    }
  }

  static Sector? fromCode(String? code) {
    if (code == null) return null;
    switch (code) {
      case 'en':
        return Sector.english;
      case 'ru':
        return Sector.russian;
      case 'az':
        return Sector.azerbaijani;
      default:
        return null;
    }
  }
}

@JsonSerializable()
class UserModel {
  @JsonKey(name: '_id')
  final String? id;
  final String? email;
  final String? photoUrl;
  final String? firstName;
  final String? lastName;
  @JsonKey(name: 'universityId')
  final UniversityModel? university;
  @JsonKey(name: 'facultyId')
  final FacultyModel? faculty;
  final Sector? sector;
  final bool? isVerified;
  @JsonKey(name: 'verificationId')
  final VerificationModel? verification;
  final BlockStatusModel? blockStatus;
  final int? friendsCount;
  final int? pendingRequestsCount;

  // НОВОЕ: Язык пользователя с сервера
  final String? language;

  UserModel({
    required this.id,
    this.email,
    this.photoUrl,
    this.firstName,
    this.lastName,
    this.university,
    this.faculty,
    this.sector,
    this.isVerified,
    this.verification,
    this.blockStatus,
    this.friendsCount,
    this.pendingRequestsCount,
    this.language, // НОВОЕ
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  bool get isProfileComplete =>
      firstName != null &&
          lastName != null &&
          university != null &&
          faculty != null &&
          sector != null;

  bool get canInteract => blockStatus?.canInteract ?? true;
  bool get isBlocked => blockStatus?.isBlocked ?? false;
  bool get isBlockedBy => blockStatus?.isBlockedBy ?? false;
}