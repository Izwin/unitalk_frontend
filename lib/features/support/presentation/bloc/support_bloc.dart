// features/support/presentation/bloc/support_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/features/support/domain/repository/support_repository.dart';
import 'support_event.dart';
import 'support_state.dart';

class SupportBloc extends Bloc<SupportEvent, SupportState> {
  final SupportRepository supportRepository;

  SupportBloc({required this.supportRepository})
      : super(SupportState.initial()) {
    on<CreateSupportMessageEvent>(_onCreateSupportMessage);
    on<GetMyMessagesEvent>(_onGetMyMessages);
    on<GetMessageEvent>(_onGetMessage);
  }

  Future<void> _onCreateSupportMessage(
      CreateSupportMessageEvent event,
      Emitter<SupportState> emit,
      ) async {
    emit(state.copyWith(status: SupportStatus.loading, errorMessage: null));

    final result = await supportRepository.createSupportMessage(
      subject: event.subject,
      message: event.message,
      category: event.category,
      imageFile: event.imageFile,
    );

    result.fold(
          (failure) => emit(state.copyWith(
        status: SupportStatus.failure,
        errorMessage: failure.message,
      )),
          (message) {
        final updatedMessages = [message, ...state.messages];
        emit(state.copyWith(
          status: SupportStatus.success,
          messages: updatedMessages,
          currentMessage: message,
        ));
      },
    );
  }

  Future<void> _onGetMyMessages(
      GetMyMessagesEvent event,
      Emitter<SupportState> emit,
      ) async {
    emit(state.copyWith(status: SupportStatus.loading, errorMessage: null));

    final result = await supportRepository.getMyMessages(
      page: event.page,
      limit: event.limit,
      status: event.status,
    );

    result.fold(
          (failure) => emit(state.copyWith(
        status: SupportStatus.failure,
        errorMessage: failure.message,
      )),
          (messages) {
        final updatedMessages =
        event.page == 1 ? messages : [...state.messages, ...messages];

        emit(state.copyWith(
          status: SupportStatus.success,
          messages: updatedMessages,
          messagesPage: state.messagesPage + 1,
          messagesLastPage: messages.length < event.limit,
        ));
      },
    );
  }

  Future<void> _onGetMessage(
      GetMessageEvent event,
      Emitter<SupportState> emit,
      ) async {
    emit(state.copyWith(status: SupportStatus.loading, errorMessage: null));

    final result = await supportRepository.getMessage(event.messageId);

    result.fold(
          (failure) => emit(state.copyWith(
        status: SupportStatus.failure,
        errorMessage: failure.message,
      )),
          (message) => emit(state.copyWith(
        status: SupportStatus.success,
        currentMessage: message,
      )),
    );
  }
}