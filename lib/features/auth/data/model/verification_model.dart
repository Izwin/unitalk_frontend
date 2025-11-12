import 'package:json_annotation/json_annotation.dart';

part 'verification_model.g.dart';

@JsonSerializable()
class VerificationModel {
  final String? id;
  final String? userId;
  final String? studentCardImageUrl;
  final String status; // 'pending', 'approved', 'rejected', 'not_submitted'
  final String? rejectionReason;
  final String? approvedBy;
  final DateTime? createdAt;
  final DateTime? approvedAt;

  VerificationModel({
    this.id,
    this.userId,
    this.studentCardImageUrl,
    required this.status,
    this.rejectionReason,
    this.approvedBy,
    this.createdAt,
    this.approvedAt,
  });

  factory VerificationModel.fromJson(Map<String, dynamic> json) =>
      _$VerificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$VerificationModelToJson(this);

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isNotSubmitted => status == 'not_submitted';
}