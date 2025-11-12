// features/support/presentation/bloc/support_event.dart
import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class SupportEvent extends Equatable {
  const SupportEvent();

  @override
  List<Object?> get props => [];
}

class CreateSupportMessageEvent extends SupportEvent {
  final String subject;
  final String message;
  final String category;
  final File? imageFile;

  const CreateSupportMessageEvent({
    required this.subject,
    required this.message,
    required this.category,
    this.imageFile,
  });

  @override
  List<Object?> get props => [subject, message, category, imageFile];
}

class GetMyMessagesEvent extends SupportEvent {
  final int page;
  final int limit;
  final String? status;

  const GetMyMessagesEvent({
    this.page = 1,
    this.limit = 20,
    this.status,
  });

  @override
  List<Object?> get props => [page, limit, status];
}

class GetMessageEvent extends SupportEvent {
  final String messageId;

  const GetMessageEvent(this.messageId);

  @override
  List<Object?> get props => [messageId];
}