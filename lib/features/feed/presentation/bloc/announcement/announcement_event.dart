// features/feed/presentation/bloc/announcement/announcement_event.dart
import 'package:equatable/equatable.dart';

abstract class AnnouncementEvent extends Equatable {
  const AnnouncementEvent();

  @override
  List<Object?> get props => [];
}

class GetAnnouncementsEvent extends AnnouncementEvent {}

class MarkAnnouncementViewedEvent extends AnnouncementEvent {
  final String announcementId;

  const MarkAnnouncementViewedEvent(this.announcementId);

  @override
  List<Object?> get props => [announcementId];
}

class MarkAnnouncementClickedEvent extends AnnouncementEvent {
  final String announcementId;

  const MarkAnnouncementClickedEvent(this.announcementId);

  @override
  List<Object?> get props => [announcementId];
}