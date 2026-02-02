// lib/features/auth/data/model/user_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'package:unitalk/features/block/data/model/block_model.dart';
import 'package:unitalk/features/faculty/data/models/faculty_model.dart';
import 'package:unitalk/features/university/data/models/university_model.dart';
import 'package:unitalk/l10n/app_localizations.dart';
import 'verification_model.dart';

part 'user_model.g.dart';

// ═══════════════════════════════════════════════
// ENUMS
// ═══════════════════════════════════════════════

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

/// Курс обучения
enum Course {
  @JsonValue('1')
  year1,
  @JsonValue('2')
  year2,
  @JsonValue('3')
  year3,
  @JsonValue('4')
  year4,
  @JsonValue('master_1')
  master1,
  @JsonValue('master_2')
  master2,
  @JsonValue('phd')
  phd,
  @JsonValue('graduate')
  graduate;

  String get code {
    switch (this) {
      case Course.year1:
        return '1';
      case Course.year2:
        return '2';
      case Course.year3:
        return '3';
      case Course.year4:
        return '4';
      case Course.master1:
        return 'master_1';
      case Course.master2:
        return 'master_2';
      case Course.phd:
        return 'phd';
      case Course.graduate:
        return 'graduate';
    }
  }

  String getLocalizedName(AppLocalizations l10n) {
    switch (this) {
      case Course.year1:
        return l10n.year1;
      case Course.year2:
        return l10n.year2;
      case Course.year3:
        return l10n.year3;
      case Course.year4:
        return l10n.year4;
      case Course.master1:
        return l10n.master1;
      case Course.master2:
        return l10n.master2;
      case Course.phd:
        return l10n.phd;
      case Course.graduate:
        return l10n.graduate;
    }
  }

  static Course? fromCode(String? code) {
    if (code == null) return null;
    switch (code) {
      case '1':
        return Course.year1;
      case '2':
        return Course.year2;
      case '3':
        return Course.year3;
      case '4':
        return Course.year4;
      case 'master_1':
        return Course.master1;
      case 'master_2':
        return Course.master2;
      case 'phd':
        return Course.phd;
      case 'graduate':
        return Course.graduate;
      default:
        return null;
    }
  }
}

// ═══════════════════════════════════════════════
// BADGE MODEL
// ═══════════════════════════════════════════════

@JsonSerializable()
class BadgeModel {
  final String id;
  final String icon;
  final String? tier;
  final int? value;

  BadgeModel({
    required this.id,
    required this.icon,
    this.tier,
    this.value,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) =>
      _$BadgeModelFromJson(json);

  Map<String, dynamic> toJson() => _$BadgeModelToJson(this);
}

// ═══════════════════════════════════════════════
// BADGE PROGRESS MODEL
// ═══════════════════════════════════════════════

@JsonSerializable()
class BadgeProgressModel {
  final int current;
  final int target;
  final bool achieved;

  BadgeProgressModel({
    this.current = 0,
    this.target = 0,
    this.achieved = false,
  });

  double get progress => target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

  factory BadgeProgressModel.fromJson(Map<String, dynamic> json) =>
      _$BadgeProgressModelFromJson(json);

  Map<String, dynamic> toJson() => _$BadgeProgressModelToJson(this);
}

// ═══════════════════════════════════════════════
// USER STATS MODEL
// ═══════════════════════════════════════════════

@JsonSerializable()
class UserStatsModel {
  final int postsCount;
  final int commentsCount;
  final int totalLikesReceived;

  UserStatsModel({
    this.postsCount = 0,
    this.commentsCount = 0,
    this.totalLikesReceived = 0,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) =>
      _$UserStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserStatsModelToJson(this);
}

// ═══════════════════════════════════════════════
// USER MODEL
// ═══════════════════════════════════════════════

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
  final String? language;

  // ═══════════════════════════════════════════════
  // НОВЫЕ ПОЛЯ
  // ═══════════════════════════════════════════════

  final String? bio;
  final String? status;
  final String? profileEmoji;
  final Course? course;
  final String? instagramUsername;
  final int? registrationNumber;
  final UserStatsModel? stats;
  final List<BadgeModel>? badges;
  final Map<String, BadgeProgressModel>? badgeProgress;

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
    this.language,
    this.bio,
    this.status,
    this.profileEmoji,
    this.course,
    this.instagramUsername,
    this.registrationNumber,
    this.stats,
    this.badges,
    this.badgeProgress,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  // ═══════════════════════════════════════════════
  // GETTERS
  // ═══════════════════════════════════════════════

  bool get isProfileComplete =>
      firstName != null &&
          lastName != null &&
          university != null &&
          faculty != null &&
          sector != null;

  bool get canInteract => blockStatus?.canInteract ?? true;
  bool get isBlocked => blockStatus?.isBlocked ?? false;
  bool get isBlockedBy => blockStatus?.isBlockedBy ?? false;

  bool get isOG => registrationNumber != null && registrationNumber! <= 1000;

  String? get ogTier {
    if (registrationNumber == null) return null;
    if (registrationNumber! <= 100) return 'gold';
    if (registrationNumber! <= 500) return 'silver';
    if (registrationNumber! <= 1000) return 'bronze';
    return null;
  }

  String get displayName {
    final name = [firstName, lastName].whereType<String>().join(' ');
    if (profileEmoji != null && profileEmoji!.isNotEmpty) {
      return '$name $profileEmoji';
    }
    return name;
  }

  String? get instagramUrl {
    if (instagramUsername == null || instagramUsername!.isEmpty) return null;
    return 'https://instagram.com/$instagramUsername';
  }

  int get earnedBadgesCount => badges?.length ?? 0;

  bool hasBadge(String badgeId) {
    return badges?.any((b) => b.id == badgeId) ?? false;
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? photoUrl,
    String? firstName,
    String? lastName,
    UniversityModel? university,
    FacultyModel? faculty,
    Sector? sector,
    bool? isVerified,
    VerificationModel? verification,
    BlockStatusModel? blockStatus,
    int? friendsCount,
    int? pendingRequestsCount,
    String? language,
    String? bio,
    String? status,
    String? profileEmoji,
    Course? course,
    String? instagramUsername,
    int? registrationNumber,
    UserStatsModel? stats,
    List<BadgeModel>? badges,
    Map<String, BadgeProgressModel>? badgeProgress,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      university: university ?? this.university,
      faculty: faculty ?? this.faculty,
      sector: sector ?? this.sector,
      isVerified: isVerified ?? this.isVerified,
      verification: verification ?? this.verification,
      blockStatus: blockStatus ?? this.blockStatus,
      friendsCount: friendsCount ?? this.friendsCount,
      pendingRequestsCount: pendingRequestsCount ?? this.pendingRequestsCount,
      language: language ?? this.language,
      bio: bio ?? this.bio,
      status: status ?? this.status,
      profileEmoji: profileEmoji ?? this.profileEmoji,
      course: course ?? this.course,
      instagramUsername: instagramUsername ?? this.instagramUsername,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      stats: stats ?? this.stats,
      badges: badges ?? this.badges,
      badgeProgress: badgeProgress ?? this.badgeProgress,
    );
  }
}