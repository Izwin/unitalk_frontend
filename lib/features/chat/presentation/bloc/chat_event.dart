import 'dart:io';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/features/chat/data/model/message_model.dart';

abstract class ChatEvent {}

class LoadParticipantsEvent extends ChatEvent {}

class LoadMessagesEvent extends ChatEvent {
  final int page;
  final int limit;
  final DateTime? before;

  LoadMessagesEvent({
    this.page = 1,
    this.limit = 50,
    this.before,
  });
}

class LoadMoreMessagesEvent extends ChatEvent {}

// ОБНОВЛЕНО: Добавлен videoFile
class SendMessageEvent extends ChatEvent {
  final String content;
  final File? imageFile;
  final File? videoFile;
  final String? replyTo;

  SendMessageEvent({
    required this.content,
    this.imageFile,
    this.videoFile,
    this.replyTo,
  });
}

class EditMessageEvent extends ChatEvent {
  final String messageId;
  final String content;

  EditMessageEvent({
    required this.messageId,
    required this.content,
  });
}

class DeleteMessageEvent extends ChatEvent {
  final String messageId;

  DeleteMessageEvent({required this.messageId});
}

class ConnectSocketEvent extends ChatEvent {
  final String token;

  ConnectSocketEvent({required this.token});
}

class DisconnectSocketEvent extends ChatEvent {}

class NewMessageReceivedEvent extends ChatEvent {
  final MessageModel message;

  NewMessageReceivedEvent({required this.message});
}

class MessageEditedReceivedEvent extends ChatEvent {
  final MessageModel message;

  MessageEditedReceivedEvent({required this.message});
}

class MessageDeletedReceivedEvent extends ChatEvent {
  final String messageId;

  MessageDeletedReceivedEvent({required this.messageId});
}

class StartTypingEvent extends ChatEvent {}

class StopTypingEvent extends ChatEvent {}

class UserTypingReceivedEvent extends ChatEvent {
  final String userId;
  final String firstName;
  final String lastName;

  UserTypingReceivedEvent({
    required this.userId,
    required this.firstName,
    required this.lastName,
  });
}

class UserStoppedTypingReceivedEvent extends ChatEvent {
  final String userId;

  UserStoppedTypingReceivedEvent({required this.userId});
}

class GetOnlineUsersEvent extends ChatEvent {}

class OnlineUsersReceivedEvent extends ChatEvent {
  final List<OnlineUserModel> users;

  OnlineUsersReceivedEvent({required this.users});
}

class UserJoinedReceivedEvent extends ChatEvent {
  final OnlineUserModel user;

  UserJoinedReceivedEvent({required this.user});
}

class UserLeftReceivedEvent extends ChatEvent {
  final String userId;

  UserLeftReceivedEvent({required this.userId});
}

class MarkMessagesAsReadEvent extends ChatEvent {
  final String lastReadMessageId;

  MarkMessagesAsReadEvent({required this.lastReadMessageId});
}

class MessagesReadReceivedEvent extends ChatEvent {
  final String userId;
  final String lastReadMessageId;
  final DateTime timestamp;

  MessagesReadReceivedEvent({
    required this.userId,
    required this.lastReadMessageId,
    required this.timestamp,
  });
}

class LoadChatInfoEvent extends ChatEvent {}

class ConnectionStatusChangedEvent extends ChatEvent {
  final bool isConnected;

  ConnectionStatusChangedEvent({required this.isConnected});
}