// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
  language: json['language'] as String?,
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
  'language': instance.language,
};

const _$SectorEnumMap = {
  Sector.english: 'en',
  Sector.russian: 'ru',
  Sector.azerbaijani: 'az',
};
