// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'about_config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AboutConfigModel _$AboutConfigModelFromJson(Map<String, dynamic> json) =>
    AboutConfigModel(
      id: json['_id'] as String?,
      key: json['key'] as String,
      mode: json['mode'] as String,
      appName: json['appName'] as String?,
      showVersion: json['showVersion'] as bool?,
      studentProject: json['studentProject'] == null
          ? null
          : StudentProjectConfig.fromJson(
              json['studentProject'] as Map<String, dynamic>,
            ),
      production: json['production'] == null
          ? null
          : ProductionConfig.fromJson(
              json['production'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$AboutConfigModelToJson(AboutConfigModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'key': instance.key,
      'mode': instance.mode,
      'appName': instance.appName,
      'showVersion': instance.showVersion,
      'studentProject': instance.studentProject,
      'production': instance.production,
    };

StudentProjectConfig _$StudentProjectConfigFromJson(
  Map<String, dynamic> json,
) => StudentProjectConfig(
  universityName: json['universityName'] == null
      ? null
      : LocalizedText.fromJson(json['universityName'] as Map<String, dynamic>),
  facultyName: json['facultyName'] == null
      ? null
      : LocalizedText.fromJson(json['facultyName'] as Map<String, dynamic>),
  courseName: json['courseName'] == null
      ? null
      : LocalizedText.fromJson(json['courseName'] as Map<String, dynamic>),
  groupNumber: json['groupNumber'] as String?,
  teacherName: json['teacherName'] == null
      ? null
      : LocalizedText.fromJson(json['teacherName'] as Map<String, dynamic>),
  projectYear: json['projectYear'] as String?,
  projectDescription: json['projectDescription'] == null
      ? null
      : LocalizedText.fromJson(
          json['projectDescription'] as Map<String, dynamic>,
        ),
  projectPurpose: json['projectPurpose'] == null
      ? null
      : LocalizedText.fromJson(json['projectPurpose'] as Map<String, dynamic>),
  teamMembers: (json['teamMembers'] as List<dynamic>?)
      ?.map((e) => TeamMember.fromJson(e as Map<String, dynamic>))
      .toList(),
  footerText: json['footerText'] == null
      ? null
      : LocalizedText.fromJson(json['footerText'] as Map<String, dynamic>),
);

Map<String, dynamic> _$StudentProjectConfigToJson(
  StudentProjectConfig instance,
) => <String, dynamic>{
  'universityName': instance.universityName,
  'facultyName': instance.facultyName,
  'courseName': instance.courseName,
  'groupNumber': instance.groupNumber,
  'teacherName': instance.teacherName,
  'projectYear': instance.projectYear,
  'projectDescription': instance.projectDescription,
  'projectPurpose': instance.projectPurpose,
  'teamMembers': instance.teamMembers,
  'footerText': instance.footerText,
};

ProductionConfig _$ProductionConfigFromJson(Map<String, dynamic> json) =>
    ProductionConfig(
      appDescription: json['appDescription'] == null
          ? null
          : LocalizedText.fromJson(
              json['appDescription'] as Map<String, dynamic>,
            ),
      contactEmail: json['contactEmail'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      footerText: json['footerText'] == null
          ? null
          : LocalizedText.fromJson(json['footerText'] as Map<String, dynamic>),
      copyrightYear: json['copyrightYear'] as String?,
    );

Map<String, dynamic> _$ProductionConfigToJson(ProductionConfig instance) =>
    <String, dynamic>{
      'appDescription': instance.appDescription,
      'contactEmail': instance.contactEmail,
      'websiteUrl': instance.websiteUrl,
      'footerText': instance.footerText,
      'copyrightYear': instance.copyrightYear,
    };

LocalizedText _$LocalizedTextFromJson(Map<String, dynamic> json) =>
    LocalizedText(
      en: json['en'] as String?,
      ru: json['ru'] as String?,
      az: json['az'] as String?,
    );

Map<String, dynamic> _$LocalizedTextToJson(LocalizedText instance) =>
    <String, dynamic>{'en': instance.en, 'ru': instance.ru, 'az': instance.az};

TeamMember _$TeamMemberFromJson(Map<String, dynamic> json) => TeamMember(
  name: json['name'] == null
      ? null
      : LocalizedText.fromJson(json['name'] as Map<String, dynamic>),
  order: (json['order'] as num?)?.toInt(),
);

Map<String, dynamic> _$TeamMemberToJson(TeamMember instance) =>
    <String, dynamic>{'name': instance.name, 'order': instance.order};
