// features/support/presentation/bloc/support_state.dart
import 'package:equatable/equatable.dart';
import 'package:unitalk/features/support/data/model/support_message_model.dart';

enum SupportStatus { initial, loading, success, failure }

class SupportState extends Equatable {
  final SupportStatus status;
  final List<SupportMessageModel> messages;
  final int messagesPage;
  final bool messagesLastPage;
  final SupportMessageModel? currentMessage;
  final String? errorMessage;

  const SupportState._({
    required this.status,
    this.messages = const [],
    required this.messagesPage,
    required this.messagesLastPage,
    this.currentMessage,
    this.errorMessage,
  });

  factory SupportState.initial() => const SupportState._(
    status: SupportStatus.initial,
    messages: [],
    messagesLastPage: false,
    messagesPage: 0,
  );

  SupportState copyWith({
    SupportStatus? status,
    List<SupportMessageModel>? messages,
    int? messagesPage,
    bool? messagesLastPage,
    SupportMessageModel? currentMessage,
    String? errorMessage,
  }) {
    return SupportState._(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      messagesPage: messagesPage ?? this.messagesPage,
      messagesLastPage: messagesLastPage ?? this.messagesLastPage,
      currentMessage: currentMessage ?? this.currentMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    messages,
    messagesPage,
    messagesLastPage,
    currentMessage,
    errorMessage,
  ];
}