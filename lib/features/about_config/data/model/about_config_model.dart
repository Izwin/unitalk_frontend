import 'package:json_annotation/json_annotation.dart';

part 'about_config_model.g.dart';

@JsonSerializable()
class AboutConfigModel {
  @JsonKey(name: '_id')
  final String? id;
  final String key;
  final String mode;
  final String? appName;
  final bool? showVersion;
  final StudentProjectConfig? studentProject;
  final ProductionConfig? production;

  AboutConfigModel({
    this.id,
    required this.key,
    required this.mode,
    this.appName,
    this.showVersion,
    this.studentProject,
    this.production,
  });

  factory AboutConfigModel.fromJson(Map<String, dynamic> json) =>
      _$AboutConfigModelFromJson(json);

  Map<String, dynamic> toJson() => _$AboutConfigModelToJson(this);

  bool get isStudentProject => mode == 'student_project';
  bool get isProduction => mode == 'production';
}

@JsonSerializable()
class StudentProjectConfig {
  final LocalizedText? universityName;
  final LocalizedText? facultyName;
  final LocalizedText? courseName;
  final String? groupNumber;
  final LocalizedText? teacherName;
  final String? projectYear;
  final LocalizedText? projectDescription;
  final LocalizedText? projectPurpose;
  final List<TeamMember>? teamMembers;
  final LocalizedText? footerText;

  StudentProjectConfig({
    this.universityName,
    this.facultyName,
    this.courseName,
    this.groupNumber,
    this.teacherName,
    this.projectYear,
    this.projectDescription,
    this.projectPurpose,
    this.teamMembers,
    this.footerText,
  });

  factory StudentProjectConfig.fromJson(Map<String, dynamic> json) =>
      _$StudentProjectConfigFromJson(json);

  Map<String, dynamic> toJson() => _$StudentProjectConfigToJson(this);
}

@JsonSerializable()
class ProductionConfig {
  final LocalizedText? appDescription;
  final String? contactEmail;
  final String? websiteUrl;
  final LocalizedText? footerText;
  final String? copyrightYear;

  ProductionConfig({
    this.appDescription,
    this.contactEmail,
    this.websiteUrl,
    this.footerText,
    this.copyrightYear,
  });

  factory ProductionConfig.fromJson(Map<String, dynamic> json) =>
      _$ProductionConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ProductionConfigToJson(this);
}

@JsonSerializable()
class LocalizedText {
  final String? en;
  final String? ru;
  final String? az;

  LocalizedText({this.en, this.ru, this.az});

  factory LocalizedText.fromJson(Map<String, dynamic> json) =>
      _$LocalizedTextFromJson(json);

  Map<String, dynamic> toJson() => _$LocalizedTextToJson(this);

  String get(String locale) {
    switch (locale) {
      case 'ru':
        return ru ?? en ?? az ?? '';
      case 'az':
        return az ?? en ?? ru ?? '';
      default:
        return en ?? ru ?? az ?? '';
    }
  }
}

@JsonSerializable()
class TeamMember {
  final LocalizedText? name;  // Изменено с String на LocalizedText
  final int? order;

  TeamMember({this.name, this.order});

  factory TeamMember.fromJson(Map<String, dynamic> json) =>
      _$TeamMemberFromJson(json);

  Map<String, dynamic> toJson() => _$TeamMemberToJson(this);

  String getName(String locale) => name?.get(locale) ?? '';
}