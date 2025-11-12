// features/feed/presentation/bloc/announcement/announcement_state.dart
import 'package:equatable/equatable.dart';
import 'package:unitalk/features/feed/data/model/announcement_model.dart';

enum AnnouncementStatus { initial, loading, success, failure }

class AnnouncementState extends Equatable {
  final AnnouncementStatus status;
  final List<AnnouncementModel> announcements;
  final String? errorMessage;

  const AnnouncementState({
    required this.status,
    required this.announcements,
    this.errorMessage,
  });

  factory AnnouncementState.initial() {
    return const AnnouncementState(
      status: AnnouncementStatus.initial,
      announcements: [],
      errorMessage: null,
    );
  }

  AnnouncementState copyWith({
    AnnouncementStatus? status,
    List<AnnouncementModel>? announcements,
    String? errorMessage,
  }) {
    return AnnouncementState(
      status: status ?? this.status,
      announcements: announcements ?? this.announcements,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, announcements, errorMessage];
}