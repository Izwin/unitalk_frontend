// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BadgeModel _$BadgeModelFromJson(Map<String, dynamic> json) => BadgeModel(
  id: json['id'] as String,
  icon: json['icon'] as String,
  tier: json['tier'] as String?,
  value: (json['value'] as num?)?.toInt(),
);

Map<String, dynamic> _$BadgeModelToJson(BadgeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'icon': instance.icon,
      'tier': instance.tier,
      'value': instance.value,
    };

BadgeProgressModel _$BadgeProgressModelFromJson(Map<String, dynamic> json) =>
    BadgeProgressModel(
      current: (json['current'] as num?)?.toInt() ?? 0,
      target: (json['target'] as num?)?.toInt() ?? 0,
      achieved: json['achieved'] as bool? ?? false,
    );

Map<String, dynamic> _$BadgeProgressModelToJson(BadgeProgressModel instance) =>
    <String, dynamic>{
      'current': instance.current,
      'target': instance.target,
      'achieved': instance.achieved,
    };

UserStatsModel _$UserStatsModelFromJson(Map<String, dynamic> json) =>
    UserStatsModel(
      postsCount: (json['postsCount'] as num?)?.toInt() ?? 0,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
      totalLikesReceived: (json['totalLikesReceived'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$UserStatsModelToJson(UserStatsModel instance) =>
    <String, dynamic>{
      'postsCount': instance.postsCount,
      'commentsCount': instance.commentsCount,
      'totalLikesReceived': instance.totalLikesReceived,
    };

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['_id'] as String?,
  email: json['email'] as String?,
  photoUrl: json['photoUrl'] as String?,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  university: json['universityId'] == null
      ? null
      : UniversityModel.fromJson(json['universityId'] as Map<String, dynamic>),
  faculty: json['facultyId'] == null
      ? null
      : FacultyModel.fromJson(json['facultyId'] as Map<String, dynamic>),
  sector: $enumDecodeNullable(_$SectorEnumMap, json['sector']),
  isVerified: json['isVerified'] as bool?,
  verification: json['verificationId'] == null
      ? null
      : VerificationModel.fromJson(
          json['verificationId'] as Map<String, dynamic>,
        ),
  blockStatus: json['blockStatus'] == null
      ? null
      : BlockStatusModel.fromJson(json['blockStatus'] as Map<String, dynamic>),
  friendsCount: (json['friendsCount'] as num?)?.toInt(),
  pendingRequestsCount: (json['pendingRequestsCount'] as num?)?.toInt(),
  language: json['language'] as String?,
  bio: json['bio'] as String?,
  status: json['status'] as String?,
  profileEmoji: json['profileEmoji'] as String?,
  course: $enumDecodeNullable(_$CourseEnumMap, json['course']),
  instagramUsername: json['instagramUsername'] as String?,
  registrationNumber: (json['registrationNumber'] as num?)?.toInt(),
  stats: json['stats'] == null
      ? null
      : UserStatsModel.fromJson(json['stats'] as Map<String, dynamic>),
  badges: (json['badges'] as List<dynamic>?)
      ?.map((e) => BadgeModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  badgeProgress: (json['badgeProgress'] as Map<String, dynamic>?)?.map(
    (k, e) =>
        MapEntry(k, BadgeProgressModel.fromJson(e as Map<String, dynamic>)),
  ),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  '_id': instance.id,
  'email': instance.email,
  'photoUrl': instance.photoUrl,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'universityId': instance.university,
  'facultyId': instance.faculty,
  'sector': _$SectorEnumMap[instance.sector],
  'isVerified': instance.isVerified,
  'verificationId': instance.verification,
  'blockStatus': instance.blockStatus,
  'friendsCount': instance.friendsCount,
  'pendingRequestsCount': instance.pendingRequestsCount,
  'language': instance.language,
  'bio': instance.bio,
  'status': instance.status,
  'profileEmoji': instance.profileEmoji,
  'course': _$CourseEnumMap[instance.course],
  'instagramUsername': instance.instagramUsername,
  'registrationNumber': instance.registrationNumber,
  'stats': instance.stats,
  'badges': instance.badges,
  'badgeProgress': instance.badgeProgress,
};

const _$SectorEnumMap = {
  Sector.english: 'en',
  Sector.russian: 'ru',
  Sector.azerbaijani: 'az',
};

const _$CourseEnumMap = {
  Course.year1: '1',
  Course.year2: '2',
  Course.year3: '3',
  Course.year4: '4',
  Course.master1: 'master_1',
  Course.master2: 'master_2',
  Course.phd: 'phd',
  Course.graduate: 'graduate',
};
