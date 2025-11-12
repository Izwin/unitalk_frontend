// features/feed/presentation/bloc/announcement/announcement_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/features/feed/domain/repository/announcement_repository.dart';
import 'announcement_event.dart';
import 'announcement_state.dart';

class AnnouncementBloc extends Bloc<AnnouncementEvent, AnnouncementState> {
  final AnnouncementRepository announcementRepository;

  AnnouncementBloc({required this.announcementRepository})
      : super(AnnouncementState.initial()) {
    on<GetAnnouncementsEvent>(_onGetAnnouncements);
    on<MarkAnnouncementViewedEvent>(_onMarkViewed);
    on<MarkAnnouncementClickedEvent>(_onMarkClicked);
  }

  Future<void> _onGetAnnouncements(
      GetAnnouncementsEvent event,
      Emitter<AnnouncementState> emit,
      ) async {
    emit(state.copyWith(
      status: AnnouncementStatus.loading,
      errorMessage: null,
    ));

    final result = await announcementRepository.getAnnouncements();

    result.fold(
          (failure) => emit(state.copyWith(
        status: AnnouncementStatus.failure,
        errorMessage: failure.message,
      )),
          (announcements) => emit(state.copyWith(
        status: AnnouncementStatus.success,
        announcements: announcements,
      )),
    );
  }

  Future<void> _onMarkViewed(
      MarkAnnouncementViewedEvent event,
      Emitter<AnnouncementState> emit,
      ) async {
    await announcementRepository.markViewed(event.announcementId);
  }

  Future<void> _onMarkClicked(
      MarkAnnouncementClickedEvent event,
      Emitter<AnnouncementState> emit,
      ) async {
    await announcementRepository.markClicked(event.announcementId);
  }
}